# ARCHITECTURE: LED MUX Controller — UVM 1.2 Testbench

**Source spec:** SPEC.md (PSDC_UVM_FINAL_PROJECT_DV_BATCH7.pdf, PCDA2025 Rev1.0)

This architecture follows the UVM 1.2 build/connect/run model required by the spec: RTL and interfaces live in `tb_top`, UVM classes are factory-created, virtual interfaces and timing knobs are distributed through `uvm_config_db`, and all observed transactions are broadcast through analysis ports to independent checking and coverage subscribers.

---

## 1. Component Diagram

Shows every module/class in the testbench, how they are composed, and which signals flow between them.

```mermaid
flowchart TB
    subgraph TB_TOP["STATIC TESTBENCH TOP  (tb_top.sv)"]
        CLKGEN["clock/reset generation"]
        RUNTEST["uvm_config_db::set(vifs, cfg)\nrun_test()"]
    end

    subgraph TEST["UVM TEST  (base_test / derived tests)"]
        CFG["led_env_cfg\napb_agent_cfg · led_agent_cfg\nhold_cycles=1002 · latency=60..80"]
        VSEQ["virtual sequence\ncoordinates APB + LED sequences"]
        subgraph ENV["UVM ENVIRONMENT  (led_env)"]
            subgraph APB_AGT["APB AGENT  (apb_agent, active)"]
                APBSEQR["apb_sequencer\nextends uvm_sequencer#(apb_seq_item)"]
                APBDRV["apb_driver\n● vif: virtual apb_if"]
                APBMON["apb_monitor\n● vif: virtual apb_if\nanalysis_port#(apb_seq_item)"]
                APBSEQR -- "seq_item_export / seq_item_port" --> APBDRV
            end

            subgraph LED_AGT["ERROR INTERFACE AGENT  (led_agent, active)"]
                LEDSEQR["led_sequencer\nextends uvm_sequencer#(led_seq_item)"]
                LEDDRV["led_driver\n● vif: virtual led_if"]
                LEDMON["led_monitor\n● vif: virtual led_if\nanalysis_port#(led_seq_item)"]
                LEDSEQR -- "seq_item_export / seq_item_port" --> LEDDRV
            end

            SCB["led_scoreboard\nuvm_analysis_imp_apb\nuvm_analysis_imp_led\nref_model: bin→BCD"]
            COV["led_coverage\nextends uvm_subscriber\ncg_error_q · cg_digits · cg_enable"]
        end

        CFG --> ENV
        VSEQ --> APBSEQR
        VSEQ --> LEDSEQR
        APBMON -- ap: apb_seq_item --> SCB
        LEDMON -- ap: led_seq_item --> SCB
        APBMON -- ap: apb_seq_item --> COV
        LEDMON -- ap: led_seq_item --> COV
    end

    APB_IF["apb_if  (virtual interface)\ni_paddr · i_psel · i_penable\ni_pwrite · i_pwdata\no_prdata · o_pready · o_pslerr"]

    LED_IF["led_if  (virtual interface)\nerror_q 20-bit  → in\nclk · rst_n\nsel_out 6-bit   ← out\nseg_out 8-bit   ← out"]

    APBDRV -. vif ref .-> APB_IF
    APBMON -. vif ref .-> APB_IF
    LEDDRV -. vif ref .-> LED_IF
    LEDMON -. vif ref .-> LED_IF

    subgraph DUT["DUT — LED MUX Controller"]
        subgraph SLAVE["APB SLAVE"]
            R0["0x4000  LED_enable  RW  default=1"]
            R1["0x4004  Done        RO  default=0"]
            R2["0x4008  Scratch Pad RW  default=0"]
        end
        subgraph MUX["LED_MUX"]
            BCD["bin→BCD converter\noverflow: error_q mod 1000000"]
            MUXCTL["6-digit multiplexer\nsel_out one-hot active-low\n1002-cycle hold · 60-80 cy latency"]
            BCD --> MUXCTL
        end
        SVA["SVA CHECKER  (bound in tb_top)\nreset values · sel_out one-hot\nseg_out7 always 1 when active"]
        R0 -- LED_enable --> BCD
        BCD -- Done --> R1
    end

    TB_TOP --> APB_IF
    TB_TOP --> LED_IF
    TB_TOP --> DUT
    RUNTEST -. "config_db virtual interface handles" .-> APBDRV
    RUNTEST -. "config_db virtual interface handles" .-> APBMON
    RUNTEST -. "config_db virtual interface handles" .-> LEDDRV
    RUNTEST -. "config_db virtual interface handles" .-> LEDMON
    APB_IF <-- signals --> SLAVE
    LED_IF <-- signals --> MUX
```

### Key design decisions

| Decision | Why |
|---|---|
| Two separate agents (APB + LED IF) | The DUT has two physically distinct interfaces with different protocols; one agent per interface keeps stimulus and observation cleanly separated. |
| Virtual interface references (dotted lines, ● marker) | Driver and Monitor hold a SystemVerilog `virtual` handle — no structural port connection. This is the standard UVM pattern; it decouples the testbench class hierarchy from the RTL port hierarchy. |
| Analysis ports fan out to both Scoreboard and Coverage | Both consumers need every transaction, but neither should know about the other. The `uvm_analysis_port` broadcast model keeps them fully decoupled. |
| `tb_top` sets virtual interfaces through `uvm_config_db` | UVM classes cannot connect directly to RTL ports. The static top module instantiates the interfaces, places their virtual handles in the config database, and starts UVM with `run_test()`. |
| Agents are active by default but configurable | The project needs APB and LED stimulus, so both agents start as `UVM_ACTIVE`. Keeping `is_active` in each agent config makes passive reuse possible for future subsystem verification. |
| Coverage implemented as subscriber-style component | A coverage collector consumes monitor transactions like any other analysis subscriber. This keeps covergroups independent from the scoreboard's pass/fail logic. |
| SVA bound directly to DUT | Assertions fire in zero-sim-time relative to RTL signals, catching protocol violations that a UVM monitor (which samples at clock edges) might miss by one cycle. |
| Scoreboard holds reference model internally | The bin→BCD conversion and 7-segment encoding are simple enough to replicate inline; a separate reference model process is unnecessary overhead. |

---

## 2. Sequence Diagram

Traces one complete UVM stimulus cycle: `tb_top` starts UVM and publishes virtual interfaces, the test raises a run-phase objection, a virtual sequence coordinates APB and Error IF sequences, monitors publish observed transactions, then the scoreboard compares only after Done is observed.

```mermaid
sequenceDiagram
    participant Top    as tb_top
    participant Test   as base_test
    participant VSeq   as virtual sequence
    participant ASeqr  as APB Sequencer
    participant ADrv   as apb_driver
    participant AMon   as apb_monitor
    participant DAPB   as DUT APB SLAVE
    participant DMUX   as DUT LED_MUX
    participant LSeqr  as LED IF Sequencer
    participant LDrv   as led_driver
    participant LMon   as led_monitor
    participant SCB    as led_scoreboard

    Note over Top,SCB: ── UVM setup: build/connect/run ──
    Top->>Test: run_test()
    Top->>Test: config_db provides apb_if / led_if / env_cfg
    Test->>Test: build_phase creates env via factory
    Test->>Test: run_phase raise_objection()
    Test->>VSeq: start() with APB + LED sequencer handles

    Note over VSeq,SCB: ── Phase 1: Register transition (APB write LED_enable = 1) ──

    VSeq->>ASeqr: start(apb_write_seq, addr=0x4000, data=1)
    ASeqr->>ADrv: get_next_item(apb_seq_item)
    ADrv->>DAPB: SETUP  psel=1 pwrite=1 paddr=0x4000 pwdata=1
    ADrv->>DAPB: ACCESS  penable=1
    DAPB-->>ADrv: pready=1  (no-wait-state)
    ADrv->>ASeqr: item_done()
    AMon->>DAPB: sample paddr / pwrite / pwdata / pready
    AMon->>SCB: ap.write(apb_seq_item)  ── LED_enable=1 recorded

    Note over VSeq,SCB: ── Phase 2: Drive error_q through LED sequence ──

    VSeq->>LSeqr: start(led_error_seq, error_q=42)
    LSeqr->>LDrv: get_next_item(led_seq_item)
    LDrv->>DMUX: drive error_q = 20'h0002A
    Note over LDrv,DMUX: hold ≥ 1002 clock cycles (C-4)
    LDrv->>LSeqr: item_done()

    Note over DMUX: 60–80 cycle propagation delay (C-5)
    DMUX->>DMUX: bin→BCD(42) → digits 0,0,0,0,4,2
    DMUX->>DMUX: cycle sel_out one-hot through positions 5→0
    DMUX->>DMUX: assert Done=1 when all digits stable

    Note over VSeq,SCB: ── Phase 3: Poll Done register, then compare ──

    VSeq->>ASeqr: start(apb_read_seq, addr=0x4004)
    ASeqr->>ADrv: get_next_item(apb_seq_item)
    ADrv->>DAPB: SETUP  psel=1 pwrite=0 paddr=0x4004
    ADrv->>DAPB: ACCESS  penable=1
    DAPB-->>ADrv: prdata=1 (Done=1)  pready=1
    ADrv->>ASeqr: item_done()
    AMon->>SCB: ap.write(apb_seq_item)  ── Done=1 recorded

    LMon->>DMUX: sample sel_out / seg_out (after latency window)
    LMon->>SCB: ap.write(led_seq_item)
    SCB->>SCB: ref_model(error_q=42) → expected seg_out per digit
    SCB->>SCB: compare expected vs actual → PASS / FAIL
    VSeq-->>Test: sequence complete
    Test->>Test: drop_objection()
```

### Key design decisions

| Decision | Why |
|---|---|
| Test owns objections; sequences do not | The test controls simulation lifetime in `run_phase`. Sequences remain reusable transaction generators and do not decide when the phase ends. |
| Virtual sequence coordinates both agents | APB control/status traffic and LED stimulus must be ordered together. A virtual sequence centralizes cross-interface ordering without coupling the two agents. |
| APB write precedes `error_q` drive | The `LED_enable` state must be known to the scoreboard before any `seg_out` comparison — order matters because `LED_enable=0` suppresses output entirely (FR 3.4). |
| `item_done()` called before monitor samples | The driver releases the item as soon as the bus cycle completes; the monitor observes the same signals independently. This is the UVM split-transaction model — driver and monitor are never coupled. |
| Done register polled before scoreboard comparison | `seg_out` is indeterminate when `Done=0` (FR 3.5 / AC-D1). Sampling before `Done=1` would produce false failures; polling via APB is the only safe gate. |
| 1002-cycle hold enforced in driver (not test) | The hold-time constraint (C-4) is a driver-level protocol rule, not a test-level concern. Encoding it in `led_driver` makes it impossible for any sequence to violate it. |
| 60–80 cycle latency window respected by monitor | The monitor must not sample outputs within this window (C-5). The monitor tracks cycles since `error_q` changed and defers sampling until the window closes. |

---

## 3. Class Diagram

Shows the data model: transaction objects, UVM component classes, their fields, and the composition/dependency relationships.

```mermaid
classDiagram
    class tb_top {
        <<module>>
        +apb_if apb_vif
        +led_if led_vif
        +DUT dut
        +initial config_db_set()
        +initial run_test()
    }

    class led_env_cfg {
        +apb_agent_cfg apb_cfg
        +led_agent_cfg led_cfg
        +int hold_cycles = 1002
        +int latency_lo = 60
        +int latency_hi = 80
        +bit enable_coverage = 1
    }

    class apb_agent_cfg {
        +uvm_active_passive_enum is_active = UVM_ACTIVE
        +virtual apb_if vif
    }

    class led_agent_cfg {
        +uvm_active_passive_enum is_active = UVM_ACTIVE
        +virtual led_if vif
        +int hold_cycles
        +int latency_lo
        +int latency_hi
    }

    class apb_seq_item {
        <<uvm_sequence_item>>
        +rand bit[31:0] addr
        +rand bit       pwrite
        +rand bit[31:0] wdata
        +bit[31:0]      rdata
        +bit            pready
        +bit            pslerr
        +constraint c_addr: addr inside 0x4000 0x4004 0x4008
    }

    class led_seq_item {
        <<uvm_sequence_item>>
        +rand bit[19:0] error_q
        +bit[5:0]       sel_out
        +bit[7:0]       seg_out
        +constraint c_range: error_q <= 20hFFFFF
    }

    class apb_sequencer {
        <<uvm_sequencer>>
    }

    class led_sequencer {
        <<uvm_sequencer>>
    }

    class led_virtual_sequence {
        <<uvm_sequence>>
        +apb_sequencer apb_seqr
        +led_sequencer led_seqr
        +task body()
    }

    class apb_driver {
        <<uvm_driver>>
        +virtual apb_if vif
        +apb_agent_cfg cfg
        +function build_phase()
        +task run_phase()
        +task drive_setup(apb_seq_item t)
        +task drive_access(apb_seq_item t)
    }

    class apb_monitor {
        <<uvm_monitor>>
        +virtual apb_if vif
        +uvm_analysis_port ap
        +apb_agent_cfg cfg
        +function build_phase()
        +task run_phase()
        +task capture_transfer()
    }

    class apb_agent {
        <<uvm_agent>>
        +apb_agent_cfg cfg
        +apb_driver  drv
        +apb_monitor mon
        +apb_sequencer seqr
        +uvm_active_passive_enum is_active
        +function build_phase()
        +function connect_phase()
    }

    class led_driver {
        <<uvm_driver>>
        +virtual led_if vif
        +led_agent_cfg cfg
        +int hold_cycles
        +function build_phase()
        +task run_phase()
        +task drive_error_q(led_seq_item t)
    }

    class led_monitor {
        <<uvm_monitor>>
        +virtual led_if vif
        +uvm_analysis_port ap
        +led_agent_cfg cfg
        +int latency_lo
        +int latency_hi
        +function build_phase()
        +task run_phase()
        +task sample_outputs()
    }

    class led_agent {
        <<uvm_agent>>
        +led_agent_cfg cfg
        +led_driver  drv
        +led_monitor mon
        +led_sequencer seqr
        +function build_phase()
        +function connect_phase()
    }

    class led_scoreboard {
        <<uvm_scoreboard>>
        +uvm_analysis_imp apb_export
        +uvm_analysis_imp led_export
        +bit led_enable
        +bit done_flag
        +int pass_count
        +int fail_count
        +function write_apb(apb_seq_item t)
        +function write_led(led_seq_item t)
        +function ref_model(bit[19:0] eq) bit[7:0]
        +function bcd_to_seg(bit[3:0] d)  bit[7:0]
    }

    class led_coverage {
        <<uvm_subscriber>>
        +covergroup cg_error_q
        +covergroup cg_digits
        +covergroup cg_enable
        +function write(led_seq_item t)
    }

    class led_env {
        <<uvm_env>>
        +led_env_cfg cfg
        +apb_agent    apb_agt
        +led_agent    led_agt
        +led_scoreboard scb
        +led_coverage   cov
        +function build_phase()
        +function connect_phase()
    }

    class base_test {
        <<uvm_test>>
        +led_env env
        +led_env_cfg cfg
        +function build_phase()
        +function end_of_elaboration_phase()
        +task    run_phase()
    }

    %% Composition
    tb_top          ..> base_test : run_test
    base_test       *-- led_env
    base_test       *-- led_env_cfg
    led_env_cfg     *-- apb_agent_cfg
    led_env_cfg     *-- led_agent_cfg
    led_env         *-- apb_agent
    led_env         *-- led_agent
    led_env         *-- led_scoreboard
    led_env         *-- led_coverage
    apb_agent       *-- apb_sequencer
    apb_agent       *-- apb_driver
    apb_agent       *-- apb_monitor
    led_agent       *-- led_sequencer
    led_agent       *-- led_driver
    led_agent       *-- led_monitor

    %% Transaction usage
    led_virtual_sequence ..> apb_sequencer : starts APB sequences
    led_virtual_sequence ..> led_sequencer : starts LED sequences
    apb_driver      ..> apb_seq_item : drives
    apb_monitor     ..> apb_seq_item : captures
    led_driver      ..> led_seq_item : drives
    led_monitor     ..> led_seq_item : captures

    %% Analysis port connections
    apb_monitor     --> led_scoreboard : ap.write
    led_monitor     --> led_scoreboard : ap.write
    apb_monitor     --> led_coverage   : ap.write
    led_monitor     --> led_coverage   : ap.write
```

### Key design decisions

| Decision | Why |
|---|---|
| Separate config objects for env and agents | `led_env_cfg`, `apb_agent_cfg`, and `led_agent_cfg` make virtual interfaces, active/passive mode, timing windows, and coverage enables explicit build-time settings instead of scattered constants. |
| Every UVM class is factory-registered | Components, sequences, and sequence items should use the appropriate UVM utility macro so tests can override behavior without editing the environment. |
| Two separate transaction classes (`apb_seq_item`, `led_seq_item`) | The APB and LED interfaces have fundamentally different signal sets and randomisation constraints; a shared base class would only add complexity with no reuse benefit. |
| `addr` constrained to `{0x4000, 0x4004, 0x4008}` in `apb_seq_item` | These are the only valid register addresses. Constraining at the item level means every sequence automatically stays in-range without extra guard code. |
| `hold_cycles` and `latency_lo / latency_hi` as fields, not constants | Allows tests to override via `uvm_config_db` for corner-case timing tests without subclassing the driver or monitor. |
| `led_scoreboard` contains the reference model (`ref_model`, `bcd_to_seg`) | The DUT's logic (bin→BCD + 7-segment encoding) is simple and deterministic. An embedded golden model is easier to audit against the spec's segment table (Section 4.4) than an external model. |
| `led_coverage` is a separate class (not inside scoreboard) | Coverage closure and correctness checking are orthogonal concerns. Separating them means either can be disabled, replaced, or extended independently. |
| `uvm_analysis_imp` with two ports in scoreboard | The scoreboard needs both APB context (what `LED_enable` is set to) and LED IF data (actual `seg_out`) to make a correct comparison. Two named imports handle the fan-in cleanly using the `uvm_analysis_imp_decl` macro. |

---

## 4. UVM Implementation Flow

This is the build order and responsibility split the SystemVerilog implementation should follow.

### Static top (`tb_top.sv`)

- Instantiate the DUT, `apb_if`, and `led_if`.
- Generate `clk` and drive/reset `rst_n`.
- Bind the SVA checker to the DUT or DUT interfaces.
- Publish virtual interfaces before `run_test()`:

```systemverilog
uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agt*", "vif", apb_vif);
uvm_config_db#(virtual led_if)::set(null, "uvm_test_top.env.led_agt*", "vif", led_vif);
run_test();
```

### Test layer

- `base_test` creates `led_env_cfg`, sets default timing/configuration, creates `led_env` through the factory, and passes config through `uvm_config_db`.
- Derived tests override only scenario intent: reset test, enable/disable test, overflow test, scratch-pad test, APB error test, and randomized regression test.
- `run_phase` raises one objection, starts a virtual sequence, waits for completion, then drops the objection.

### Environment and agents

- `led_env.build_phase` gets `led_env_cfg`, creates both agents, scoreboard, and coverage when enabled.
- Each agent always creates its monitor. It creates sequencer and driver only when `cfg.is_active == UVM_ACTIVE`.
- Each active agent connects `driver.seq_item_port` to `sequencer.seq_item_export` in `connect_phase`.
- Monitors publish completed transactions through `uvm_analysis_port`; they do not call scoreboard methods directly.

### Checking and coverage

- `led_scoreboard` keeps APB-visible state (`LED_enable`, `Done`, scratch-pad mirror) and compares LED observations only after `Done == 1`.
- `led_coverage` samples monitor transactions and crosses digit position, digit value, overflow/non-overflow, and enable state.
- SVA handles cycle-accurate protocol and signal invariants: reset values, APB two-phase behavior, `sel_out` one-hot active-low, and `seg_out[7] == 1` when active.
