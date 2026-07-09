# TESTPLAN: LED MUX Controller — UVM Verification

**Source spec:** SPEC.md (PSDC_UVM_FINAL_PROJECT_DV_BATCH7.pdf, PCDA2025 Rev1.0)  
**Architecture:** ARCHITECTURE.md  
**Methodology:** UVM 1.2, metrics-driven verification

This testplan is the build checklist. Each row tells you what test to write, what sequence flow to run, what values to constrain, and what checker/scoreboard/SVA to implement.

**Deliverable format:** The final testplan must be exported to Excel using `LED_MUX_CONTROLLER_stu/Template-TestPlan.xlsx`. See **§9** for column layout, row rules, and mapping from this document into the template.

---

## How to use this document

| Column | What you decide |
|---|---|
| **Test name** | UVM test class name (`*_test`) and virtual/child sequence name |
| **Sequence flow** | Ordered steps across APB and LED agents |
| **Constraints** | Value ranges and rules from SPEC.md (C-1..C-8, FR, AC) |
| **Checkers** | What to build: SVA, scoreboard logic, monitor-side checks, covergroups |

**Legend**

| Tag | Meaning |
|---|---|
| `BASIC` | Happy-path functional test |
| `CORNER` | Boundary, negative, timing, or protocol stress |
| `SVA` | SystemVerilog assertion (bound in `tb_top`) |
| `SCB` | `led_scoreboard` check |
| `MON` | Monitor or driver protocol enforcement |
| `COV` | `led_coverage` covergroup bin |

---

## 0. Shared build inventory

Implement these once; all tests below reuse them.

### 0.1 Sequences to build

| Sequence | Agent | Purpose |
|---|---|---|
| `apb_write_seq` | APB | Single APB write (SETUP → ACCESS) |
| `apb_read_seq` | APB | Single APB read (SETUP → ACCESS) |
| `apb_wr_rd_seq` | APB | Write then read same address |
| `apb_invalid_addr_seq` | APB | Access unsupported address |
| `apb_done_poll_seq` | APB | Poll `0x4004` until `Done==1` or timeout |
| `led_error_seq` | LED | Drive one `error_q` value, hold ≥ 1002 cycles |
| `led_error_burst_seq` | LED | Drive multiple `error_q` values back-to-back |
| `led_reset_seq` | LED | Assert/deassert `rst_n` via `led_if` |
| `led_mux_virtual_seq` | Virtual | Coordinates APB + LED ordering for integration tests |

### 0.2 Scoreboard (`led_scoreboard`) — build checklist

| ID | Check | Trigger | Pass criteria |
|---|---|---|---|
| SCB-1 | Register mirror — `LED_enable` | APB write/read `0x4000` | Scoreboard state matches DUT; readback equals write |
| SCB-2 | Register mirror — `Done` | APB read `0x4004` | `done_flag` updated; no write side-effect |
| SCB-3 | Register mirror — scratch pad | APB write/read `0x4008` | Readback equals last write |
| SCB-4 | Golden model — bin→BCD | LED monitor sample after `Done==1` and `LED_enable==1` | Displayed value = `error_q % 1_000_000` |
| SCB-5 | Golden model — 7-seg encode | Per digit when `sel_out` identifies position | `seg_out[6:0]` matches SPEC §4.4 table |
| SCB-6 | `seg_out[7]` check | Active digit comparison | `seg_out[7] == 1` when segments active |
| SCB-7 | Enable gating | `LED_enable==0` | No `seg_out` update for new `error_q` |
| SCB-8 | Done gating | `Done==0` | Scoreboard skips `seg_out` compare (no false fail) |
| SCB-9 | Overflow | `error_q > 999_999` | Expected digits from modulo only |

### 0.3 SVA checker (`led_mux_sva`) — build checklist

| ID | Assertion / cover | Signals | Spec ref |
|---|---|---|---|
| SVA-1 | After reset deassert: `sel_out == 6'h3E` | `rst_n`, `sel_out` | AC-R1 |
| SVA-2 | After reset deassert: `seg_out == 8'h80` | `rst_n`, `seg_out` | AC-R2 |
| SVA-3 | `sel_out` one-hot active-low during normal op | `sel_out`, `rst_n` | AC-M1 |
| SVA-4 | `seg_out[7] == 1` when any segment active | `seg_out` | AC-B2 |
| SVA-5 | APB SETUP: `psel==1`, `penable==0` | `apb_if` | C-6 |
| SVA-6 | APB ACCESS: `psel==1`, `penable==1` | `apb_if` | C-6 |
| SVA-7 | `o_pready` high on completing transfer | `apb_if` | AC-A3 |
| SVA-8 | `o_pslerr` on invalid address | `apb_if` | AC-A2 |
| SVA-9 | Cover: each digit position selected | `sel_out` | AC-C1 |
| SVA-10 | Cover: each decimal digit 0–9 displayed | `seg_out`, `sel_out` | AC-C1 |

### 0.4 Functional coverage (`led_coverage`) — build checklist

| Covergroup | Bins / crosses | Closed by |
|---|---|---|
| `cg_error_q` | `0`, `1`, `9`, `99`, `999_999`, `1_000_000`, `1_048_575`, random mid-range | LED tests |
| `cg_digits` | digit position 0–5 × digit value 0–9 | LED + random tests |
| `cg_enable` | `LED_enable` 0→1, 1→0, default-at-reset | APB + integration tests |
| `cg_done` | `Done` 0, `Done` 1, poll-before-done | Integration tests |
| `cg_overflow` | in-range vs overflow bucket | Overflow corner tests |

---

## 1. APB Controller block

APB SLAVE register access, protocol, and control/status behavior.

### 1.1 APB — Basic function

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| A-B01 | `apb_reset_defaults_test` | `led_reset_seq` → `apb_read_seq` ×3 | 1. Reset DUT 2. Read `0x4000` (expect `LED_enable=1`) 3. Read `0x4004` (expect `Done=0`) 4. Read `0x4008` (expect `0`) | No APB traffic during reset assert | **SCB-1, SCB-2, SCB-3**; **SVA-1, SVA-2** |
| A-B02 | `apb_led_enable_write_read_test` | `apb_wr_rd_seq` | 1. Write `0x4000 = 0` 2. Read `0x4000` 3. Write `0x4000 = 1` 4. Read `0x4000` | `wdata[0]` only; upper bits ignored or stored per RTL | **SCB-1**; **COV** `cg_enable` |
| A-B03 | `apb_scratchpad_wr_rd_test` | `apb_wr_rd_seq` | 1. Write `0x4008 = 32'hDEAD_BEEF` 2. Read `0x4008` | `wdata` full 32-bit | **SCB-3** |
| A-B04 | `apb_done_read_only_test` | `apb_write_seq` → `apb_read_seq` | 1. Write `0x4004 = 32'hFFFF_FFFF` (illegal) 2. Read `0x4004` | `wdata` arbitrary; address fixed `0x4004` | **SCB-2**; **MON**: monitor flags attempted RO write; **SVA** no crash |
| A-B05 | `apb_pready_no_wait_test` | `apb_write_seq` + `apb_read_seq` | 1. Write `0x4000` 2. Read `0x4004` | Standard 2-phase APB | **SVA-5, SVA-6, SVA-7** |
| A-B06 | `apb_default_enable_led_path_test` | `led_mux_virtual_seq` | 1. No write to `0x4000` (use default) 2. Drive `error_q=7` 3. Poll Done 4. Scoreboard compare | `error_q inside {[1:99]}` | **SCB-1, SCB-4..6, SCB-8**; **SVA-3,4** |

### 1.2 APB — Corner cases

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| A-C01 | `apb_invalid_addr_test` | `apb_invalid_addr_seq` | 1. SETUP+ACCESS write `0x5000` 2. Check `pslerr` 3. SETUP+ACCESS read `0x0000` 4. Check `pslerr` | `addr NOT IN {0x4000,0x4004,0x4008}`; disable `apb_seq_item::c_addr` | **SVA-8**; **MON**: `pslerr==1`; **SCB**: ignore data |
| A-C02 | `apb_done_poll_timeout_test` | `apb_done_poll_seq` (short timeout) | 1. Do **not** drive `error_q` 2. Poll `0x4004` with timeout | Poll interval ≥1 cycle; timeout < full LED processing | **SCB-8** (no seg compare); test expects `Done==0` |
| A-C03 | `apb_scratchpad_all_ones_test` | `apb_wr_rd_seq` | 1. Write `0x4008 = 32'hFFFF_FFFF` 2. Read back | All bits toggled | **SCB-3** |
| A-C04 | `apb_scratchpad_walking_one_test` | `apb_wr_rd_seq` in loop | For `i` in 0..31: write `1<<i`, read back | 32 iterations | **SCB-3**; toggle coverage |
| A-C05 | `apb_enable_toggle_stress_test` | `led_mux_virtual_seq` | 1. Toggle `LED_enable` 5× 2. Each time drive new `error_q` 3. Poll Done when enabled | `error_q` distinct per iteration | **SCB-1,7**; **COV** `cg_enable` all transitions |
| A-C06 | `apb_read_during_processing_test` | `led_mux_virtual_seq` | 1. Drive `error_q` 2. Read `0x4004` **before** 60 cycles 3. Read again after poll passes | `error_q=42`; early read at cycle 10 | **SCB-2,8**; expect `Done==0` then `Done==1` |

---

## 2. LED MUX block

Binary-to-BCD conversion, multiplexing, timing, reset, and segment encoding.

### 2.1 LED — Basic function

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| L-B01 | `led_reset_values_test` | `led_reset_seq` | 1. Assert `rst_n=0` 2. Check outputs 3. Deassert reset 4. Check outputs | Sample `@(posedge clk)` after reset | **SVA-1, SVA-2** |
| L-B02 | `led_single_digit_zero_test` | `led_mux_virtual_seq` | 1. Ensure `LED_enable=1` 2. Drive `error_q=0` 3. Poll Done 4. Compare all digit positions | `error_q == 0` | **SCB-4..6**; **COV** `cg_digits` digit 0 |
| L-B03 | `led_single_digit_one_test` | `led_mux_virtual_seq` | Same as L-B02 | `error_q == 1` | **SCB-4..6**; segments for digit **1** (SPEC §4.4) |
| L-B04 | `led_decimal_42_test` | `led_mux_virtual_seq` | 1. `LED_enable=1` 2. `error_q=42` 3. Poll Done 4. Compare | `error_q == 42` | **SCB-4..6**; expect digits `0,0,0,0,4,2` |
| L-B05 | `led_max_displayable_test` | `led_mux_virtual_seq` | 1. Drive `error_q=999_999` 2. Poll Done 3. Compare each position | `error_q == 999_999` | **SCB-4..6**; all digits **9** |
| L-B06 | `led_sel_onehot_scan_test` | `led_mux_virtual_seq` | 1. Drive `error_q=74565` 2. Wait ≥1002 cycles 3. Monitor collects 6+ samples | Hold exactly 1002 cycles | **SVA-3**; **MON**: one-hot each sample; **COV** all positions |
| L-B07 | `led_seg_active_low_test` | `led_mux_virtual_seq` | 1. Drive `error_q=8` (all segments on) 2. Poll Done 3. Check `seg_out[6:0]` has 0s where lit | `error_q == 8` | **SCB-6**; **SVA-4** |
| L-B08 | `led_hold_time_min_test` | `led_error_seq` | 1. Drive `error_q` 2. Hold exactly 1002 cycles 3. Poll Done | Hold `error_q` for 1002 cycles (C-4) | **MON**: hold enforced; **SCB-4** |
| L-B09 | `led_latency_window_test` | `led_mux_virtual_seq` | 1. Drive `error_q` 2. Wait 60–80 cycles 3. Sample outputs | `error_q=100`; do not sample before 60 cycles (C-5) | **MON** defer sampling; **SCB-8** before Done |

### 2.2 LED — Corner cases

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| L-C01 | `led_overflow_modulo_test` | `led_mux_virtual_seq` | 1. `error_q=1_000_001` 2. Poll Done 3. Compare | `error_q == 1_000_001` → display `000001` | **SCB-9**; **COV** `cg_overflow` |
| L-C02 | `led_overflow_max_test` | `led_mux_virtual_seq` | 1. `error_q=1_048_575` (`20'hF_FFFF`) 2. Poll Done 3. Compare | `error_q == 20'hF_FFFF` | **SCB-9**; modulo = `48_575` |
| L-C03 | `led_overflow_boundary_test` | `led_mux_virtual_seq` | Run back-to-back: `999_999`, `1_000_000`, `1_000_001` | Three explicit values | **SCB-9**; boundary bins in **COV** |
| L-C04 | `led_disable_blocks_update_test` | `led_mux_virtual_seq` | 1. Write `LED_enable=0` 2. Drive `error_q=55` 3. Poll Done / sample `seg_out` 4. Confirm no update | `LED_enable=0` | **SCB-7**; **COV** `cg_enable` |
| L-C05 | `led_reenable_after_disable_test` | `led_mux_virtual_seq` | 1. Disable 2. Drive `error_q` (no effect) 3. Enable 4. Drive new `error_q` 5. Poll Done | Two different `error_q` values | **SCB-7**, then **SCB-4..6** |
| L-C06 | `led_back_to_back_error_test` | `led_error_burst_seq` | 1. Drive `error_q=A`, hold 1002 2. Drive `error_q=B`, hold 1002 3. Poll Done after each | `A=10`, `B=99`; hold ≥1002 each | **SCB-4**; **MON** latency restarts per change |
| L-C07 | `led_reset_during_display_test` | `led_mux_virtual_seq` + `led_reset_seq` | 1. Start display with `error_q=42` 2. Assert reset mid-hold 3. Check reset values 4. Restart test | Reset at cycle 500 of hold | **SVA-1,2**; **SCB-8** during reset |
| L-C08 | `led_done_clear_after_reset_test` | `led_mux_virtual_seq` | 1. Complete one display (`Done=1`) 2. Reset 3. Read `Done` | — | **SCB-2**; **AC-D2** |
| L-C09 | `led_hold_below_min_negative_test` | `led_error_seq` + expect fail | 1. Hold `error_q` for 1000 cycles (< C-4 min) 2. Drive `error_q` | Hold duration 1000 cycles (violates C-4) | **MON**/test expect **failure** or DUT not Done |
| L-C10 | `led_all_digits_0_to_9_test` | `led_mux_virtual_seq` in loop | For `d` in 0..9: drive `error_q=d` (or value with ones digit `d`) | 10 iterations | **SCB-5**; **SVA-10**; **COV** `cg_digits` full |

---

## 3. Integration block (APB + LED)

Cross-interface scenarios using `led_mux_virtual_seq`.

### 3.1 Integration — Basic function

| # | Test name | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|
| I-B01 | `smoke_test` | Reset → default enable → `error_q=42` → poll Done → scoreboard | `error_q=42` | Full **SCB** path; all **SVA** enabled |
| I-B02 | `full_display_flow_test` | Write enable → drive error → poll Done → read scratch → read Done | `error_q` random in `[0:999_999]` | **SCB-1..6,8** |
| I-B03 | `scratch_then_display_test` | Scratch write/read → LED display → read Done | Independent `wdata` and `error_q` | **SCB-3** + **SCB-4..6** |

### 3.2 Integration — Corner cases

| # | Test name | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|
| I-C01 | `random_regression_test` | Random order: APB wr/rd, enable toggles, random `error_q`, poll Done | `error_q` dist: in-range 80%, overflow 20%; hold ≥1002 cycles (C-4) | All **SCB**, **COV** closure target |
| I-C02 | `virtual_seq_stress_test` | 20× random virtual sequence (stretch goal Day 4) | Seed-controlled (`+ntb_random_seed`) | Regression + coverage merge |
| I-C03 | `enable_off_overflow_test` | Disable → drive overflow `error_q` → enable → drive in-range | `error_q=1_000_050` then `50` | **SCB-7,9** |
| I-C04 | `poll_until_done_stress_test` | Tight poll loop on `0x4004` while LED processes | Poll every 5 cycles | **SCB-2,8**; no false fails |

---

## 4. Constraint reference by feature

Quick lookup from **SPEC.md** when writing tests and sequences.

### 4.1 APB register feature

| Feature | Constraint | Spec ref |
|---|---|---|
| LED_enable write | `addr==16'h4000`; `wdata[0] inside {0,1}` | FR 3.4, §4.3 |
| Done read | `addr==16'h4004`; read-only | FR 3.5, C-7 |
| Scratch pad | `addr==16'h4008`; write must equal readback | FR 3.7, AC-A1 |
| Invalid access | `addr NOT IN {16'h4000, 16'h4004, 16'h4008}` | AC-A2 |
| APB protocol | Two-phase SETUP / ACCESS | C-6, AC-A3 |

### 4.2 LED display feature

| Feature | Constraint | Spec ref |
|---|---|---|
| Normal display | `0 <= error_q <= 999_999` | FR 3.1, AC-B1 |
| Overflow display | `1_000_000 <= error_q <= 20'hF_FFFF`; display = `error_q % 1_000_000` | FR 3.6, C-2, C-3, AC-B4 |
| Hold time | Hold `error_q` for ≥ 1002 simulation clock cycles | C-4, FR 3.2 |
| Output latency | Output not valid until 60–80 cycles after `error_q` changes | C-5, FR 3.2, AC-E1 |
| Multiplex scan | All 6 digit positions within 1002 cycles; `sel_out` one-hot active-low | AC-M1, AC-M2, AC-M3 |
| Reset | `sel_out==6'h3E`, `seg_out==8'h80` after reset deassert | FR 3.3, AC-R1, AC-R2 |
| Segment encoding | `seg_out[6:0]` active-low; `seg_out[7]==1` when active | FR 3.1, AC-B2, AC-B3 |
| Enable gating | `LED_enable==0` → `error_q` not propagated to `seg_out` | FR 3.4, AC-E2 |

### 4.3 Scoreboard compare gating

| Condition | Compare `seg_out`? |
|---|---|
| `Done == 0` | No (**SCB-8**) |
| `LED_enable == 0` | No (**SCB-7**) |
| `Done == 1` and `LED_enable == 1` | Yes (**SCB-4..6,9**) |
| Reset asserted | No |

---

## 5. Test → checker traceability matrix

| Test name | SCB | SVA | COV | MON |
|---|---|---|---|---|
| `apb_reset_defaults_test` | 1,2,3 | 1,2 | enable | — |
| `apb_invalid_addr_test` | — | 8 | — | pslerr |
| `led_reset_values_test` | — | 1,2 | — | — |
| `led_decimal_42_test` | 4,5,6,8 | 3,4 | digits | latency |
| `led_overflow_modulo_test` | 9 | 3,4 | overflow | — |
| `led_disable_blocks_update_test` | 7 | — | enable | — |
| `led_sel_onehot_scan_test` | 5 | 3,9 | digits | one-hot |
| `smoke_test` | all | all | all | hold+latency |
| `random_regression_test` | all | all | all | all |

---

## 6. Recommended build order

| Day | Build | Run tests |
|---|---|---|
| 1 | This testplan + ARCHITECTURE.md | — |
| 2 | Agents, drivers, monitors, `apb_*_seq`, `led_error_seq`, `smoke_test` | I-B01, A-B06, L-B04 |
| 3 | `led_scoreboard`, `led_mux_sva`, `led_coverage` | L-B01–B09, A-B01–B05 |
| 4 | `led_mux_virtual_seq`, corner tests, `random_regression_test` | All CORNER + I-C01 |
| 5 | Coverage closure, multi-seed regression | Fill **COV** holes from §0.4 |
| 6 | Annotate pass/fail + coverage in this doc for presentation | — |

---

## 7. Regression suite (minimum)

| Priority | Test name | Type | Seed |
|---|---|---|---|
| P0 | `smoke_test` | BASIC | fixed |
| P0 | `apb_reset_defaults_test` | BASIC | fixed |
| P0 | `led_decimal_42_test` | BASIC | fixed |
| P0 | `led_overflow_modulo_test` | CORNER | fixed |
| P1 | `apb_invalid_addr_test` | CORNER | fixed |
| P1 | `led_disable_blocks_update_test` | CORNER | fixed |
| P1 | `led_all_digits_0_to_9_test` | CORNER | fixed |
| P2 | `random_regression_test` | CORNER | random ×10 seeds |

---

## 8. Acceptance criteria mapping

| Spec AC | Covered by tests |
|---|---|
| AC-R1, AC-R2 | L-B01, `apb_reset_defaults_test` |
| AC-E1, AC-E2 | A-B02, L-C04, L-C05 |
| AC-B1, AC-B2, AC-B3 | L-B02–B07, L-C10 |
| AC-B4 | L-C01, L-C02, L-C03 |
| AC-M1, AC-M2, AC-M3 | L-B06, L-B08 |
| AC-D1, AC-D2 | I-B02, L-C08 |
| AC-A1 | A-B03, A-C03, A-C04 |
| AC-A2 | A-C01 |
| AC-A3 | A-B05 |
| AC-C1 | L-C10, `random_regression_test` |
| AC-C2 | All tests + §0.4 covergroups |
| AC-C3 | §0.3 SVA-1,3,4 (minimum) |

---

## 9. Generated testplan format (Excel / HVP)

Use the course template as the **authoritative output format** when submitting or annotating coverage results.

**Template file:** `LED_MUX_CONTROLLER_stu/Template-TestPlan.xlsx`  
**Companion reference:** `LED_MUX_CONTROLLER_stu/Template-TestPlan.xml` (same content, HVP-compatible)

Copy the template to a working file (e.g. `LED_MUX_CONTROLLER_testplan.xlsx`) and fill it from the test entries in §1–§3 of this document.

---

### 9.1 Sheet: `TestPlan` (primary deliverable)

This is the main HVP-style testplan grid. One row per verifiable sub-feature.

#### Column layout (row 1 = header)

| Col | Header | Fill with |
|---|---|---|
| **A** | `hvp plan` | Row 2 only: plan name (e.g. `led_mux_controller_testplan`). Leave blank on feature rows unless starting a new plan block. |
| **B** | `Feature` | Top-level block — use **`APB Controller`**, **`LED MUX`**, or **`Integration`**. Repeat on first row of each block; leave blank on continuation rows (same as template). |
| **C** | `Sub Feature` | Specific behavior under test (short phrase, not the UVM class name). |
| **D** | `$owner` | Verification owner (e.g. your name / `dv_batch7`). |
| **E** | `$description` | Numbered stimulus + check steps. Include sequence flow, constrained values, and expected result. |
| **F** | `Assertions/Cover property` | SVA assertion or cover property IDs (e.g. `SVA-1`, `SVA-3`, `cp_sel_onehot`). |
| **G** | `Covergroups` | Functional covergroup + bins (e.g. `cg_digits`, `cg_enable`). |
| **H** | `Code Coverage` | RTL code-coverage goal: `line`, `branch`, `cond`, `fsm`, `toggle` as applicable. |
| **I** | `Tests` | UVM test class name exactly as run by Makefile: `make dv TESTNAME=<Tests>`. |

#### Row rules

| Row | Rule |
|---|---|
| **1** | Header row — do not edit column titles. |
| **2** | Plan name in column **A** (`led_mux_controller_testplan`). Other columns blank. |
| **3+** | One row per sub-feature. Group by **Feature** (col B). Sub-features (col C) nest under the current feature block. |
| **Description** | Use numbered steps: `1)` stimulus, `2)` wait/poll, `3)` checker expectation. Copy sequence flow and constraints from §1–§3. |
| **Tests** | One primary test per row. If multiple tests cover the same sub-feature, either duplicate the row or list the main test and note alternates in `$description`. |

#### Feature block convention (this project)

| Feature (col B) | Maps to TESTPLAN.md |
|---|---|
| `APB Controller` | §1 — register access, protocol, enable/Done/scratch |
| `LED MUX` | §2 — display, multiplexing, timing, overflow, reset |
| `Integration` | §3 — cross-interface virtual sequences |
| `General and basic sequence` | Optional prefix for reset/smoke rows (matches template style) |
| `Corner cases` | Use as **Feature** for stress rows, or as a **Sub Feature** under APB/LED (either is acceptable; be consistent within your file) |

---

### 9.2 Sheet: `Sheet1` (per-test checklist — optional)

The template includes a second sheet with extended fields for individual test review. Use it when you need more detail than the HVP grid allows.

| Field | Fill with |
|---|---|
| **Test name** | UVM test class (`smoke_test`, `led_decimal_42_test`, …) |
| **Aim** | One-sentence goal |
| **Validation level** | `Unit`, `Sub-system`, or `SoC` — use `Sub-system` for this block-level TB |
| **Test Owner** | Same as `$owner` |
| **Description** | High-level scenario summary |
| **Test Environment Requirement** | `UVM 1.2`, `led_env`, both agents active (per ARCHITECTURE.md) |
| **Test Steps** | Copy **Sequence flow** from §1–§3 |
| **Pass/Fail Criteria** | Scoreboard pass, SVA clean, expected register values, coverage bin hit |
| **Type** | `BASIC` or `CORNER` |
| **Weight** | Priority: P0 = high, P1 = medium, P2 = low (from §7) |
| **Goal** | Spec AC IDs (e.g. `AC-R1`, `AC-B4`) |

---

### 9.3 Mapping: this document → Excel columns

| TESTPLAN.md field | Excel column |
|---|---|
| Test name (§1–§3 tables) | **Tests** (I) |
| Block (APB / LED / Integration) | **Feature** (B) |
| Scenario title / focus | **Sub Feature** (C) |
| Sequence flow | **$description** (E) — steps 1), 2), 3) |
| Constraints | **$description** (E) — under a "Constraints:" line or inline |
| SCB-* / SVA-* / MON / COV tags | **Assertions/Cover property** (F) and **Covergroups** (G) |
| Spec AC (§8) | **$description** (E) or **Sheet1 → Goal** |
| Regression priority (§7) | **Sheet1 → Weight** |

---

### 9.4 Example export rows (copy into `TestPlan` sheet)

Plan name for row 2: **`led_mux_controller_testplan`**

| Feature | Sub Feature | $owner | $description | Assertions/Cover property | Covergroups | Code Coverage | Tests |
|---|---|---|---|---|---|---|---|
| General and basic sequence | Reset values on LED interface | dv_batch7 | 1) Assert `rst_n=0`, then deassert. 2) Check `sel_out==6'h3E` and `seg_out==8'h80`. Constraints: sample on posedge clk after reset. | SVA-1, SVA-2 | — | line, toggle | `led_reset_values_test` |
| APB Controller | Reset register defaults | dv_batch7 | 1) Reset DUT. 2) APB read `0x4000` expect `LED_enable=1`. 3) Read `0x4004` expect `Done=0`. 4) Read `0x4008` expect `0`. | SVA-1, SVA-2 | cg_enable | line, branch | `apb_reset_defaults_test` |
| APB Controller | LED_enable write/read | dv_batch7 | 1) Write `0x4000=0`. 2) Read back `0`. 3) Write `0x4000=1`. 4) Read back `1`. Constraints: `wdata[0]` only. | — | cg_enable | line | `apb_led_enable_write_read_test` |
| APB Controller | Scratch pad write/read | dv_batch7 | 1) Write `0x4008=32'hDEAD_BEEF`. 2) Read `0x4008`, expect `DEAD_BEEF`. | — | — | line | `apb_scratchpad_wr_rd_test` |
| APB Controller | Invalid APB address | dv_batch7 | 1) Write to `0x5000`. 2) Check `pslerr=1`. 3) Read `0x0000`. 4) Check `pslerr=1`. Constraints: addr outside `{4000,4004,4008}`. | SVA-8 | — | branch, cond | `apb_invalid_addr_test` |
| LED MUX | Binary-to-BCD display (decimal 42) | dv_batch7 | 1) `LED_enable=1`. 2) Drive `error_q=42`, hold ≥1002 cycles. 3) Poll Done at `0x4004`. 4) Scoreboard compares each digit encoding. Constraints: C-4 (hold), C-5 (60–80 cycle latency). | SVA-3, SVA-4 | cg_digits, cg_error_q | line, fsm, toggle | `led_decimal_42_test` |
| LED MUX | Max displayable value | dv_batch7 | 1) Drive `error_q=999_999`. 2) Poll Done. 3) Expect all six digits show **9**. | SVA-3, SVA-4 | cg_digits | line | `led_max_displayable_test` |
| LED MUX | Overflow modulo | dv_batch7 | 1) Drive `error_q=1_000_001`. 2) Poll Done. 3) Expect display `000001`. Constraints: golden = `error_q % 1_000_000`. | SVA-3, SVA-4 | cg_overflow, cg_digits | line, branch | `led_overflow_modulo_test` |
| LED MUX | LED_enable disables propagation | dv_batch7 | 1) Write `LED_enable=0`. 2) Drive `error_q=55`. 3) Confirm `seg_out` does not update. Constraints: scoreboard SCB-7 gating. | — | cg_enable | cond | `led_disable_blocks_update_test` |
| LED MUX | sel_out one-hot multiplex scan | dv_batch7 | 1) Drive `error_q=74565`. 2) Hold 1002 cycles. 3) Monitor samples `sel_out` — exactly one bit low per cycle. | SVA-3, cp_sel_onehot | cg_digits | fsm, toggle | `led_sel_onehot_scan_test` |
| Corner cases | Reset recovery mid-display | dv_batch7 | 1) Start `error_q=42` display. 2) Assert reset at cycle 500. 3) Check reset values. 4) Re-run display. | SVA-1, SVA-2 | — | line | `led_reset_during_display_test` |
| Integration | End-to-end smoke | dv_batch7 | 1) Reset. 2) Default enable. 3) `error_q=42`. 4) Poll Done. 5) Scoreboard pass. | SVA-1..8 (all) | cg_error_q, cg_digits, cg_enable | all | `smoke_test` |
| Integration | Random regression | dv_batch7 | 1) Random APB + LED virtual sequence. 2) `error_q` 80% in-range, 20% overflow. 3) Coverage closure. Constraints: C-4, C-2/C-3; seed via `+ntb_random_seed`. | All SVA | All covergroups | all | `random_regression_test` |

Export **every** row from §1–§3 into this format for presentation. The table above shows the pattern; complete the file with all `A-B**`, `A-C**`, `L-B**`, `L-C**`, `I-B**`, and `I-C**` entries.

---

### 9.5 Execution annotation (post-run)

After regression (Day 5), annotate the Excel testplan for the metrics-driven loop:

| Where | What to record |
|---|---|
| **$description** (append) | `PASS` / `FAIL`, date, seed |
| **Covergroups** (G) | Hit percentage or `CLOSED` / `OPEN` |
| **Code Coverage** (H) | Merged code-coverage % from VCS/Verdi |
| **Sheet1 → Goal** | Link to spec AC status |

---

*Update the **Run** / **Pass** / **Coverage** columns during execution (Day 5) to complete the metrics-driven loop.*
