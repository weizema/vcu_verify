'''
Author: weizema
Date: 2023-07-31 19:15:12
LastEditors: weizema
LastEditTime: 2023-08-01 17:07:06
Description: 
'''
import vcu_compiler
from utils import *

vcu_compiler.get_vcu_config_insn(
    path="./insn.dat",
    adder_constant_0=int(half2bin_tensor(1),2),
    adder_constant_1=0b0,
    adder_constant_2=0b0,
    multiplication_constant_0=int(half2bin_tensor(0.044715),2),
    multiplication_constant_1=int(half2bin_tensor(np.half(np.sqrt(2 / np.pi))),2),
    multiplication_constant_2=int(half2bin_tensor(2),2),
    compare_constant=0b0,
    para_stride=0b000000, # 参数stride，不需要stride，所以为0
    fpu_work=0b1, # FPU需要工作
    resadd_para_type=0b00, # 没有resadd，无所谓
    resadd_ram_valid=0b0, # 没有resadd，设置为0
    multi_para=0b0, # 不启用与data成比例的连续para的读取
    para_ram_valid=0b10, # 要访问para ram用于fp计算，设置为10
    ram_data_out_type=1, # ram输出fp16类型
    ram_data_in_type=1, # ram输入fp16类型
    ram_out_mode=0b01, # ram输出到ofmap_ram
    compute_length=0b001100010000, # 计算长度为32*28*28/32=784=0b001100010000
    fpu=0b00000000000000010001, # 高10位为0，低6位为17，表示gelu需要18-1条微码
    resadd_ram_in_address=0b0000000000,
    para_ram_in_address=0b00000,
    data_ram_out_address=0b000000000000,
    data_ram_in_address=0b000000000000
)

code = []

code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 1, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 1, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 1, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 0, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 2, 1)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 2, 2)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(4, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 3, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(3, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(5, 2, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 2, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 3, 0)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 0, 3)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(1, 2, 4)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(15, 0, 0)))

with open("./opcode.dat", "w") as f:
    for i in code:
        f.write(i + "\n")