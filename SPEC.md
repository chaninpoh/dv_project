# SPEC: LED MUX Controller — UVM Verification Project

**Source:** PSDC_UVM_FINAL_PROJECT_DV_BATCH7.pdf (PCDA2025 Rev1.0)
**Author:** Su Lin Poh (Penang Silicon Design / PSDC)
**Classification:** Internal Use Only

---

## 1. Problem Statement

The Device Under Test (DUT) is an **LED MUX Controller** that reads a binary error count from an APB-accessible register and drives a 6-digit 7-segment LED display. The project requires building a complete UVM testbench to functionally verify this DUT, covering stimulus generation, protocol checking, scoreboarding, functional coverage, and regression.

---

## 2. Scope

### 2.1 DUT Blocks

The DUT contains two sub-blocks:

| Block | Role |
|---|---|
| **APB SLAVE** | Exposes a register interface for CPU control and status read-back |
| **LED_MUX** | Converts the error count from binary to BCD, multiplexes it across 6 LED digits |

### 2.2 Interfaces Under Test

- **APB Interface** — used to configure and read the DUT (driven by testbench)
- **LED Interface (Error Interface)** — drives the 20-bit error count into LED_MUX; captures `sel_out` and `seg_out` outputs

### 2.3 Out of Scope

- Physical LED panel hardware
- APB bus fabric (only the slave is modelled)
- Timing closure / synthesis

---

## 3. Functional Requirements

### 3.1 LED Display Multiplexing

- The LED_MUX block converts `error_q` from binary to decimal and drives a **6-digit 7-segment display**.
- The display is time-multiplexed: the controller cycles through all 6 digit positions. Each digit must be held for at least **one refresh cycle** so that the information propagates to all 6 LED positions.
- `sel_out` is a **one-hot, active-low** 6-bit select signal — one bit per digit.
- `seg_out[6:0]` is **active-low** (0 = segment on, 1 = segment off).
- `seg_out[7]` is **always 1** while segments are active (decimal point / active indicator).

### 3.2 Hold Time / Refresh Rate

- The error value must be held for a minimum of **6 multiplexing cycles** so that every digit receives the current value.
- For human visibility, the displayed value must be maintained for at least **2 seconds** in hardware (50 MHz clock → ≥ 100 million clock cycles).
- **Simulation equivalent:** maintain the value for at least **1002 clock cycles** (chosen because it is divisible by 6), corresponding to 20 μs at the simulation clock rate.
- After a new `error_q` is presented at the input, changes take effect at the output of the MUX controller after a propagation delay of **60–80 clock cycles**.

### 3.3 Reset Behaviour

On assertion of active-low reset (`rst_n = 0`):

| Signal | Reset Value |
|---|---|
| `sel_out` | `6'h3E` |
| `seg_out` | `8'h80` |

### 3.4 APB Slave — LED Enable

- The APB slave allows a CPU master to enable/disable the LED controller.
- **Default:** `LED_enable = 1` (LED controller is active on power-up without any write).
- When `LED_enable = 0`, the error signal is not propagated to `seg_out`.

### 3.5 APB Slave — Status Read-back

- The CPU can poll a **Done** status bit to determine when `seg_out` reflects a stable, valid encoding of `error_q`.
- When `Done = 1`, `seg_out[7:0]` encodes the current `error_q` value correctly.
- When `Done = 0`, `seg_out` is indeterminate.

### 3.6 Overflow Behaviour (error_q > 999,999)

- `error_q` is a 20-bit value with a maximum of 1,048,575, which exceeds the 6-digit display capacity of 999,999.
- When `error_q > 999,999`, the displayed value must be **`error_q % 1,000,000`** (the lower 6 decimal digits).
- Example: `error_q = 1,000,001` → display shows `000001`.

### 3.7 APB Slave — Scratch Pad

- A 32-bit read/write scratch pad register is available for CPU use.
- Any value written must be read back unchanged.

---

## 4. Data Model

### 4.1 LED Interface Signals

| Signal | Direction | Width (bits) | Description |
|---|---|---|---|
| `clk` | Input | 1 | System clock — 50 MHz in hardware |
| `rst_n` | Input | 1 | Active-low synchronous reset |
| `error_q` | Input | 20 | Error count in binary. Maximum value: 2²⁰ − 1 |
| `sel_out` | Output | 6 | One-hot digit select, active-low. Bit N selects digit N. |
| `seg_out` | Output | 8 | Segment drive: bits [6:0] active-low; bit [7] always 1 when active |

### 4.2 APB Interface Signals

| Signal | Direction | Width (bits) | Description |
|---|---|---|---|
| `i_paddr` | Input | 32 | Address bus |
| `i_psel` | Input | 1 | Slave select |
| `i_penable` | Input | 1 | Transfer enable (asserted on 2nd and subsequent cycles) |
| `i_pwrite` | Input | 1 | Transfer direction: 1 = write, 0 = read |
| `i_pwdata` | Input | 32 | Write data bus |
| `o_prdata` | Output | 32 | Read data bus |
| `o_pready` | Output | 1 | Slave ready — transfer completes when high |
| `o_pslerr` | Output | 1 | Slave error flag |

### 4.3 Register Map

| Register | Address | Field | Access | Default | Description |
|---|---|---|---|---|---|
| Control | `16'h4000` | `LED_enable` — Bit[0] | RW | 1 | Set to 1 to enable error propagation to `seg_out` |
| Status 1 | `16'h4004` | `Done` — Bit[0] | RO | 0 | 1 = `seg_out` is valid and matches `error_q` |
| Scratch Pad | `16'h4008` | Bit[31:0] | RW | 0 | General-purpose scratch; read must equal last write |

### 4.4 7-Segment Encoding

Segment positions are numbered 0–6 per the layout below:

```
 -- 1 --
|       |
6       2
|       |
 -- 0 --
|       |
5       3
|       |
 -- 4 --
```

Active segments (0 = on in `seg_out[6:0]`) for each decimal digit:

| Digit | Segments On |
|---|---|
| 0 | 1, 2, 3, 4, 5, 6 |
| 1 | 2, 3 |
| 2 | 0, 1, 2, 4, 5 |
| 3 | 0, 1, 2, 3, 4 |
| 4 | 0, 2, 3, 6 |
| 5 | 0, 1, 3, 4, 6 |
| 6 | 0, 3, 4, 5, 6 |
| 7 | 1, 2, 3 |
| 8 | 0, 1, 2, 3, 4, 5, 6 (all) |
| 9 | 0, 1, 2, 3, 6 |

---

## 5. Constraints

| # | Constraint |
|---|---|
| C-1 | Clock frequency is 50 MHz in hardware; simulation may use a scaled clock. |
| C-2 | `error_q` is a 20-bit unsigned value; maximum representable error count is 2²⁰ = 1,048,576. |
| C-3 | The 6-digit display can show at most 6 decimal digits (max displayable value: 999,999). When `error_q > 999,999`, the display shows `error_q % 1,000,000` (see FR 3.6). |
| C-4 | Simulation hold time must be ≥ 1002 cycles (divisible by 6) to satisfy the 6-cycle refresh requirement. |
| C-5 | Output changes are not observable until at least 60–80 cycles after the input changes. Checkers must not sample output before this latency window. |
| C-6 | APB transfers follow the standard two-phase (SETUP / ACCESS) protocol as shown in the write/read timing diagrams. |
| C-7 | `Done` status bit is read-only; writes to address `16'h4004` have no effect. |
| C-8 | Testbench must use the UVM 1.2 methodology (sequences, agents, monitors, scoreboard, coverage). |

---

## 6. Acceptance Criteria

### 6.1 Reset

- AC-R1: Immediately after `rst_n` de-asserts, `sel_out` must equal `6'h3E`.
- AC-R2: Immediately after `rst_n` de-asserts, `seg_out` must equal `8'h80`.

### 6.2 LED Enable

- AC-E1: With `LED_enable = 1` (default), changes to `error_q` must propagate to `seg_out` within 60–80 clock cycles.
- AC-E2: With `LED_enable = 0` (written via APB), `seg_out` must not update to reflect new `error_q` values.

### 6.3 Binary-to-Decimal Conversion

- AC-B1: For every value of `error_q` ≤ 999,999, each decimal digit of the converted value must be encoded in `seg_out` according to the segment map in Section 4.4.
- AC-B4: For `error_q` > 999,999, the displayed value must equal `error_q % 1,000,000`, with each digit encoded per Section 4.4. Test must cover at least one value in the range 1,000,000–1,048,575.
- AC-B2: `seg_out[7]` must be 1 whenever any segment is active.
- AC-B3: `seg_out[6:0]` must be active-low (a lit segment corresponds to bit value 0).

### 6.4 Multiplexing

- AC-M1: `sel_out` must be one-hot at all times during normal operation (exactly one bit is 0, all others are 1).
- AC-M2: The controller must cycle through all 6 digit positions within 1002 simulation clock cycles.
- AC-M3: Each digit position must be held for at least 1 clock cycle per refresh cycle.

### 6.5 Done Status

- AC-D1: When `Done = 1` (read via APB at `16'h4004`), the current `seg_out` encoding must correctly represent `error_q`.
- AC-D2: `Done` must reset to 0 after reset de-assertion.

### 6.6 APB Protocol

- AC-A1: Write followed by read to the same address must return the last written value (scratch pad: `16'h4008`; control: `16'h4000`).
- AC-A2: The `o_pslerr` signal must be asserted for invalid/unsupported transfers.
- AC-A3: The DUT must complete transfers with `o_pready` asserted as shown in the no-wait-state read timing diagram.

### 6.7 Coverage Closure

- AC-C1: All 10 decimal digit values (0–9) must be exercised on every digit position.
- AC-C2: Code coverage (line, branch, condition, FSM, toggle) and functional coverage (covergroups, cover properties) must be collected and annotated to the testplan.
- AC-C3: SVA assertions must be written for at least: reset values, `sel_out` one-hot property, and `seg_out[7]` always-1-when-active property.

---

## 7. Verification Methodology

The project follows a **Metrics-Driven Verification** flow with three phases:

| Phase | Activities |
|---|---|
| **Plan** | Write a SMART testplan; define features, sub-features, checker types, and milestones |
| **Build** | Implement UVM environment (agents, sequences, scoreboard, SVA, covergroups) per the testplan |
| **Execute** | Run regression with multiple seeds; merge coverage; annotate results back to testplan |

### 7.1 Testbench Components Required

- **APB Agent** — driver + monitor for the APB master interface
- **Error Interface Agent** — drives `error_q`; monitors `sel_out` and `seg_out`
- **Scoreboard** — receives transactions from monitors; compares expected vs actual segment encoding
- **Functional Coverage** — covergroups for `error_q` values, digit positions, `LED_enable` transitions
- **SVA Checker** — cover properties and assertions bound to the DUT

### 7.2 Project Schedule

| Day | Milestone |
|---|---|
| 1 | Recap; draw testbench architecture diagram; write testplan |
| 2 | Build testbench; write tests and sequences |
| 3 | Implement scoreboard and SVA checkers |
| 4 | Execute testplan; virtual sequence (stretch goal) |
| 5 | Coverage closure; regression; wrap-up |
| 6 | Presentation day |

### 7.3 Presentation Deliverables

- Objective and testplan overview
- Summary of verification effort (tests run, coverage achieved)
- Findings, conclusions, and proposed future improvements
