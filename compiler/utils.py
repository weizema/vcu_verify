'''
Author: weizema
Date: 2023-07-31 12:29:53
LastEditors: weizema
LastEditTime: 2023-07-31 20:35:33
Description: 
'''
import numpy as np
import struct

def short2hex_tensor(F: np.short) -> str:
    return '{:04x}'.format(struct.unpack('<H', np.short(F).tobytes())[0])

def half2bin_tensor(F: np.float16) -> str:
    return '{:016b}'.format(struct.unpack('<H', np.float16(F).tobytes())[0])