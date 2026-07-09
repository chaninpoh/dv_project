TESTNAME = "my_test"
SEED=0

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

run_dv:
	${ROOT}/sim/run_sim.csh dv ${MODULE} ${TESTNAME} ${SEED}




.PHONY: dv clean run_dv
