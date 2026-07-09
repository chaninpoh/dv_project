verdiSetActWin -dock widgetDock_<Decl._Tree>
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiWindowResize -win $_Verdi_1 "270" "81" "900" "700"
debLoadSimResult /mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/sim/waveform.fsdb
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
debLoadSimResult /mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/sim/waveform.fsdb
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvCloseGetStreamsDialog -win $_nWave2
wvAttrOrderConfigDlg -win $_nWave2 -close
wvCloseDetailsViewDlg -win $_nWave2
wvCloseDetailsViewDlg -win $_nWave2 -streamLevel
wvCloseFilterColorizeDlg -win $_nWave2
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvGetSignalOpen -win $_nWave2
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
simSetSimulator "-vcssv" -exec \
           "/mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/sim/dut_simv" -args
debImport "-dbdir" "/mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/sim/dut_simv.daidir"
srcHBSelect "top_tb.dut_inst" -win $_nTrace1
srcSetScope "top_tb.dut_inst" -delim "." -win $_nTrace1
srcHBSelect "top_tb.dut_inst" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
debLoadSimResult /mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/sim/waveform.fsdb
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk" -line 2 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "seg_out" -line 7 -pos 1 -win $_nTrace1
wvCreateWindow
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave3
verdiSetActWin -win $_nWave3
debExit
