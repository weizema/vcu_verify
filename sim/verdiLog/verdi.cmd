sidCmdLineBehaviorAnalysisOpt -incr -clockSkew 0 -loopUnroll 0 -bboxEmptyModule 0  -cellModel 0 -bboxIgnoreProtected 0 
debImport "-f" "filelist.f" "-top" "vcu_tb"
nsMsgSwitchTab -tab general
debLoadSimResult /home/weizema/work/vcu_verify/sim/vcu.fsdb
wvCreateWindow
nsMsgSwitchTab -tab cmpl
wvRestoreSignal -win $_nWave2 "./signal.rc" -overWriteAutoAlias on -appendSignals \
           on
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_data_opcode" -line 68 -pos 1 -win $_nTrace1
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb.vcu" -delim "."
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_data_opcode" -line 12 -pos 1 -win $_nTrace1
srcHBSelect "vcu_tb.vcu.two_port_ram_16x1024_opcode" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb.vcu.two_port_ram_16x1024_opcode" -delim "."
srcHBSelect "vcu_tb.vcu.two_port_ram_16x1024_opcode" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_data" -line 3 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_data" -line 4 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "w_data" -line 3 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 159377.060559 -snap {("G2" 0)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb.vcu" -delim "."
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "insn" -line 3 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
nMemCreateWindow
nMemGetVariable -win $_nMem0 -var vcu_tb.vcu.two_port_ram_16x1024_opcode.mem \
           -delim . -from DUMPED_BY_SIMULATOR -addrRange {[0:1023]} \
           -wordBitRange {[15:0]} -wordsInOneRow 8
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
srcHBSelect "vcu_tb.vcu.two_port_ram_16x1024_opcode" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb.vcu.two_port_ram_16x1024_opcode" -delim "."
srcHBSelect "vcu_tb.vcu.two_port_ram_16x1024_opcode" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_addr" -line 4 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 252500.000000
wvZoom -win $_nWave2 0.000000 19269.736842
wvZoom -win $_nWave2 0.000000 1419.875346
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb.vcu" -delim "."
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_data_acc" -line 6 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 1747565.789474
wvZoom -win $_nWave2 0.000000 108073.147507
wvZoom -win $_nWave2 0.000000 10522.911731
wvZoom -win $_nWave2 0.000000 1370.747712
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
nMemGetVariable -win $_nMem0 -var vcu_tb.two_port_ram_2048x4096_acc.mem -delim . \
           -from DUMPED_BY_SIMULATOR -addrRange {[0:4095]} -wordBitRange \
           {[2047:0]} -wordsInOneRow 8
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemPrevDump -win $_nMem0
nMemPrevDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemNextDump -win $_nMem0
nMemSetTime -win $_nMem0 -time 10000
wvSetCursor -win $_nWave2 777434.210526 -snap {("G1" 4)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 1182763.157895
wvZoom -win $_nWave2 0.000000 49800.554017
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcAction -pos 5 3 7 -win $_nTrace1 -name "r_addr_acc" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_addr_acc" -line 6 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "r_en_acc" -line 6 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoom -win $_nWave2 0.000000 305657.894737
wvZoom -win $_nWave2 0.000000 15282.894737
wvZoom -win $_nWave2 0.000000 1065.780817
wvZoom -win $_nWave2 0.000000 214.558507
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
nMemCloseWindow -win $_nMem0
verdiHideWindow -win $_nMem0
srcHBSelect "vcu_tb.vcu" -win $_nTrace1
wvCreateWindow
wvSetPosition -win $_nWave4 {("G1" 0)}
wvOpenFile -win $_nWave4 {/home/weizema/work/vcu_verify/sim/vcu.fsdb}
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoom -win $_nWave4 0.000000 361764.705882
wvZoom -win $_nWave4 0.000000 21701.668437
wvZoom -win $_nWave4 0.000000 733.079074
wvScrollUp -win $_nWave4 7
wvSelectSignal -win $_nWave4 {( "vcu" 17 )} 
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvSetCursor -win $_nWave4 248.029936 -snap {("vcu" 12)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvReloadFile -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 38517.216405 -snap {("vcu" 7)}
wvSetCursor -win $_nWave4 51305.238551 -snap {("vcu" 6)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvReloadFile -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvSetCursor -win $_nWave4 6740.034450 -snap {("vcu" 20)}
wvSetCursor -win $_nWave4 7619.169378 -snap {("vcu" 20)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 4981.764593 -snap {("vcu" 21)}
wvSetCursor -win $_nWave4 19634.013397 -snap {("vcu" 20)}
wvZoom -win $_nWave4 24908.822967 38681.936842
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 9084.394258 -snap {("vcu" 20)}
wvSetCursor -win $_nWave4 235901.205742 -snap {("vcu" 24)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvReloadFile -win $_nWave4
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollUp -win $_nWave4 1
wvSetCursor -win $_nWave4 17289.653589 -snap {("vcu" 23)}
wvSetCursor -win $_nWave4 16117.473684 -snap {("vcu" 23)}
wvSetCursor -win $_nWave4 14066.158852 -snap {("vcu" 23)}
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 225058.541627 -snap {("vcu" 29)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvReloadFile -win $_nWave4
wvSetCursor -win $_nWave4 308283.314833 -snap {("vcu" 23)}
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvSetCursor -win $_nWave4 26081.002871 -snap {("vcu" 21)}
wvZoom -win $_nWave4 28718.407656 58315.950239
wvZoom -win $_nWave4 32096.937807 33229.858097
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoom -win $_nWave4 149870.718593 167910.712497
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoom -win $_nWave4 390335.908134 421691.720574
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
nMemCreateWindow
nMemGetVariable -win $_nMem1 -var vcu_tb.two_port_ram_512x4096_ofmap.mem -delim . \
           -from DUMPED_BY_SIMULATOR -addrRange {[0:4095]} -wordBitRange \
           {[511:0]} -wordsInOneRow 8
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemNextDump -win $_nMem1
nMemCloseWindow -win $_nMem1
verdiHideWindow -win $_nMem1
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvScrollDown -win $_nWave4 0
wvZoom -win $_nWave4 418761.270813 428138.710048
wvZoom -win $_nWave4 423235.264378 423901.876600
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 423468.450998 -snap {("vcu" 3)}
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoom -win $_nWave4 0.000000 27546.227751
wvZoom -win $_nWave4 0.000000 451.886170
wvZoom -win $_nWave4 3.397640 45.404830
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
srcHBSelect "vcu_tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "vcu_tb" -delim "."
srcHBSelect "vcu_tb" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "vcu_done" -line 228 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "vcu_done" -line 228 -pos 1 -win $_nTrace1
srcAction -pos 227 3 2 -win $_nTrace1 -name "vcu_done" -ctrlKey off
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvDisplayGridCount -win $_nWave4 -off
wvGetSignalClose -win $_nWave4
wvReloadFile -win $_nWave4
srcDeselectAll -win $_nTrace1
srcSelect -signal "vcu_done" -line 767 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
wvScrollDown -win $_nWave4 1
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 418986.729412 427226.635294
wvZoom -win $_nWave2 423291.444366 423752.149645
wvZoomOut -win $_nWave2
verdiDockWidgetSetCurTab -dock windowDock_nWave_4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvSetCursor -win $_nWave4 17289.653589 -snap {("vcu" 19)}
wvZoom -win $_nWave4 0.000000 14652.248804
wvZoomIn -win $_nWave4
wvZoomIn -win $_nWave4
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvZoom -win $_nWave4 490.745175 1011.535973
wvZoomOut -win $_nWave4
wvZoomOut -win $_nWave4
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollUp -win $_nWave4 1
wvScrollDown -win $_nWave4 1
debExit
