'''
Author: weizema
Date: 2023-07-31 19:14:24
LastEditors: weizema
LastEditTime: 2023-07-31 21:32:20
Description: 
'''
import vcu_compiler
from utils import *

vcu_compiler.get_vcu_config_insn(
    path="./insn.dat",
    adder_constant_0=int(half2bin_tensor(1),2),
    adder_constant_1=0b0,
    adder_constant_2=0b0,
    multiplication_constant_0=int(half2bin_tensor(2),2),
    multiplication_constant_1=0b0,
    multiplication_constant_2=0b0,
    compare_constant=0b0,
    para_stride=0b000000,
    fpu_work=0b1,
    resadd_para_type=0b00,
    resadd_ram_valid=0b0,
    multi_para=0b0,
    para_ram_valid=0b00,
    ram_data_out_type=1,
    ram_data_in_type=1,
    ram_out_mode=0b01,
    compute_length=0b001100010000,
    fpu=0b00000000000000001001,
    resadd_ram_in_address=0b0000000000,
    para_ram_in_address=0b00000,
    data_ram_out_address=0b000000000000,
    data_ram_in_address=0b000000000000
)

code = []

code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 0, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(4, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 3, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(5, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 2, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(15, 0, 0)))

with open("./opcode.dat", "w") as f:
    for i in code:
        f.write(i + "\n")