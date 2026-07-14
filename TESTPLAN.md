# TESTPLAN: LED MUX Controller — UVM Verification

**Source spec:** SPEC.md (PSDC_UVM_FINAL_PROJECT_DV_BATCH7.pdf, PCDA2025 Rev1.0)  
**Architecture:** ARCHITECTURE.md  
**Methodology:** UVM 1.2, metrics-driven verification

This testplan is the build checklist. **Start with §1 P0 essential tests (11)**; add P1 good-to-have and P2 stretch only after P0 passes.

## Phase status (as of 2026-07-12, regress_202607121440)

| Phase | Tests | PASS | FAIL | UNKNOWN | Notes |
|---|---|---|---|---|---|
| P0 | 10 | 6 | 4 | 0 | Failures all known DUT bugs |
| P1 | 9 | 2 | 7 | 0 | All implemented and run |
| P2 | 18 | — | — | 18 | Not yet implemented |

**Testplan coverage score: 67.54%** | TOGGLE: 23.09% | Groups avg: 86.06%

### P0 gate results

| Test | Result | Root cause |
|---|---|---|
| `led_reset_values_test` | PASS | — |
| `apb_reset_defaults_test` | FAIL | BUG-001 (LED_enable reads 0 after reset) |
| `apb_pready_no_wait_test` | PASS | — |
| `apb_led_enable_write_read_test` | PASS | — |
| `apb_scratchpad_wr_rd_test` | PASS | — |
| `apb_invalid_addr_test` | PASS | — |
| `led_decimal_42_test` | FAIL | BUG-004 (digit 2 wrong encoding) |
| `led_overflow_modulo_test` | FAIL | BUG-004 + BUG-006 |
| `led_disable_blocks_update_test` | PASS | — |
| `led_all_digits_0_to_9_test` | FAIL | BUG-004, BUG-005 |

### P1 gate results

| Test | Result | Root cause |
|---|---|---|
| `apb_default_enable_led_path_test` | FAIL | BUG-001 |
| `led_reenable_after_disable_test` | FAIL | BUG-004 |
| `led_max_displayable_test` | FAIL | BUG-007 (bin2bcd truncation) |
| `led_sel_onehot_scan_test` | FAIL | BUG-005 + encoding errors |
| `led_hold_time_min_test` | **PASS** | — |
| `led_latency_window_test` | **PASS** | — |
| `full_display_flow_test` | FAIL | BUG-004 |
| `apb_read_during_processing_test` | FAIL | BUG-004 |
| `random_regression_test` | FAIL | BUG-004 + BUG-005 |

### Remaining coverage gaps (after P0+P1)

| Covergroup | Score | Missing bins |
|---|---|---|
| `cg_error_q` | 62.50% | `b99`, `b1_000_000`, `b1_048_575` |
| `cg_enable` | 83.33% | `default_at_reset` (blocked by BUG-001) |
| `cg_digits` cross | 53.33% | 28/60 cross bins (all 6 pos × all 10 val combos not seen) |
| `cg_overflow` | 100.00% | — |
| `cg_done` | 100.00% | — |

### P2 implementation priority (coverage-driven)

Implement in this order:

| Priority | ID | Test | Coverage target |
|---|---|---|---|
| 1 | S10 | `led_overflow_boundary_test` | `b99`, `b1_000_000` in `cg_error_q`; high-position cross bins |
| 2 | S09 | `led_overflow_max_test` | `b1_048_575` in `cg_error_q`; `Overflow_maximum_error_q` HVP |
| 3 | S06 | `led_single_digit_zero_test` | Cross `(pos5, val0)`; `Single_digit_zero_display` HVP |
| 4 | S07 | `led_single_digit_one_test` | Cross `(pos5, val1)`; `Single_digit_one_display` HVP |
| 5 | S08 | `led_seg_active_low_test` | `seg_out_active_low_encoding` HVP |
| 6 | S11 | `led_back_to_back_error_test` | `Back_to_back_error_q_changes` HVP |
| 7 | S17 | `enable_off_overflow_test` | `Disable_then_overflow_then_enable` HVP |
| 8+ | S01–S05, S12–S16, S18 | Stress/redundancy | Implement last if time permits |

---

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
| `SVA` | SystemVerilog assertion or cover property in `led_mux_sva` (use **snake_case** names from §0.3) |
| `SCB` | `led_scoreboard` check |
| `MON` | Monitor or driver protocol enforcement |
| `COV` | `led_coverage` covergroup / coverpoint / cross |
| `P0` | **Essential** — must implement; blocks spec sign-off |
| `P1` | **Good to have** — closes coverage gaps; add after P0 passes |
| `P2` | **Stretch** — stress / redundant; optional before presentation |

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

All assertions and cover properties use **meaningful `snake_case` names** (no numeric IDs like `SVA-1`). Names are the identifier in SystemVerilog, the testplan **Assertions/Cover property** column, and regression logs.

#### Naming convention

| Prefix | Use for | Example |
|---|---|---|
| `assert_` | Immediate assertion (must never fail) | `assert_sel_out_onehot_active_low` |
| `cover_` | Cover property (observability / coverage) | `cover_sel_out_digit_position` |
| `check_` | Timing or behavioral rule (often bound with latency parameters) | `check_60_80_cycle` |

Rules:

- Lowercase only; words separated by `_`
- Name describes **what** is checked, not ticket numbers
- Tie names to SPEC constraints where applicable (e.g. `check_60_80_cycle` → C-5)
- One property per row in the table below

#### Property list

| Name | Type | Assertion / cover | Signals | Spec ref |
|---|---|---|---|---|
| `assert_sel_out_reset_value` | assert | After reset deassert: `sel_out == 6'h3E` | `rst_n`, `sel_out` | AC-R1 |
| `assert_seg_out_reset_value` | assert | After reset deassert: `seg_out == 8'h80` | `rst_n`, `seg_out` | AC-R2 |
| `assert_sel_out_onehot_active_low` | assert | `sel_out` one-hot active-low during normal op | `sel_out`, `rst_n` | AC-M1 |
| `assert_seg_out_bit7_always_one` | assert | `seg_out[7] == 1` when any segment active | `seg_out` | AC-B2 |
| `assert_apb_setup_phase` | assert | APB SETUP: `psel==1`, `penable==0` | `apb_if` | C-6 |
| `assert_apb_access_phase` | assert | APB ACCESS: `psel==1`, `penable==1` | `apb_if` | C-6 |
| `assert_apb_pready_complete` | assert | `o_pready` high on completing transfer | `apb_if` | AC-A3 |
| `assert_apb_pslerr_invalid_addr` | assert | `o_pslerr` on invalid address | `apb_if` | AC-A2 |
| `cover_sel_out_digit_position` | cover | Each digit position 0–5 selected on `sel_out` | `sel_out` | AC-C1 |
| `cover_seg_out_decimal_digit` | cover | Each decimal digit 0–9 displayed on `seg_out` | `seg_out`, `sel_out` | AC-C1 |
| `check_60_80_cycle` | check | Output not valid until 60–80 cycles after `error_q` changes | `error_q`, `seg_out`, `clk` | C-5, AC-E1 |
| `check_hold_1002_cycle` | check | `error_q` held for ≥ 1002 simulation cycles per refresh | `error_q`, `clk` | C-4, AC-M2 |

### 0.4 Functional coverage (`led_coverage`) — build checklist

Implement **one** `led_coverage` component (UVM subscriber or analysis-imp fan-in). Add **covergroups**, **coverpoints**, and **crosses** incrementally when the **first** P0/P1 test that needs them is built — same rule as SCB/SVA. Do not create unused coverpoints ahead of the feature that samples them.

#### Naming convention

| Kind | Prefix / form | Example |
|---|---|---|
| Covergroup | `cg_<feature>` | `cg_enable`, `cg_digits` |
| Coverpoint | `cp_<signal_or_aspect>` | `cp_led_enable`, `cp_digit_pos` |
| Cross | `cx_<a>_x_<b>` | `cx_digit_pos_x_digit_val` |

#### Covergroup inventory (coverpoints + crosses)

| Covergroup | Coverpoints | Crosses | Sample when | Spec / AC |
|---|---|---|---|---|
| `cg_enable` | `cp_led_enable` `{bin_off, bin_on}`; `cp_enable_trans` `{off_to_on, on_to_off, default_at_reset}` | — | APB write/read `0x4000`; reset defaults | AC-E1, AC-E2 |
| `cg_done` | `cp_done` `{bin_0, bin_1}`; `cp_poll_before_done` `{polled_while_0}` | — | APB read `0x4004` / Done poll | AC-D1, AC-D2 |
| `cg_error_q` | `cp_error_q` bins: `0`, `1`, `9`, `99`, `999_999`, `1_000_000`, `1_048_575`, `mid_range` (illegal / auto) | — | LED `error_q` drive | AC-B1, AC-B4 |
| `cg_overflow` | `cp_range` `{in_range (<=999_999), overflow (>999_999)}` | — | LED overflow / max tests | AC-B4 |
| `cg_digits` | `cp_digit_pos` `{0..5}`; `cp_digit_val` `{0..9}` | **`cx_digit_pos_x_digit_val`** = `cp_digit_pos × cp_digit_val` | After `Done==1`, per digit sample | AC-C1, AC-B1 |
| `cg_apb_addr` *(optional P1)* | `cp_apb_addr` `{enable, done, scratch, invalid}` | — | APB address decode | AC-A1, AC-A2 |

#### Feature → coverage map (add when working that feature)

| Feature set | First test that needs COV | Add to `led_coverage` |
|---|---|---|
| Reset / defaults | E02 `apb_reset_defaults_test` | `cg_enable.cp_enable_trans` bin `default_at_reset`; `cg_done.cp_done` bin `bin_0` |
| LED_enable RW | E03 `apb_led_enable_write_read_test` | `cg_enable` coverpoints (`cp_led_enable`, `cp_enable_trans`) |
| Disable gating | E10 `led_disable_blocks_update_test` | Hit `cg_enable` `bin_off` / `on_to_off` |
| Display / BCD | E08 `led_decimal_42_test` | `cg_error_q` (bin for 42 / mid); start `cg_digits` coverpoints |
| Overflow | E09 `led_overflow_modulo_test` | `cg_overflow`; `cg_error_q` overflow bins |
| All digits 0–9 | E11 `led_all_digits_0_to_9_test` | Complete `cg_digits` + **cross** `cx_digit_pos_x_digit_val` |
| Integration smoke | E01 `smoke_test` | Sample all existing covergroups end-to-end |
| Coverage closure | G09 `random_regression_test` | Close remaining bins / crosses (P1) |

#### Implementation rules

1. **One class** — `led_coverage` only; no per-test covergroup classes.
2. **Incremental** — create the covergroup shell when the first feature needs it; add coverpoints/crosses on later features that require them.
3. **Crosses** — require both coverpoints to exist first; add `cx_*` when the feature needs correlation (e.g. digit position × digit value for E11).
4. **Sample source** — sample from APB and/or LED analysis transactions (or scoreboard mirror), not from ad-hoc test `$display`s.
5. **Env hook** — instantiate once in `led_env`; connect monitor analysis ports (or fan-out from scoreboard) in `connect_phase`.
6. **Excel** — put covergroup names in the **Covergroups** column; crosses count as functional coverage for AC-C2.

#### Minimal covergroup sketch

```systemverilog
covergroup cg_digits;
  cp_digit_pos: coverpoint digit_pos { bins pos[] = {[0:5]}; }
  cp_digit_val: coverpoint digit_val { bins val[] = {[0:9]}; }
  cx_digit_pos_x_digit_val: cross cp_digit_pos, cp_digit_val;
endgroup
```

---

## 1. Test priority summary

38 tests were identified; **11 are essential (P0)** for spec sign-off. Implement P0 first, then P1 for coverage closure, then P2 if time allows.

### 1.1 Essential — P0 (implement first)

| # | Test name | Block | Spec AC closed |
|---|---|---|---|
| E01 | `smoke_test` | Integration | End-to-end sanity; all checkers exercised |
| E02 | `apb_reset_defaults_test` | APB | AC-R1, AC-R2 (register defaults after reset) |
| E03 | `apb_led_enable_write_read_test` | APB | AC-E1, AC-E2 (`LED_enable` write/read) |
| E04 | `apb_scratchpad_wr_rd_test` | APB | AC-A1 (scratch pad) |
| E05 | `apb_invalid_addr_test` | APB | AC-A2 (`pslerr` on bad address) |
| E06 | `apb_pready_no_wait_test` | APB | AC-A3, C-6 (APB 2-phase / pready) |
| E07 | `led_reset_values_test` | LED | AC-R1, AC-R2 (`sel_out` / `seg_out` at reset) |
| E08 | `led_decimal_42_test` | LED | AC-B1, AC-D1, AC-M1 (BCD + Done + one-hot) |
| E09 | `led_overflow_modulo_test` | LED | AC-B4 (overflow `error_q % 1_000_000`) |
| E10 | `led_disable_blocks_update_test` | LED | AC-E2 (`LED_enable=0` blocks update) |
| E11 | `led_all_digits_0_to_9_test` | LED | AC-C1, AC-B1 (all segment encodings 0–9) |

**P0 regression (run every build):** E01–E11.

### 1.2 Good to have — P1 (add after P0 passes)

| # | Test name | Block | Why add it |
|---|---|---|---|
| G01 | `apb_default_enable_led_path_test` | APB | Proves power-on `LED_enable=1` without APB write |
| G02 | `apb_read_during_processing_test` | APB | `Done` before/after latency; exercises `check_60_80_cycle` |
| G03 | `led_max_displayable_test` | LED | Upper in-range boundary `error_q=999_999` |
| G04 | `led_sel_onehot_scan_test` | LED | Explicit multiplex scan AC-M2, AC-M3 |
| G05 | `led_hold_time_min_test` | LED | Explicit C-4 hold (1002 cycles) |
| G06 | `led_latency_window_test` | LED | Explicit C-5 sampling window |
| G07 | `led_reenable_after_disable_test` | LED | Disable → enable recovery sequence |
| G08 | `full_display_flow_test` | Integration | APB + LED + scratch pad in one flow |
| G09 | `random_regression_test` | Integration | Coverage closure; multi-seed (×10) |

### 1.3 Stretch — P2 (optional)

| # | Test name | Block | Notes |
|---|---|---|---|
| S01 | `apb_done_read_only_test` | APB | RO `Done` write attempt |
| S02 | `apb_done_poll_timeout_test` | APB | `Done==0` without `error_q` |
| S03 | `apb_scratchpad_all_ones_test` | APB | Bit-pattern stress |
| S04 | `apb_scratchpad_walking_one_test` | APB | 32-step walking-one |
| S05 | `apb_enable_toggle_stress_test` | APB | Rapid `LED_enable` toggle |
| S06 | `led_single_digit_zero_test` | LED | Redundant with E08/E11 |
| S07 | `led_single_digit_one_test` | LED | Redundant with E08/E11 |
| S08 | `led_seg_active_low_test` | LED | Partial AC-B3; covered by scoreboard in E08 |
| S09 | `led_overflow_max_test` | LED | Max `error_q` corner |
| S10 | `led_overflow_boundary_test` | LED | 999_999 / 1_000_000 / 1_000_001 sweep |
| S11 | `led_back_to_back_error_test` | LED | Consecutive `error_q` updates |
| S12 | `led_reset_during_display_test` | LED | Reset mid-hold recovery |
| S13 | `led_done_clear_after_reset_test` | LED | AC-D2 explicit |
| S14 | `led_hold_below_min_negative_test` | LED | Negative test (violates C-4) |
| S15 | `scratch_then_display_test` | Integration | Scratch + display ordering |
| S16 | `virtual_seq_stress_test` | Integration | 20× random virtual sequence |
| S17 | `enable_off_overflow_test` | Integration | Enable gating + overflow combo |
| S18 | `poll_until_done_stress_test` | Integration | Tight `Done` poll loop |

---

## 2. Essential tests — detail (P0)

Full sequence, constraint, and checker detail for each **essential** test only. See §3–§4 for P1/P2 summaries.

### 2.1 APB — Essential

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| E02 | `apb_reset_defaults_test` | `led_reset_seq` → `apb_read_seq` ×3 | 1. Reset DUT 2. Read `0x4000` (expect `LED_enable=1`) 3. Read `0x4004` (expect `Done=0`) 4. Read `0x4008` (expect `0`) | No APB traffic during reset assert | **SCB-1, SCB-2, SCB-3**; **assert_sel_out_reset_value, assert_seg_out_reset_value**; **COV** `cg_enable` (`default_at_reset`), `cg_done` (`bin_0`) |
| E03 | `apb_led_enable_write_read_test` | `apb_wr_rd_seq` | 1. Write `0x4000 = 0` 2. Read `0x4000` 3. Write `0x4000 = 1` 4. Read `0x4000` | `wdata[0]` only (FR 3.4) | **SCB-1**; **COV** `cg_enable` (`cp_led_enable`, `cp_enable_trans`) |
| E04 | `apb_scratchpad_wr_rd_test` | `apb_wr_rd_seq` | 1. Write `0x4008 = 32'hDEAD_BEEF` 2. Read `0x4008` | Full 32-bit `wdata` | **SCB-3** |
| E05 | `apb_invalid_addr_test` | `apb_invalid_addr_seq` | 1. Write `0x5000` 2. Check `pslerr` 3. Read `0x0000` 4. Check `pslerr` | Addr outside `{0x4000,0x4004,0x4008}` | **assert_apb_pslerr_invalid_addr**; **MON** `pslerr==1` |
| E06 | `apb_pready_no_wait_test` | `apb_write_seq` + `apb_read_seq` | 1. Write `0x4000` 2. Read `0x4004` | Standard 2-phase APB (C-6) | **assert_apb_setup_phase, assert_apb_access_phase, assert_apb_pready_complete** |

### 2.2 LED — Essential

| # | Test name | Virtual / child sequences | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|---|
| E07 | `led_reset_values_test` | `led_reset_seq` | 1. Assert `rst_n=0` 2. Check outputs 3. Deassert reset 4. Check outputs | Sample after reset (FR 3.3) | **assert_sel_out_reset_value, assert_seg_out_reset_value** |
| E08 | `led_decimal_42_test` | `led_mux_virtual_seq` | 1. `LED_enable=1` 2. `error_q=42` 3. Poll Done 4. Compare digits `0,0,0,0,4,2` | C-4 hold ≥1002; C-5 latency | **SCB-4..6, SCB-8**; **assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one, check_60_80_cycle**; **COV** `cg_error_q`, `cg_digits` (`cp_digit_pos`, `cp_digit_val`) |
| E09 | `led_overflow_modulo_test` | `led_mux_virtual_seq` | 1. `error_q=1_000_001` 2. Poll Done 3. Expect display `000001` | Golden = `error_q % 1_000_000` | **SCB-9**; **COV** `cg_overflow`, `cg_error_q` overflow bins |
| E10 | `led_disable_blocks_update_test` | `led_mux_virtual_seq` | 1. Write `LED_enable=0` 2. Drive `error_q=55` 3. Confirm no `seg_out` update | `LED_enable=0` (FR 3.4) | **SCB-7**; **COV** `cg_enable` (`bin_off`, `on_to_off`) |
| E11 | `led_all_digits_0_to_9_test` | `led_mux_virtual_seq` loop | For `d` in 0..9: drive value with ones digit `d`; poll Done; compare encoding | 10 iterations | **SCB-5**; **cover_seg_out_decimal_digit**; **COV** `cg_digits` + cross **`cx_digit_pos_x_digit_val`** |

### 2.3 Integration — Essential

| # | Test name | Sequence flow | Constraints | Checkers |
|---|---|---|---|---|
| E01 | `smoke_test` | Reset → default enable → `error_q=42` → poll Done → scoreboard | `error_q=42` | Full **SCB**; all §0.3 **assert_** / **cover_** / **check_** properties; **COV** all covergroups sampled |

---

## 3. Good-to-have tests — detail (P1)

| # | Test name | Sequence flow (summary) | Constraints | Checkers |
|---|---|---|---|---|
| G01 | `apb_default_enable_led_path_test` | No write `0x4000` → drive `error_q=7` → poll Done → compare | Default `LED_enable=1` | **SCB-1, SCB-4..6, SCB-8**; **assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one** |
| G02 | `apb_read_during_processing_test` | Drive `error_q=42` → read `Done` at cycle 10 → poll after latency | C-5 early read | **SCB-2, SCB-8**; **check_60_80_cycle** |
| G03 | `led_max_displayable_test` | Drive `error_q=999_999` → poll Done → all digits **9** | In-range max | **SCB-4..6** |
| G04 | `led_sel_onehot_scan_test` | Drive `error_q=74565` → hold 1002 → sample `sel_out` one-hot | C-4 | **assert_sel_out_onehot_active_low, cover_sel_out_digit_position** |
| G05 | `led_hold_time_min_test` | Drive `error_q` → hold exactly 1002 → poll Done | C-4 | **check_hold_1002_cycle**; **SCB-4** |
| G06 | `led_latency_window_test` | Drive `error_q=100` → wait 60–80 cycles → sample | C-5 | **check_60_80_cycle**; **SCB-8** |
| G07 | `led_reenable_after_disable_test` | Disable → drive (no effect) → enable → drive new value → poll Done | Two `error_q` values | **SCB-7**, then **SCB-4..6** |
| G08 | `full_display_flow_test` | Enable → random `error_q` → poll Done → read scratch → read Done | `error_q` in `[0:999_999]` | **SCB-1..6, SCB-8** |
| G09 | `random_regression_test` | Random APB + LED virtual sequence; 80% in-range / 20% overflow | C-4; multi-seed | All **SCB**, all §0.3 properties, **COV** (close remaining coverpoints / crosses) |

---

## 4. Stretch tests (P2)

Optional — implement only if P0 and P1 are green and time remains. See §1.3 for the full list. These tests add stress, redundancy, or negative scenarios; they do not block initial sign-off.

---

## 5. Full test catalogue (reference)

All 38 tests with priority rank. Implement **P0** first (§2), then **P1** (§3), then **P2** (§4).

| Rank | ID | Test name | Block | Type |
|---|---|---|---|---|
| P0 | E01 | `smoke_test` | Integration | BASIC |
| P0 | E02 | `apb_reset_defaults_test` | APB | BASIC |
| P0 | E03 | `apb_led_enable_write_read_test` | APB | BASIC |
| P0 | E04 | `apb_scratchpad_wr_rd_test` | APB | BASIC |
| P0 | E05 | `apb_invalid_addr_test` | APB | CORNER |
| P0 | E06 | `apb_pready_no_wait_test` | APB | BASIC |
| P0 | E07 | `led_reset_values_test` | LED | BASIC |
| P0 | E08 | `led_decimal_42_test` | LED | BASIC |
| P0 | E09 | `led_overflow_modulo_test` | LED | CORNER |
| P0 | E10 | `led_disable_blocks_update_test` | LED | CORNER |
| P0 | E11 | `led_all_digits_0_to_9_test` | LED | CORNER |
| P1 | G01 | `apb_default_enable_led_path_test` | APB | BASIC |
| P1 | G02 | `apb_read_during_processing_test` | APB | CORNER |
| P1 | G03 | `led_max_displayable_test` | LED | BASIC |
| P1 | G04 | `led_sel_onehot_scan_test` | LED | BASIC |
| P1 | G05 | `led_hold_time_min_test` | LED | BASIC |
| P1 | G06 | `led_latency_window_test` | LED | BASIC |
| P1 | G07 | `led_reenable_after_disable_test` | LED | CORNER |
| P1 | G08 | `full_display_flow_test` | Integration | BASIC |
| P1 | G09 | `random_regression_test` | Integration | CORNER |
| P2 | S01 | `apb_done_read_only_test` | APB | BASIC |
| P2 | S02 | `apb_done_poll_timeout_test` | APB | CORNER |
| P2 | S03 | `apb_scratchpad_all_ones_test` | APB | CORNER |
| P2 | S04 | `apb_scratchpad_walking_one_test` | APB | CORNER |
| P2 | S05 | `apb_enable_toggle_stress_test` | APB | CORNER |
| P2 | S06 | `led_single_digit_zero_test` | LED | BASIC |
| P2 | S07 | `led_single_digit_one_test` | LED | BASIC |
| P2 | S08 | `led_seg_active_low_test` | LED | BASIC |
| P2 | S09 | `led_overflow_max_test` | LED | CORNER |
| P2 | S10 | `led_overflow_boundary_test` | LED | CORNER |
| P2 | S11 | `led_back_to_back_error_test` | LED | CORNER |
| P2 | S12 | `led_reset_during_display_test` | LED | CORNER |
| P2 | S13 | `led_done_clear_after_reset_test` | LED | CORNER |
| P2 | S14 | `led_hold_below_min_negative_test` | LED | CORNER |
| P2 | S15 | `scratch_then_display_test` | Integration | BASIC |
| P2 | S16 | `virtual_seq_stress_test` | Integration | CORNER |
| P2 | S17 | `enable_off_overflow_test` | Integration | CORNER |
| P2 | S18 | `poll_until_done_stress_test` | Integration | CORNER |

---

## 6. Constraint reference by feature

Quick lookup from **SPEC.md** when writing tests and sequences.

### 6.1 APB register feature

| Feature | Constraint | Spec ref |
|---|---|---|
| LED_enable write | `addr==16'h4000`; `wdata[0] inside {0,1}` | FR 3.4, §4.3 |
| Done read | `addr==16'h4004`; read-only | FR 3.5, C-7 |
| Scratch pad | `addr==16'h4008`; write must equal readback | FR 3.7, AC-A1 |
| Invalid access | `addr NOT IN {16'h4000, 16'h4004, 16'h4008}` | AC-A2 |
| APB protocol | Two-phase SETUP / ACCESS | C-6, AC-A3 |

### 6.2 LED display feature

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

### 6.3 Scoreboard compare gating

| Condition | Compare `seg_out`? |
|---|---|
| `Done == 0` | No (**SCB-8**) |
| `LED_enable == 0` | No (**SCB-7**) |
| `Done == 1` and `LED_enable == 1` | Yes (**SCB-4..6,9**) |
| Reset asserted | No |

---

## 7. Test → checker traceability (P0 only)

| Test name | SCB | SVA / check properties | COV (covergroup / coverpoint / cross) | MON |
|---|---|---|---|---|
| `apb_reset_defaults_test` | 1,2,3 | assert_sel_out_reset_value, assert_seg_out_reset_value | `cg_enable.default_at_reset`, `cg_done.bin_0` | — |
| `apb_led_enable_write_read_test` | 1 | — | `cg_enable` (`cp_led_enable`, `cp_enable_trans`) | — |
| `apb_invalid_addr_test` | — | assert_apb_pslerr_invalid_addr | — | pslerr |
| `led_reset_values_test` | — | assert_sel_out_reset_value, assert_seg_out_reset_value | — | — |
| `led_decimal_42_test` | 4,5,6,8 | assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one, check_60_80_cycle | `cg_error_q`, `cg_digits` coverpoints | latency |
| `led_overflow_modulo_test` | 9 | assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one | `cg_overflow`, `cg_error_q` overflow bins | — |
| `led_disable_blocks_update_test` | 7 | — | `cg_enable` (`bin_off`, `on_to_off`) | — |
| `led_all_digits_0_to_9_test` | 5 | cover_seg_out_decimal_digit | `cg_digits` + **`cx_digit_pos_x_digit_val`** | — |
| `led_sel_onehot_scan_test` | 5 | assert_sel_out_onehot_active_low, cover_sel_out_digit_position | `cg_digits` | one-hot |
| `led_latency_window_test` | 8 | check_60_80_cycle | — | defer sample |
| `led_hold_time_min_test` | 4 | check_hold_1002_cycle | — | hold |
| `smoke_test` | all | all §0.3 properties | all covergroups | hold+latency |
| `random_regression_test` | all | all §0.3 properties | all (closure of coverpoints / crosses) | all |

---

## 8. Recommended build order

| Day | Build | Run tests |
|---|---|---|
| 1 | This testplan + ARCHITECTURE.md | — |
| 2 | Agents, drivers, monitors, `apb_*_seq`, `led_error_seq`, `smoke_test` | **P0:** E01, E08 |
| 3 | `led_scoreboard`, `led_mux_sva`, `led_coverage` | **P0:** E02–E07, E09–E11 |
| 4 | `led_mux_virtual_seq`, P1 tests | **P1:** G01–G09 |
| 5 | Coverage closure, multi-seed `random_regression_test` | **P1:** G09 ×10 seeds |
| 6 | P2 stretch (optional); annotate results | **P2** as time allows |

---

## 9. Regression suite

| Rank | Test name | Type | Seed | When to run |
|---|---|---|---|---|
| P0 | `smoke_test` | BASIC | fixed | Every build |
| P0 | `apb_reset_defaults_test` | BASIC | fixed | Every build |
| P0 | `apb_led_enable_write_read_test` | BASIC | fixed | Every build |
| P0 | `apb_scratchpad_wr_rd_test` | BASIC | fixed | Every build |
| P0 | `apb_invalid_addr_test` | CORNER | fixed | Every build |
| P0 | `apb_pready_no_wait_test` | BASIC | fixed | Every build |
| P0 | `led_reset_values_test` | BASIC | fixed | Every build |
| P0 | `led_decimal_42_test` | BASIC | fixed | Every build |
| P0 | `led_overflow_modulo_test` | CORNER | fixed | Every build |
| P0 | `led_disable_blocks_update_test` | CORNER | fixed | Every build |
| P0 | `led_all_digits_0_to_9_test` | CORNER | fixed | Nightly |
| P1 | `random_regression_test` | CORNER | random ×10 | Coverage closure |
| P1 | `led_sel_onehot_scan_test` | BASIC | fixed | After P0 green |
| P1 | `led_hold_time_min_test` | BASIC | fixed | After P0 green |
| P1 | `led_latency_window_test` | BASIC | fixed | After P0 green |

---

## 10. Acceptance criteria mapping

| Spec AC | Covered by (minimum = P0) |
|---|---|
| AC-R1, AC-R2 | E02, E07 |
| AC-E1, AC-E2 | E03, E10 (+ G07 P1 for re-enable) |
| AC-B1, AC-B2, AC-B3 | E08, E11 (+ G03 P1 for max value) |
| AC-B4 | E09 |
| AC-M1, AC-M2, AC-M3 | E08 (+ G04, G05 P1 for explicit timing/scan) |
| AC-D1, AC-D2 | E01, E08 (+ S13 P2 for Done-after-reset) |
| AC-A1 | E04 |
| AC-A2 | E05 |
| AC-A3 | E06 |
| AC-C1 | E11 (+ G09 P1 for random closure) |
| AC-C2 | P0 tests + §0.4 covergroups; close gaps with G09 |
| AC-C3 | §0.3 minimum: `assert_sel_out_reset_value`, `assert_sel_out_onehot_active_low`, `assert_seg_out_bit7_always_one` |

---

## 11. Generated testplan format (Excel / HVP)

Use the course template as the **authoritative output format** when submitting or annotating coverage results.

**Template file:** `LED_MUX_CONTROLLER_stu/Template-TestPlan.xlsx`  
**Companion reference:** `LED_MUX_CONTROLLER_stu/Template-TestPlan.xml` (same content, HVP-compatible)

Copy the template to a working file (e.g. `LED_MUX_CONTROLLER_testplan.xlsx`) and fill **P0 tests first**, then P1. See **§11.6** to generate.

**Generate the Excel file** using the project script (see **§11.6**).

---

### 11.1 Sheet: `TestPlan` (primary deliverable)

This is the main HVP-style testplan grid. One row per verifiable sub-feature.

#### Column layout (row 1 = header)

| Col | Header | Fill with |
|---|---|---|
| **A** | `hvp plan` | Row 2 only: plan name (e.g. `led_mux_controller_testplan`). Leave blank on feature rows unless starting a new plan block. |
| **B** | `Feature` | Top-level block — use **`APB Controller`**, **`LED MUX`**, or **`Integration`**. Repeat on first row of each block; leave blank on continuation rows (same as template). |
| **C** | `Sub Feature` | Specific behavior under test (short phrase, not the UVM class name). |
| **D** | `$owner` | Verification owner — **your name** (prompted at generation time; see §11.6) |
| **E** | `$description` | Numbered stimulus + check steps. Include sequence flow, constrained values, and expected result. |
| **F** | `Assertions/Cover property` | Named SVA properties from §0.3 (e.g. `assert_sel_out_onehot_active_low`, `check_60_80_cycle`) |
| **G** | `Covergroups` | Functional covergroup + bins (e.g. `cg_digits`, `cg_enable`). |
| **H** | `Code Coverage` | RTL code-coverage goal: `line`, `branch`, `cond`, `fsm`, `toggle` as applicable. |
| **I** | `Tests` | UVM test class name exactly as run by Makefile: `make dv TESTNAME=<Tests>`. |
| **J** | `Priority` | Test rank from §1: **`P0`** (essential), **`P1`** (good to have), **`P2`** (stretch). |

#### Row rules

| Row | Rule |
|---|---|
| **1** | Header row — do not edit column titles. |
| **2** | Plan name in column **A** (`led_mux_controller_testplan`). Other columns blank. |
| **3+** | One row per sub-feature. Group by **Feature** (col B). Sub-features (col C) nest under the current feature block. |
| **Description** | Use numbered steps: `1)` stimulus, `2)` wait/poll, `3)` checker expectation. One step per line; no orphan `.` lines (see §11.6). |
| **Tests** | One primary test per row. If multiple tests cover the same sub-feature, either duplicate the row or list the main test and note alternates in `$description`. |

#### Feature block convention (this project)

| Feature (col B) | Maps to TESTPLAN.md |
|---|---|
| `APB Controller` | §2 / §5 — APB tests |
| `LED MUX` | §2 / §5 — LED tests |
| `Integration` | §2 / §5 — cross-interface tests |

---

### 11.2 Sheet: `Sheet1` (per-test checklist — optional)

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
| **Weight** | Rank: **P0** (essential), **P1** (good to have), **P2** (stretch) — from §1 |
| **Goal** | Spec AC IDs (e.g. `AC-R1`, `AC-B4`) |

---

### 11.3 Mapping: this document → Excel columns

| TESTPLAN.md field | Excel column |
|---|---|
| Test name (§2–§3) | **Tests** (I) |
| Rank (§1) | **Priority** (J) — `P0` / `P1` / `P2` |
| Block (APB / LED / Integration) | **Feature** (B) |
| Scenario title / focus | **Sub Feature** (C) |
| Sequence flow | **$description** (E) — steps 1), 2), 3) |
| Constraints | **$description** (E) — under a "Constraints:" line or inline |
| SCB-* / SVA / MON / COV tags | **Assertions/Cover property** (F) and **Covergroups** (G) — use §0.3 **names**, not numeric IDs |
| Spec AC (§8) | **$description** (E) or **Sheet1 → Goal** |
| Regression priority (§9) | **Sheet1 → Weight** (P0 / P1 / P2) |

---

### 11.4 Example export rows (P0 only)

Plan name for row 2: **`led_mux_controller_testplan`**

| Feature | Sub Feature | $owner | $description | Assertions/Cover property | Covergroups | Code Coverage | Tests |
|---|---|---|---|---|---|---|---|
| General and basic sequence | Reset values on LED interface | slpoh | 1) Assert `rst_n=0`, then deassert. 2) Check `sel_out==6'h3E` and `seg_out==8'h80`. Constraints: sample on posedge clk after reset. | assert_sel_out_reset_value, assert_seg_out_reset_value | — | line, toggle | `led_reset_values_test` |
| APB Controller | Reset register defaults | slpoh | 1) Reset DUT. 2) APB read `0x4000` expect `LED_enable=1`. 3) Read `0x4004` expect `Done=0`. 4) Read `0x4008` expect `0`. | assert_sel_out_reset_value, assert_seg_out_reset_value | cg_enable | line, branch | `apb_reset_defaults_test` |
| APB Controller | LED_enable write/read | slpoh | 1) Write `0x4000=0`. 2) Read back `0`. 3) Write `0x4000=1`. 4) Read back `1`. Constraints: `wdata[0]` only. | — | cg_enable | line | `apb_led_enable_write_read_test` |
| APB Controller | Scratch pad write/read | slpoh | 1) Write `0x4008=32'hDEAD_BEEF`. 2) Read `0x4008`, expect `DEAD_BEEF`. | — | — | line | `apb_scratchpad_wr_rd_test` |
| APB Controller | Invalid APB address | slpoh | 1) Write to `0x5000`. 2) Check `pslerr=1`. 3) Read `0x0000`. 4) Check `pslerr=1`. Constraints: addr outside `{4000,4004,4008}`. | assert_apb_pslerr_invalid_addr | — | branch, cond | `apb_invalid_addr_test` |
| LED MUX | Binary-to-BCD display (decimal 42) | slpoh | 1) `LED_enable=1`. 2) Drive `error_q=42`, hold ≥1002 cycles. 3) Poll Done at `0x4004`. 4) Scoreboard compares each digit encoding. Constraints: C-4 (hold), C-5 (60–80 cycle latency). | assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one, check_60_80_cycle | cg_digits, cg_error_q | line, fsm, toggle | `led_decimal_42_test` |
| LED MUX | Max displayable value | slpoh | 1) Drive `error_q=999_999`. 2) Poll Done. 3) Expect all six digits show **9**. | assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one | cg_digits | line | `led_max_displayable_test` |
| LED MUX | Overflow modulo | slpoh | 1) Drive `error_q=1_000_001`. 2) Poll Done. 3) Expect display `000001`. Constraints: golden = `error_q % 1_000_000`. | assert_sel_out_onehot_active_low, assert_seg_out_bit7_always_one | cg_overflow, cg_digits | line, branch | `led_overflow_modulo_test` |
| LED MUX | LED_enable disables propagation | slpoh | 1) Write `LED_enable=0`. 2) Drive `error_q=55`. 3) Confirm `seg_out` does not update. Constraints: scoreboard SCB-7 gating. | — | cg_enable | cond | `led_disable_blocks_update_test` |
| LED MUX | sel_out one-hot multiplex scan | slpoh | 1) Drive `error_q=74565`. 2) Hold 1002 cycles. 3) Monitor samples `sel_out` — exactly one bit low per cycle. | assert_sel_out_onehot_active_low, cover_sel_out_digit_position | cg_digits | fsm, toggle | `led_sel_onehot_scan_test` |
| Corner cases | Reset recovery mid-display | slpoh | 1) Start `error_q=42` display. 2) Assert reset at cycle 500. 3) Check reset values. 4) Re-run display. | assert_sel_out_reset_value, assert_seg_out_reset_value | — | line | `led_reset_during_display_test` |
| Integration | End-to-end smoke | slpoh | 1) Reset. 2) Default enable. 3) `error_q=42`. 4) Poll Done. 5) Scoreboard pass. | all §0.3 assert/cover/check properties | cg_error_q, cg_digits, cg_enable | all | `smoke_test` |
| Integration | Random regression | slpoh | 1) Random APB + LED virtual sequence. 2) `error_q` 80% in-range, 20% overflow. 3) Coverage closure. Constraints: C-4, C-2/C-3; seed via `+ntb_random_seed`. | all §0.3 assert/cover/check properties | All covergroups | all | `random_regression_test` |

Export **P0 rows first** for presentation; add P1/P2 when implemented. Use `python scripts/generate_testplan.py --tier p0` for essential-only Excel.

---

### 11.5 Execution annotation (post-run)

After regression (Day 5), annotate the Excel testplan for the metrics-driven loop:

| Where | What to record |
|---|---|
| **$description** (append) | `PASS` / `FAIL`, date, seed |
| **Covergroups** (G) | Hit percentage or `CLOSED` / `OPEN` |
| **Code Coverage** (H) | Merged code-coverage % from VCS/Verdi |
| **Sheet1 → Goal** | Link to spec AC status |

---

### 11.6 Generate Excel testplan (script)

**Script:** `scripts/generate_testplan.py`  
**Output:** `LED_MUX_CONTROLLER_testplan.xlsx`

#### Owner name (required)

The generator **prompts for your name** before writing the file. This populates:

- **TestPlan** sheet → `$owner` (column D)
- **Sheet1** → `Test Owner`

```bash
python scripts/generate_testplan.py
# Enter testplan owner name ($owner / Test Owner): Your Name
```

Non-interactive (CI or repeat runs):

```bash
python scripts/generate_testplan.py --owner "slpoh"
# Essential only (11 tests, all P0):
python scripts/generate_testplan.py --owner "slpoh" --tier p0
# P0 + P1 (20 tests):
python scripts/generate_testplan.py --owner "slpoh" --tier p1
# All tests with Priority column (38, default):
python scripts/generate_testplan.py --owner "slpoh" --tier all
```

#### $description formatting rules

Each `$description` cell contains:

1. Numbered steps: `1) …`, `2) …` (one real step per line)
2. Optional `Constraints: …` line (from SPEC.md)
3. Optional `Checkers: …` line (SCB / SVA / MON / COV IDs)

**Do not** emit orphan `.` lines (e.g. `1) .`). Those were caused by splitting flow text on *every* period. Step numbers like `1.` also end with a period, so a naive split produced empty steps. The generator now splits only at boundaries before the next step number (`N. `), and validates output before save.

#### Regenerate after edits

After updating test entries in §2–§3 or SVA property names in §0.3, re-run the script.

#### SVA names in Excel column F

Use the **exact `snake_case` names** from §0.3 in the **Assertions/Cover property** column — never numeric IDs (`SVA-1`). Examples: `assert_sel_out_onehot_active_low`, `check_60_80_cycle`.

---

*Update the **Run** / **Pass** / **Coverage** columns during execution (Day 5) to complete the metrics-driven loop.*
