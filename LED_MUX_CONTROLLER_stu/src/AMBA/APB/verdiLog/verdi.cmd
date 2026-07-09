verdiWindowResize -win $_Verdi_1 "1" "42" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debLoadSimResult \
           /mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/src/AMBA/APB/waveform.fsdb
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/APB_TB"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0/S0"
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetPosition -win $_nWave2 {("G1" 11)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/APB_TB/D0/S0/count_pready\[2:0\]} \
{/APB_TB/D0/S0/i_paddr\[31:0\]} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/S0/i_penable} \
{/APB_TB/D0/S0/i_prstn} \
{/APB_TB/D0/S0/i_psel} \
{/APB_TB/D0/S0/i_pwdata\[31:0\]} \
{/APB_TB/D0/S0/i_pwrite} \
{/APB_TB/D0/S0/o_prdata\[31:0\]} \
{/APB_TB/D0/S0/o_pready} \
{/APB_TB/D0/S0/o_pslverr} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 )} 
wvSetPosition -win $_nWave2 {("G1" 11)}
wvSetCursor -win $_nWave2 971856.085754 -snap {("G1" 11)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/APB_TB"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0/S0"
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 12)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/APB_TB/D0/S0/count_pready\[2:0\]} \
{/APB_TB/D0/S0/i_paddr\[31:0\]} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/S0/i_penable} \
{/APB_TB/D0/S0/i_prstn} \
{/APB_TB/D0/S0/i_psel} \
{/APB_TB/D0/S0/i_pwdata\[31:0\]} \
{/APB_TB/D0/S0/i_pwrite} \
{/APB_TB/D0/S0/o_prdata\[31:0\]} \
{/APB_TB/D0/S0/o_pready} \
{/APB_TB/D0/S0/o_pslverr} \
{/APB_TB/D0/S0/i_pclk} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 12)}
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0"
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/APB_TB/D0/S0/count_pready\[2:0\]} \
{/APB_TB/D0/S0/i_paddr\[31:0\]} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/S0/i_penable} \
{/APB_TB/D0/S0/i_prstn} \
{/APB_TB/D0/S0/i_psel} \
{/APB_TB/D0/S0/i_pwdata\[31:0\]} \
{/APB_TB/D0/S0/i_pwrite} \
{/APB_TB/D0/S0/o_prdata\[31:0\]} \
{/APB_TB/D0/S0/o_pready} \
{/APB_TB/D0/S0/o_pslverr} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/penable_m0} \
{/APB_TB/D0/penable_m1} \
{/APB_TB/D0/penable_m2} \
{/APB_TB/D0/penable_s} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 13 14 15 16 )} 
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/APB_TB/D0/S0/count_pready\[2:0\]} \
{/APB_TB/D0/S0/i_paddr\[31:0\]} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/S0/i_penable} \
{/APB_TB/D0/S0/i_prstn} \
{/APB_TB/D0/S0/i_psel} \
{/APB_TB/D0/S0/i_pwdata\[31:0\]} \
{/APB_TB/D0/S0/i_pwrite} \
{/APB_TB/D0/S0/o_prdata\[31:0\]} \
{/APB_TB/D0/S0/o_pready} \
{/APB_TB/D0/S0/o_pslverr} \
{/APB_TB/D0/S0/i_pclk} \
{/APB_TB/D0/penable_m0} \
{/APB_TB/D0/penable_m1} \
{/APB_TB/D0/penable_m2} \
{/APB_TB/D0/penable_s} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 13 14 15 16 )} 
wvSetPosition -win $_nWave2 {("G1" 16)}
wvGetSignalClose -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/APB_TB"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0/M0"
wvScrollDown -win $_nWave2 0
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/APB_TB"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0"
wvGetSignalSetScope -win $_nWave2 "/APB_TB/D0/M0"
wvSetPosition -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 16)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvAddSignal -win $_nWave2 "/APB_TB/D0/M0/i_pready"
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
simSetSimulator "-vcssv" -exec \
           "/mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/src/AMBA/APB/simv" -args
debImport "-dbdir" \
          "/mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/src/AMBA/APB/simv.daidir"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "APB_TB.D0" -win $_nTrace1
srcSetScope "APB_TB.D0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "APB_TB.D0.M0" -win $_nTrace1
srcSetScope "APB_TB.D0.M0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.M0" -win $_nTrace1
srcSignalView -on
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "APB_TB.D0.M0.i_prstn"
srcSignalViewSelect "APB_TB.D0.M0.i_pslverr"
srcSignalViewSelect "APB_TB.D0.M0.i_prstn" "APB_TB.D0.M0.i_pclk" \
           "APB_TB.D0.M0.i_command" "APB_TB.D0.M0.i_start" \
           "APB_TB.D0.M0.i_data_in\[31:0\]" "APB_TB.D0.M0.i_addr_in\[31:0\]" \
           "APB_TB.D0.M0.i_prdata\[31:0\]" "APB_TB.D0.M0.i_pready" \
           "APB_TB.D0.M0.i_pslverr"
wvCreateWindow
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
verdiSetActWin -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 0)}
wvOpenFile -win $_nWave3 \
           {/mnt/PCDA_share/pohsl/LED_MUX_CONTROLLER/src/AMBA/APB/waveform.fsdb}
verdiSetActWin -dock widgetDock_<Signal_List>
wvAddSignal -win $_nWave3 "/APB_TB/D0/M0/i_prstn" "/APB_TB/D0/M0/i_pclk" \
           "/APB_TB/D0/M0/i_command" "/APB_TB/D0/M0/i_start" \
           "/APB_TB/D0/M0/i_data_in\[31:0\]" "/APB_TB/D0/M0/i_addr_in\[31:0\]" \
           "/APB_TB/D0/M0/i_prdata\[31:0\]" "/APB_TB/D0/M0/i_pready" \
           "/APB_TB/D0/M0/i_pslverr"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 9)}
wvSetPosition -win $_nWave3 {("G1" 9)}
wvSelectSignal -win $_nWave3 {( "G1" 5 )} 
verdiSetActWin -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 8 )} 
wvSelectSignal -win $_nWave3 {( "G1" 7 )} 
wvSelectSignal -win $_nWave3 {( "G1" 6 )} 
wvSelectSignal -win $_nWave3 {( "G1" 5 )} 
wvSelectSignal -win $_nWave3 {( "G1" 6 )} 
wvSelectSignal -win $_nWave3 {( "G1" 7 )} 
wvSelectSignal -win $_nWave3 {( "G1" 9 )} 
wvSelectSignal -win $_nWave3 {( "G1" 8 )} 
wvSelectSignal -win $_nWave3 {( "G1" 8 )} 
wvSelectSignal -win $_nWave3 {( "G1" 8 )} 
srcSignalViewSelect "APB_TB.D0.M0.i_start"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "APB_TB.D0.M0.i_pslverr"
srcSignalViewSelect "APB_TB.D0.M0.i_pready"
srcSignalViewAddSelectedToWave
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pready" -line 28 -pos 1 -win $_nTrace1
srcAction -pos 27 4 5 -win $_nTrace1 -name "i_pready" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt\[0\]" -line 117 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt\[0\]" -line 117 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/o_gnt\[0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "pready_m" -line 142 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/pready_m"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSelectSignal -win $_nWave3 {( "G1" 2 )} 
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "pready_m" -line 142 -pos 1 -win $_nTrace1
srcAction -pos 141 4 2 -win $_nTrace1 -name "pready_m" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/o_gnt\[2:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
srcAction -pos 178 4 2 -win $_nTrace1 -name "o_gnt" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
srcAction -pos 83 6 9 -win $_nTrace1 -name \
          "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left" -line 82 -pos 1 -win $_nTrace1
srcAction -pos 81 2 10 -win $_nTrace1 -name "priority_tmp_left" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp" -line 82 -pos 1 -win $_nTrace1
srcAction -pos 81 7 7 -win $_nTrace1 -name "priority_tmp" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate\[MASTER_COUNT-1:0\]" -line 79 -pos 1 -win \
          $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate\[MASTER_COUNT-1:0\]" -line 79 -pos 1 -win \
          $_nTrace1
srcAction -pos 78 6 13 -win $_nTrace1 -name \
          "request_vec_rotate\[MASTER_COUNT-1:0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate_double\[MASTER_COUNT-1:0\]" -line 71 -pos 1 \
          -win $_nTrace1
srcAction -pos 70 6 19 -win $_nTrace1 -name \
          "request_vec_rotate_double\[MASTER_COUNT-1:0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate_double" -line 70 -pos 1 -win $_nTrace1
srcAction -pos 69 2 17 -win $_nTrace1 -name "request_vec_rotate_double" -ctrlKey \
          off
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/request_vec_rotate_double\[5:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 70 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 70 -pos 1 -win $_nTrace1
srcAction -pos 69 12 8 -win $_nTrace1 -name "priority_state\[0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_clk" -line 48 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_clk"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_rst" -line 48 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_rst"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state" -line 53 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state" -line 50 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "APB_TB/D0/f0/A0/priority_state\[2:0\]"
wvUnknownSaveResult -win $_nWave3 -clear
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "APB_TB/D0/f0/A0/priority_state\[2:0\]"
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state" -line 53 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "next_priority_state" -line 53 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "APB_TB/D0/f0/A0/next_priority_state\[2:0\]"
wvSelectSignal -win $_nWave3 {( "G1" 4 )} 
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_update" -line 52 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_update"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_end_of_transfer" -line 57 -pos 1 -win $_nTrace1
srcSetOptions -annotate on -win $_nTrace1
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcSelect -signal "next_priority_state" -line 53 -pos 1 -win $_nTrace1
verdiWindowResize -win $_Verdi_1 "77" "141" "1038" "700"
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
srcSetScope "APB_TB.D0.f0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "APB_TB" -win $_nTrace1
srcSetScope "APB_TB" -delim "." -win $_nTrace1
srcHBSelect "APB_TB" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "start_0" -line 86 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave3
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "APB_TB.D0.f0.A0" -win $_nTrace1
srcSetScope "APB_TB.D0.f0.A0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.f0.A0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_end_of_transfer" -line 7 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/o_end_of_transfer"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvZoom -win $_nWave3 0.000000 693189.262613
verdiSetActWin -win $_nWave3
wvZoom -win $_nWave3 0.000000 86984.939810
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_request_vec" -line 7 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_request_vec\[2:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
srcSetScope "APB_TB.D0.f0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
verdiSetActWin -win $_nWave3
wvSelectAll -win $_nWave3
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 0)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_paddr" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_pwrite" -line 104 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -signal "o_psel" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_penable" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_pwdata" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_prdata" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_pready" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_pslverr" -line 104 -pos 1 -win $_nTrace1
srcSelect -signal "o_gnt" -line 105 -pos 1 -win $_nTrace1
srcAction -pos 104 0 2 -win $_nTrace1 -name "o_gnt" -ctrlKey off
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/o_paddr\[31:0\]" \
           "/APB_TB/D0/f0/o_pwrite" "/APB_TB/D0/f0/o_psel\[2:0\]" \
           "/APB_TB/D0/f0/o_penable" "/APB_TB/D0/f0/o_pwdata\[31:0\]" \
           "/APB_TB/D0/f0/o_prdata\[31:0\]" "/APB_TB/D0/f0/o_pready" \
           "/APB_TB/D0/f0/o_pslverr" "/APB_TB/D0/f0/o_gnt\[2:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 9)}
verdiWindowResize -win $_Verdi_1 "34" "34" "1261" "762"
wvZoomAll -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomAll -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_prstn" -line 96 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/i_prstn"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pclk" -line 96 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/i_pclk"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pready_s0" -line 100 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomAll -win $_nWave3
srcSignalViewSelect "APB_TB.D0.f0.i_prstn"
verdiSetActWin -dock widgetDock_<Signal_List>
srcHBSelect "APB_TB.D0.f0.A0" -win $_nTrace1
srcSetScope "APB_TB.D0.f0.A0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.f0.A0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_update" -line 52 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 4)}
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_update"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_update" -line 52 -pos 1 -win $_nTrace1
srcAction -pos 51 6 3 -win $_nTrace1 -name "i_update" -ctrlKey off
srcTraceValueChange "APB_TB.D0.f0.o_pready" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pready_s1" -line 196 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
verdiSetActWin -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -show -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "I_UPDATE" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "i-update" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "i_update" -next -widget MTB_SOURCE_TAB_1
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pready" -line 347 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/o_pready"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSelectSignal -win $_nWave3 {( "G1" 1 )} 
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pready" -line 347 -pos 1 -win $_nTrace1
srcAction -pos 346 4 4 -win $_nTrace1 -name "o_pready" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/o_gnt\[2:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
srcAction -pos 178 4 1 -win $_nTrace1 -name "o_gnt" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp" -line 79 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate\[MASTER_COUNT-1:0\]" -line 79 -pos 1 -win \
          $_nTrace1
srcAction -pos 78 6 12 -win $_nTrace1 -name \
          "request_vec_rotate\[MASTER_COUNT-1:0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "request_vec_rotate_double\[MASTER_COUNT-1:0\]" -line 71 -pos 1 \
          -win $_nTrace1
srcAction -pos 70 6 11 -win $_nTrace1 -name \
          "request_vec_rotate_double\[MASTER_COUNT-1:0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[i\]" -line 62 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
srcSignalViewSelect "APB_TB.D0.f0.A0.priority_tmp\[2:0\]"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomAll -win $_nWave3
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollDown -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
wvScrollUp -win $_nWave3 1
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "APB_TB.D0.f0.A0.priority_state\[2:0\]"
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debReload
srcSignalViewSelect "APB_TB.D0.f0.A0.next_priority_state\[2:0\]"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
srcSignalViewSelect "APB_TB.D0.f0.A0.priority_state\[2:0\]"
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSetPosition -win $_nWave3 {("G1" 3)}
wvExpandBus -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 7)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state" -line 32 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
verdiFindBar -show -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_gnt" -next -widget MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave3
wvScrollUp -win $_nWave3 1
wvSelectSignal -win $_nWave3 {( "G1" 5 )} 
verdiSetActWin -win $_nWave3
wvSelectAll -win $_nWave3
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 0)}
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/priority_tmp_left\[5:3\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
srcAction -pos 83 6 11 -win $_nTrace1 -name \
          "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -ctrlKey off
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 82 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp" -line 82 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 82 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 82 -pos 1 -win $_nTrace1
srcAction -pos 81 12 6 -win $_nTrace1 -name "priority_state\[0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state" -line 50 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/priority_state\[2:0\]"
wvSetPosition -win $_nWave3 {("G1" 1)}
wvSetPosition -win $_nWave3 {("G1" 2)}
wvSelectSignal -win $_nWave3 {( "G1" 2 )} 
wvExpandBus -win $_nWave3
verdiSetActWin -win $_nWave3
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 82 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_state\[0\]" -line 82 -pos 1 -win $_nTrace1
srcAction -pos 81 12 4 -win $_nTrace1 -name "priority_state\[0\]" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "next_priority_state" -line 53 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_update" -line 52 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/f0/A0/i_update"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 1)}
wvScrollDown -win $_nWave3 0
wvScrollDown -win $_nWave3 0
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_update" -line 52 -pos 1 -win $_nTrace1
srcAction -pos 51 6 4 -win $_nTrace1 -name "i_update" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pready" -line 175 -pos 1 -win $_nTrace1
srcAction -pos 174 1 5 -win $_nTrace1 -name "o_pready" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pready" -line 175 -pos 1 -win $_nTrace1
srcAction -pos 174 1 4 -win $_nTrace1 -name "o_pready" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_pready" -line 175 -pos 1 -win $_nTrace1
srcAction -pos 174 1 5 -win $_nTrace1 -name "o_pready" -ctrlKey off
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_pready_s0" -line 217 -pos 1 -win $_nTrace1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_pready" -next -widget MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
debReload
wvSetCursor -win $_nWave3 2512510.000000
verdiSetActWin -win $_nWave3
wvSetCursor -win $_nWave3 2512510.000000
wvSetCursor -win $_nWave3 2512510.000000
wvSetCursor -win $_nWave3 2892890.000000
wvSetCursor -win $_nWave3 2892890.000000
wvSetCursor -win $_nWave3 3293290.000000
wvSetCursor -win $_nWave3 3293290.000000
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSetPosition -win $_nWave3 {("G1" 3)}
wvCollapseBus -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvExpandBus -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSetPosition -win $_nWave3 {("G1" 3)}
wvCollapseBus -win $_nWave3
wvSetPosition -win $_nWave3 {("G1" 3)}
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvExpandBus -win $_nWave3
wvSelectSignal -win $_nWave3 {( "G1" 4 )} 
wvSelectSignal -win $_nWave3 {( "G1" 4 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSignalViewSelect "APB_TB.D0.f0.i_pclk"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewAddSelectedToWave -clipboard
wvDrop -win $_nWave3
wvZoom -win $_nWave3 550677.787234 1049729.531915
verdiSetActWin -win $_nWave3
wvZoom -win $_nWave3 595588.247016 603982.725480
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvSetCursor -win $_nWave3 550364.671069 -snap {("G1" 7)}
wvSetMarker -win $_nWave3 570000.000000
srcHBSelect "APB_TB.D0.M1" -win $_nTrace1
srcSetScope "APB_TB.D0.M1" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.M1" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSignalViewSelect "APB_TB.D0.M1.i_prstn"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "APB_TB.D0.M1.i_prstn" "APB_TB.D0.M1.i_pclk" \
           "APB_TB.D0.M1.i_command" "APB_TB.D0.M1.i_start" \
           "APB_TB.D0.M1.i_data_in\[31:0\]" "APB_TB.D0.M1.i_addr_in\[31:0\]" \
           "APB_TB.D0.M1.i_prdata\[31:0\]" "APB_TB.D0.M1.i_pready" \
           "APB_TB.D0.M1.i_pslverr"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/M1/i_prstn" "/APB_TB/D0/M1/i_pclk" \
           "/APB_TB/D0/M1/i_command" "/APB_TB/D0/M1/i_start" \
           "/APB_TB/D0/M1/i_data_in\[31:0\]" "/APB_TB/D0/M1/i_addr_in\[31:0\]" \
           "/APB_TB/D0/M1/i_prdata\[31:0\]" "/APB_TB/D0/M1/i_pready" \
           "/APB_TB/D0/M1/i_pslverr"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 9)}
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
verdiSetActWin -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
wvZoomOut -win $_nWave3
srcHBSelect "APB_TB.D0.M0" -win $_nTrace1
srcSetScope "APB_TB.D0.M0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.M0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcSignalViewSelect "APB_TB.D0.M0.i_prstn"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "APB_TB.D0.M0.i_prstn" "APB_TB.D0.M0.i_pclk" \
           "APB_TB.D0.M0.i_command" "APB_TB.D0.M0.i_start" \
           "APB_TB.D0.M0.i_data_in\[31:0\]" "APB_TB.D0.M0.i_addr_in\[31:0\]" \
           "APB_TB.D0.M0.i_prdata\[31:0\]" "APB_TB.D0.M0.i_pready" \
           "APB_TB.D0.M0.i_pslverr"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvAddSignal -win $_nWave3 "/APB_TB/D0/M0/i_prstn" "/APB_TB/D0/M0/i_pclk" \
           "/APB_TB/D0/M0/i_command" "/APB_TB/D0/M0/i_start" \
           "/APB_TB/D0/M0/i_data_in\[31:0\]" "/APB_TB/D0/M0/i_addr_in\[31:0\]" \
           "/APB_TB/D0/M0/i_prdata\[31:0\]" "/APB_TB/D0/M0/i_pready" \
           "/APB_TB/D0/M0/i_pslverr"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 9)}
verdiWindowResize -win $_Verdi_1 "29" "21" "1261" "762"
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
srcSetScope "APB_TB.D0.f0" -delim "." -win $_nTrace1
srcHBSelect "APB_TB.D0.f0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_gnt" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_gnt" -next -widget MTB_SOURCE_TAB_1
verdiFindBar -pattern "o_gnt" -next -widget MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "o_gnt" -line 179 -pos 1 -win $_nTrace1
srcAction -pos 178 4 3 -win $_nTrace1 -name "o_gnt" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "priority_tmp_left\[2*MASTER_COUNT-1:MASTER_COUNT\]" -line 84 \
          -pos 1 -win $_nTrace1
verdiWindowResize -win $_Verdi_1 -203 "174" "1261" "615"
verdiSetActWin -win $_nWave3
srcHBSelect "APB_TB.D0.M0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvZoomAll -win $_nWave3
verdiSetActWin -win $_nWave3
verdiWindowResize -win $_Verdi_1 "31" "118" "1261" "677"
wvZoomOut -win $_nWave3
debExit
