TESTNAME ?= phase1_tb_top_test
SEED     ?= 0

COMP_LOG = $(MODULE)_comp.log
SIM_LOG  = $(TESTNAME)_seed_$(SEED)_sim.log

.PHONY: dv clean run_dv compile run gate1 phase1 gate2 phase2

dv: run_dv

clean:
	\rm -frd novas* mkdir csrc
	\rm -frd ${MODULE}_comp.log *_sim.log *_sim.rpt *_simv *_sim.vcd *_sim.fsdb *_simv.daidir  *_ana.log *_cov.vdb
	\rm -frd ${MODULE}_sim.vcd.vpd
	\rm -frd ucli.key worklib debug.report
	\rm -frd DVEfiles dve_report.* opendatabase.log
	\rm -frd verdiLog inter.fsdb
	\rm -frd seed* sysBusyP* vc_hdrs.h
	\rm -frd bus_cov fa_cov ${MODULE}_simv.vdb cm.log .fsm.sch.verilog.xml
	\rm -frd qrun sysProgressP.conf sysProgressPLog vdCov.conf vdCovLog
	\rm -frd ${MODULE}_*_sim.fsdb ${MODULE}_*_sim.log ${MODULE}_sva.rpt* *_sva.rpt*

# Compile + elaborate + run (course wrapper)
run_dv:
	csh ${ROOT}/sim/run_sim.csh dv ${MODULE} ${TESTNAME} ${SEED}

compile: run_dv

run: run_dv

gate1:
	@./check_phase1_gate.sh $(COMP_LOG) $(SIM_LOG)

phase1: run_dv gate1
	@echo "Phase 1 complete."

gate2:
	@./check_phase2_gate.sh $(COMP_LOG) $(SIM_LOG)

phase2: run_dv gate2
	@echo "Phase 2 complete."
