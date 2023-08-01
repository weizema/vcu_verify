#!/bin/bash
###
 # @Author: weizema
 # @Date: 2023-07-31 10:22:03
 # @LastEditors: weizema
 # @LastEditTime: 2023-08-01 21:39:33
 # @Description: 
### 

vcs -full64 -f filelist.f \
    -top vcu_tb -R -v2005 \
    -timescale=1ns/1ns -debug_acc+dmptf \
    -debug_region+cell+encrypt+lib \
    -debug_access+all +vcd+vcdpluson +memcbk +error+999 \
    -LDFLAGS -Wl,--no-as-needed -kdb -lca -l sim.log \
    +define+DATA_NUM=1568 \
    +define+NUM_INSN=1
    