'''
Author: weizema
Date: 2023-08-01 18:31:28
LastEditors: weizema
LastEditTime: 2023-08-02 16:29:16
Description: 
'''
import vcu_compiler
from utils import *

vcu_compiler.get_vcu_execute_insn(
    path="./insn.dat",  # 指令文件的路径
    para_stride=0b011000011,  # 参数stride，计算64*14*14/64-1=196-1=0b011000011
    fpu_work=0b1,  # FPU需要工作
    resadd_para_type=0b00,  # 没有resadd，无所谓
    resadd_ram_valid=0b0,  # 没有resadd，设置为0
    multi_para=0b1,  # 需要使用多个para，设置为1
    para_ram_valid=0b10,  # 需要访问para ram，用于fp计算，设置为10
    ram_data_out_type=1,  # ram输出fp16类型
    ram_data_in_type=1,  # ram输入fp16类型
    ram_out_mode=0b01,  # ram输出到ofmap_ram
    compute_length=0b000110001000,  # 计算长度为64*14*14/32=392=0b000110001000
    fpu=0b00000000000000000001,  # 高10位为0，低6位为4，表示bias_add需要1条微码
    resadd_ram_in_address=0b0000000000,  # 下面的ram基地址都设置为0
    para_ram_in_address=0b00000,
    data_ram_out_address=0b000000000000,
    data_ram_in_address=0b000000000000
)

code = []

code.append(short2hex_tensor(vcu_compiler.get_vcu_code(0, 0, 4)))
code.append(short2hex_tensor(vcu_compiler.get_vcu_code(15, 0, 0)))

with open("./opcode.dat", "w") as f:
    for i in code:
        f.write(i + "\n")
