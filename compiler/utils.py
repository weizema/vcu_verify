'''
Author: weizema
Date: 2023-07-31 12:29:53
LastEditors: weizema
LastEditTime: 2023-07-31 12:30:18
Description: 
'''
import numpy as np
import struct

def short2hex_tensor(F: np.short) -> str:
    return '{:04x}'.format(struct.unpack('<H', np.short(F).tobytes())[0])