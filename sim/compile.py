'''
Author: weizema
Date: 2023-07-30 20:06:46
LastEditors: weizema
LastEditTime: 2023-07-30 20:07:17
Description: 
'''
import vcu_compiler

vcu_compiler.get_vcu_execute_insn(
    "./insn.dat", 
    para_stride=0b000000,
    fpu_work=0b1,
    resadd_para_type=0b00,
    resadd_ram_valid=0b0,
    multi_para=0b0,
    para_ram_valid=0b10,
    ram_data_out_type=0,
    ram_data_in_type=0,
    ram_out_mode=0b10,
    compute_length=0b001100010000,
    fpu=0b00000000000000000001,
    resadd_ram_in_address=0b0000000000,
    para_ram_in_address=0b00000,
    data_ram_out_address=0b000000000000,
    data_ram_in_address=0b000000000000)