'''
Author: weizema weizema@smail.nju.edu.cn
Date: 2023-07-28 19:22:32
LastEditors: weizema weizema@smail.nju.edu.cn
LastEditTime: 2023-07-28 19:58:19
FilePath: /vcu_compiler/test/test.py
Description: 
'''
import vcu_compiler

print(vcu_compiler.get_vcu_code(0, 0, 0b100))

vcu_compiler.get_vcu_execute_insn("./insn.txt", 0, 1, 0, 0, 0, 0b10, 0,0, 0b10, 0b1100010000, 1, 0, 0, 0, 0)

000000000000
000000000000
00000
0000000000
00000000000000000001
001100010000
10 
0 
0 
10 
0 
0 
00 
1 
000000 
000000000000000000000000000000000000 
0 
100