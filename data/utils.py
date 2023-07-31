import numpy as np
import struct
import math
import torch
import torch.nn.functional as F
from typing import Optional


def int2hex_tensor(F: np.int32) -> str:
    return '{:08x}'.format(struct.unpack('<I', np.int32(F).tobytes())[0])


def int2bin_tensor(F: np.int32) -> str:
    return '{:032b}'.format(struct.unpack('<I', np.int32(F).tobytes())[0])


def half2hex_tensor(F: np.float16) -> str:
    return '{:04x}'.format(struct.unpack('<H', np.float16(F).tobytes())[0])


def half2bin_tensor(F: np.float16) -> str:
    return '{:016b}'.format(struct.unpack('<H', np.float16(F).tobytes())[0])


def char2hex_tensor(F: np.int8) -> str:
    return '{:02x}'.format(struct.unpack('<B', np.int8(F).tobytes())[0])


def char2bin_tensor(F: np.int8) -> str:
    return '{:08b}'.format(struct.unpack('<B', np.int8(F).tobytes())[0])


def short2bin_tensor(F: np.short) -> str:
    return '{:016b}'.format(struct.unpack('<H', np.short(F).tobytes())[0])


def short2hex_tensor(F: np.short) -> str:
    return '{:04x}'.format(struct.unpack('<H', np.short(F).tobytes())[0])


def fp_to_bit(fp):
    x = '{:016b}'.format(struct.unpack('<H', np.float16(fp).tobytes())[0])
    sign_str = x[0]
    exp_str = x[1:6]
    frac_str = x[6:]
    return sign_str, exp_str, frac_str


def bit_to_value(sign_str, exp_str, frac_str):
    if exp_str == "00000" and frac_str == "0000000000":
        fp_value = 0
    else:
        if len(exp_str) != 5:
            print("指数段位宽错误")
        if len(frac_str) != 10:
            print("尾数段位宽错误")

        if int(exp_str, 2) > int("11110", 2):
            exp_str = "11110"
            frac_str = "1111111111"
            print("上溢出")

        frac = int(frac_str, 2)
        if exp_str == "00000":
            exp = -14
            fp_value = math.pow(2, exp)*(frac/1024)
        else:
            exp = int(exp_str, 2)-15
            fp_value = math.pow(2, exp)*(1+frac/1024)

        if sign_str == "0":
            fp_value = fp_value
        if sign_str == "1":
            fp_value = -fp_value
    return fp_value


def shiftbinary(x, number):  # x表示二进制输入，number表示移位的数量,number大于0时表示左移，number小于0时表示右移
    zero = ""
    length = len(x)
    for i in range(min(abs(number), length)):
        zero = zero+"0"
    if number >= 0:
        result = x[abs(number):]+zero
    if number < 0:
        result = zero+x[:number]
    if len(x) != len(result):
        print("位宽错误")
    return result


def addbinary(x, y):  # x,y都是二进制字符串输入,支持23位的加法，范围外按照溢出处理
    x = int(x, 2)
    y = int(y, 2)
    result = x+y
    result = "{:024b}".format(result)
    if int(result[0]) == 1:
        print("overflow")
    result = result[1:]
    return result


def addbinary_negative(x, y):  # x,y都是二进制字符串输入,支持23位的加法，范围外按照溢出处理
    x = int(x, 2)
    y = int(y, 2)
    result = x-y
    result = "{:024b}".format(result)
    if int(result[0]) == 1:
        print("overflow")
    result = result[1:]
    return result
# 此函数为FP16乘法运算的标准函数，与numpy内置乘法16位比特级相同
# 仅支持规格化数与+0值，上溢出规格化为最大值，下溢出规格化为最小值，不存在NAN,支持非规格化数字


def multiplication_noloss_all(a, b, debug):  # a,b都是浮点数输入，执行浮点数乘法，范围外按照溢出处理
    if a == 0 or b == 0:
        result = 0
        result_sign = "0"
        result_exp = "00000"
        result_frac = "0000000000"
    else:
        a_sign, a_exp, a_frac = fp_to_bit(a)
        b_sign, b_exp, b_frac = fp_to_bit(b)

        if a_exp == "00000":
            a_exp = 1
            a_frac = "0"+a_frac
        else:
            a_exp = int(a_exp, 2)
            a_frac = "1"+a_frac

        if b_exp == "00000":
            b_exp = 1
            b_frac = "0"+b_frac
        else:
            b_exp = int(b_exp, 2)
            b_frac = "1"+b_frac

        # 获得结果的符号位
        if int(a_sign, 2) == int(b_sign, 2):
            result_sign = "0"
        else:
            result_sign = "1"
        result_exp = a_exp+b_exp-15  # 获得没有进位的指数，该数为有符号数,int类型

        result_frac = int(a_frac, 2)*int(b_frac, 2)
        result_frac = "{:022b}".format(result_frac)  # str类型,2位正数部分，20位小数部分

        if debug == 1:
            print(result_exp)
            print(result_frac)
        # ----------------------------
        if len(result_frac) != 22:
            print("尾数乘法位宽出错")

        # ----------------------------

        if result_frac[0:3] == "001":
            shift_number = 1
        elif result_frac[0:4] == "0001":
            shift_number = 2
        elif result_frac[0:5] == "00001":
            shift_number = 3
        elif result_frac[0:6] == "000001":
            shift_number = 4
        elif result_frac[0:7] == "0000001":
            shift_number = 5
        elif result_frac[0:8] == "00000001":
            shift_number = 6
        elif result_frac[0:9] == "000000001":
            shift_number = 7
        elif result_frac[0:10] == "0000000001":
            shift_number = 8
        elif result_frac[0:11] == "00000000001":
            shift_number = 9
        elif result_frac[0:12] == "000000000001":  # 这里因为是乘法，所以小数点后10位内一定会出现1
            shift_number = 10
        else:
            shift_number = 0  # 这句的意思是没有其他情况了

        result_exp = result_exp-shift_number
        result_frac = shiftbinary(result_frac, shift_number)

        result_frac = result_frac + "0000000000"

        if debug == 1:
            print(result_exp)
            print(result_frac)

        if result_exp > 0:
            # 这代表这个数可以规格化表示
            if result_frac[0] == "1":
                result_exp = result_exp + 1
                retain_frac = "0"+result_frac[0:11]
                truncation_frac = result_frac[11:]
            else:
                result_exp = result_exp
                retain_frac = result_frac[0:12]
                truncation_frac = result_frac[12:]+"0"
        else:
            # 这代表这个数只能非规格化表示
            result_frac = shiftbinary(result_frac, result_exp)
            result_exp = 0
            # print(result_frac)
            retain_frac = "0"+result_frac[0:11]
            truncation_frac = result_frac[11:]

        if debug == 1:
            print(result_exp)
            print(result_frac)
            print(truncation_frac)
            print(retain_frac)

        # ----------------------------
        if len(retain_frac) != 12:
            print("尾数保留位宽出错")
        if len(truncation_frac) != 21:
            print("尾数保留位宽出错")
        # ----------------------------
        # print("retain_frac",retain_frac)
        # print("truncation_frac",truncation_frac)

        if int(truncation_frac, 2) > int("100000000000000000000", 2):
            result_frac = "{:012b}".format(int(retain_frac, 2)+1)
        elif int(truncation_frac, 2) == int("100000000000000000000", 2):
            if retain_frac[11] == "1":
                result_frac = "{:012b}".format(int(retain_frac, 2)+1)
            else:
                result_frac = retain_frac
        else:
            result_frac = retain_frac

        # print(result_frac)
        # ----------------------------
        if len(result_frac) != 12:
            print("尾数舍入位宽出错")
        # ----------------------------
        if result_exp == 0:
            if result_frac[1] == "1":
                result_exp = result_exp + 1
                result_frac = result_frac[2:]
            else:
                result_exp = result_exp
                result_frac = result_frac[2:]
        else:
            if result_frac[0] == "1":
                result_exp = result_exp + 1
                result_frac = result_frac[1:11]
            else:
                result_exp = result_exp
                result_frac = result_frac[2:]

        # ----------------------------
        if len(result_frac) != 10:
            print("尾数位宽第二次舍入出错")
        # ----------------------------
        # print(result_frac)
        # 第三次舍入，结果指数的上下溢出判断
        if result_exp > int("11110", 2):
            result_exp = "11110"
            result_frac = "1111111111"
        else:
            result_exp = "{:05b}".format(result_exp)
            result_exp = result_exp[-5:]
        # ----------------------------
        if len(result_exp) != 5:
            print("指数段舍入出错")
        # ----------------------------
        # print(result_sign,result_exp,result_frac)
        result = bit_to_value(result_sign, result_exp, result_frac)
    return result, result_sign, result_exp, result_frac
# 当前版本函数，支持规格化数和非规格化数，和python内置加法输出保持bit级别一致


def addition_noloss_all(data1, data2, debug):
    data1_signal, data1_exp, data1_mantissa = fp_to_bit(data1)
    data2_signal, data2_exp, data2_mantissa = fp_to_bit(data2)
    if int(data1_exp+data1_mantissa, 2) >= int(data2_exp+data2_mantissa, 2):
        data_max = data1
        data_min = data2
        signal_max = data1_signal
        exp_max = data1_exp
        mantissa_max = data1_mantissa
        signal_min = data2_signal
        exp_min = data2_exp
        mantissa_min = data2_mantissa
    else:
        data_max = data2
        data_min = data1
        signal_max = data2_signal
        exp_max = data2_exp
        mantissa_max = data2_mantissa
        signal_min = data1_signal
        exp_min = data1_exp
        mantissa_min = data1_mantissa

    if exp_max == "00000":
        exp_max_1 = "00001"
        frac_max = "00"+mantissa_max+"00000000000"
    else:
        exp_max_1 = exp_max
        frac_max = "01"+mantissa_max+"00000000000"

    if exp_min == "00000":
        exp_min_1 = "00001"
        frac_min = "00"+mantissa_min+"00000000000"
    else:
        exp_min_1 = exp_min
        frac_min = "01"+mantissa_min+"00000000000"  # 11位应该足够保存信息了

    shift_number = int(exp_max_1, 2) - int(exp_min_1, 2)  # 向大数靠齐 相等or有正值
    frac_min = shiftbinary(frac_min, -shift_number)
    if debug == 1:
        print(frac_min)

    flag = (int(signal_max, 2) != int(signal_min, 2))
    result_signal = signal_max

    if flag == 0:
        result_frac = addbinary(frac_max, frac_min)
    else:
        result_frac = addbinary_negative(frac_max, frac_min)  # 23位
    if debug == 1:
        print("result_frac:", result_frac)

    # print(len(result_frac))
    # 提出（左移）一个1到小数点前面，用以判断这个数能否规格化表示
    if result_frac[0:2] == "01":
        shift_number = 0
    elif result_frac[0:3] == "001":
        shift_number = 1
    elif result_frac[0:4] == "0001":
        shift_number = 2
    elif result_frac[0:5] == "00001":
        shift_number = 3
    elif result_frac[0:6] == "000001":
        shift_number = 4
    elif result_frac[0:7] == "0000001":
        shift_number = 5
    elif result_frac[0:8] == "00000001":
        shift_number = 6
    elif result_frac[0:9] == "000000001":
        shift_number = 7
    elif result_frac[0:10] == "0000000001":
        shift_number = 8
    elif result_frac[0:11] == "00000000001":
        shift_number = 9
    elif result_frac[0:12] == "000000000001":
        shift_number = 10
    elif result_frac[0:13] == "0000000000001":  # 这句的意思是小数点后11位中必然存在1
        shift_number = 11
    else:
        shift_number = 0  # 此处待验证，意思是没有其他情况了

    postshift_exp = int(exp_max_1, 2)-shift_number
    postshift_frac = shiftbinary(result_frac, shift_number)
    if debug == 1:
        print("postshift_exp:", postshift_exp)
        print("postshift_frac:", postshift_frac)

    if len(postshift_frac) != 23:
        print("postshift_frac lenth error")

    # 此处判断是规格化数还是非规格化数
    if postshift_exp > 0:
        # 这代表这个数可以规格化表示
        if result_frac[0] == "1":
            postshift_exp = postshift_exp + 1
            retain_frac = "0"+postshift_frac[0:11]
            truncation_frac = postshift_frac[11:]
        else:
            postshift_exp = postshift_exp
            retain_frac = postshift_frac[0:12]
            truncation_frac = postshift_frac[12:]+"0"
    else:
        # 这代表这个数此时只能非规格化表示
        postshift_frac = shiftbinary(postshift_frac, postshift_exp)
        postshift_exp = 0
        # print(postshift_frac)
        retain_frac = "0"+postshift_frac[0:11]
        truncation_frac = postshift_frac[11:]

    truncation_frac = truncation_frac + "0000000000"
    if debug == 1:
        print("retain_frac:", retain_frac)
        print("truncation_frac:", truncation_frac)
    # ----------------------------
    if len(retain_frac) != 12:
        print("尾数保留位宽出错")
    if len(truncation_frac) != 22:  # 此处位宽比乘法多了1位
        print("尾数截断位宽出错")
    # ----------------------------

    if int(truncation_frac, 2) > int("1000000000000000000000", 2):
        # 这里是默认了最高位1时。即1x.xxx时不可能再进位到更高位
        round_off_frac = "{:012b}".format(int(retain_frac, 2)+1)
    elif int(truncation_frac, 2) == int("1000000000000000000000", 2):
        if retain_frac[11] == "1":
            round_off_frac = "{:012b}".format(int(retain_frac, 2)+1)
        else:
            round_off_frac = retain_frac
    else:
        round_off_frac = retain_frac
    if debug == 1:
        print("round_off_frac:", round_off_frac)

    if postshift_exp == 0:
        if round_off_frac[1] == "1":
            postshift_round_off_exp = postshift_exp + 1
            postshift_round_off_mantissa = round_off_frac[2:]
        else:
            postshift_round_off_exp = postshift_exp
            postshift_round_off_mantissa = round_off_frac[2:]
    else:
        if round_off_frac[0] == "1":
            postshift_round_off_exp = postshift_exp + 1
            postshift_round_off_mantissa = round_off_frac[1:11]
        else:
            postshift_round_off_exp = postshift_exp
            postshift_round_off_mantissa = round_off_frac[2:]

    # ----------------------------
    if len(postshift_round_off_mantissa) != 10:
        print("尾数位宽第二次舍入出错")
    # ----------------------------

    if data_min == 0:
        result = data_max
        result_signal = signal_max
        result_exp = exp_max
        result_mantissa = mantissa_max
    elif signal_max != signal_min and exp_max == exp_min and mantissa_max == mantissa_min:
        result = 0
        result_signal = "0"
        result_exp = "00000"
        result_mantissa = "0000000000"
    else:
        if postshift_round_off_exp >= 31:
            result_exp = "11110"
            result_mantissa = "1111111111"
        else:
            result_exp = "{:05b}".format(postshift_round_off_exp)
            result_mantissa = postshift_round_off_mantissa

    result = bit_to_value(result_signal, result_exp, result_mantissa)

    return result, result_signal, result_exp, result_mantissa


def int32tofp16(int32, shift):
    if int32[0] == "0":
        int33 = "0"+int32
    else:
        int31_list = list(int32[1:])
        for i in range(31):
            if int31_list[i] == "0":
                int31_list[i] = "1"
            else:
                int31_list[i] = "0"
        int31_str = "".join(int31_list)
        int33 = "1"+"{:032b}".format(int(int31_str, 2)+1)
#         print(len(int33))
#         print(int33)

    int33_value = math.pow(-1, int(int33[0]))*int(int33[1:], 2)
    int33_shift_value = int33_value/math.pow(2, shift)
    signal, exp, mantissa = fp_to_bit(int33_shift_value)
    return int33_value, int33_shift_value, signal, exp, mantissa


def int8tofp16(int8):
    if int8[0] == "0":
        int9 = "0"+int8
    else:
        int7_list = list(int8[1:])
        for i in range(7):
            if int7_list[i] == "0":
                int7_list[i] = "1"
            else:
                int7_list[i] = "0"
        int7_str = "".join(int7_list)
        int9 = "1"+"{:08b}".format(int(int7_str, 2)+1)
#     print(int9)

    int9_value = math.pow(-1, int(int9[0], 2))*int(int9[1:], 2)
    signal, exp, mantissa = fp_to_bit(int9_value)
    fp16_value = bit_to_value(signal, exp, mantissa)
    return int9_value, fp16_value, signal, exp, mantissa


def fp16_to_int8(signal, exp, mantissa):
    fp16_value = bit_to_value(signal, exp, mantissa)
    int8_temp = round(fp16_value)
    if int8_temp >= 128:
        int8_value = 127
    elif int8_temp < -128:
        int8_value = -128
    else:
        int8_value = int8_temp

    int8 = '{:08b}'.format(struct.unpack('<B', np.int8(int8_value))[0])
    return fp16_value, int8_value, int8


def fp_to_binary(x):  # 用于对于0<x<1的小数，获取其源码
    if x > 1 or x < 0:
        print("error")
        return 0
    elif x == 1:
        result = "00000000000000000000"
    else:
        result = ""
        for i in range(20):
            x = x*2
            if x >= 1:
                result = result+"1"
                x = x-1
            else:
                result = result+"0"
    return result


def int2comp15(x: int):  # 输入一个int值，返回其15位补码，其中第一位是符号位,溢出时直接截断
    if x >= 0:
        result = "0"
        result = result+"{:014b}".format(x)[-14:]
    elif x < 0:
        if x == -math.pow(2, 14):
            result = "100000000000000"
        else:
            x = -x
            result = "1"
            binary = "{:014b}".format(x)[-14:]
            comp = ""
            for i in range(14):
                if binary[i] == "1":
                    comp = comp+"0"
                elif binary[i] == "0":
                    comp = comp+"1"
            comp = "{:014b}".format(int(comp, 2)+1)[-14:]
            result = result + comp
    return result


def comp2int(x: str):  # 输入15位补码，输出int值
    if x == "100000000000000":
        result = -int(math.pow(2, 14))
    if x[0] == "0":
        result = int(x, 2)
    if x[0] == "1":
        comp = x[1:]
        comp = "{:014b}".format(int(comp, 2)-1)[-14:]
        ori = ""
        for i in range(14):
            if comp[i] == "1":
                ori = ori+"0"
            elif comp[i] == "0":
                ori = ori+"1"
        result = -int(ori, 2)
    return result


def QDS2(P: str, D: str):
    if P == "011111":
        print("q error")
    elif P == "011110":
        print("q error")
    elif P == "011101":
        print("q error")
    elif P == "011100":
        print("q error")
    elif P == "011011":
        print("q error")
    elif P == "011010":
        print("q error")
    elif P == "011001":
        print("q error")
    elif P == "011000":
        print("q error")
    elif P == "010111":
        print("q error")
    elif P == "010110":
        print("q error")
    elif P == "010101":
        q = 2
    elif P == "010100":
        q = 2
    elif P == "010011":
        q = 2
    elif P == "010010":
        q = 2
    elif P == "010001":
        q = 2
    elif P == "010000":
        q = 2
    elif P == "001111":
        q = 2
    elif P == "001110":
        q = 2
    elif P == "001101":
        q = 2
    elif P == "001100":
        q = 2
    elif P == "001011":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110":
            q = 2
        elif D == "1111":
            q = 1
    elif P == "001010":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110":
            q = 2
        elif D == "1111":
            q = 1
    elif P == "001001":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011":
            q = 2
        elif D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 1
    elif P == "001000":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011":
            q = 2
        elif D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 1
    elif P == "000111":
        if D == "1000" or D == "1001":
            q = 2
        elif D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 1
    elif P == "000110":
        if D == "1000":
            q = 2
        elif D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 1
    elif P == "000101":
        q = 1
    elif P == "000100":
        q = 1
    elif P == "000011":
        q = 1
    elif P == "000010":
        if D == "1000" or D == "1001" or D == "1010":
            q = 1
        elif D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 0
    elif P == "000001":
        q = 0
    elif P == "000000":
        q = 0
    elif P == "111111":
        q = 0
    elif P == "111110":
        q = 0
    elif P == "111101":
        if D == "1000" or D == "1001" or D == "1010":
            q = -1
        elif D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = 0
    elif P == "111100":
        q = -1
    elif P == "111011":
        q = -1
    elif P == "111010":
        q = -1
    elif P == "111001":
        if D == "1000":
            q = -2
        elif D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = -1
    elif P == "111000":
        if D == "1000" or D == "1001":
            q = -2
        elif D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = -1
    elif P == "110111":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011":
            q = -2
        elif D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = -1
    elif P == "110110":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011":
            q = -2
        elif D == "1100" or D == "1101" or D == "1110" or D == "1111":
            q = -1
    elif P == "110101":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110":
            q = -2
        elif D == "1111":
            q = -1
    elif P == "110100":
        if D == "1000" or D == "1001" or D == "1010" or D == "1011" or D == "1100" or D == "1101" or D == "1110":
            q = -2
        elif D == "1111":
            q = -1
    elif P == "110011":
        q = -2
    elif P == "110010":
        q = -2
    elif P == "110001":
        q = -2
    elif P == "110000":
        q = -2
    elif P == "101111":
        q = -2
    elif P == "101110":
        q = -2
    elif P == "101101":
        q = -2
    elif P == "101100":
        q = -2
    elif P == "101011":
        q = -2
    elif P == "101010":
        print("q error")
    elif P == "101001":
        print("q error")
    elif P == "101000":
        print("q error")
    elif P == "100111":
        print("q error")
    elif P == "100110":
        print("q error")
    elif P == "100101":
        print("q error")
    elif P == "100100":
        print("q error")
    elif P == "100011":
        print("q error")
    elif P == "100010":
        print("q error")
    elif P == "100001":
        print("q error")
    elif P == "100000":
        print("q error")
    return q


def reciprocal(data, debug):
    data_signal, data_exp, data_mantissa = fp_to_bit(data)

    if data_exp == "00000":
        if data_mantissa[0:2] == "11" or data_mantissa[0:2] == "10":
            data_exp = 0
            data_mantissa = shiftbinary(data_mantissa, 1)
        elif data_mantissa[0:2] == "01":
            data_exp = -1
            data_mantissa = shiftbinary(data_mantissa, 2)
        else:
            data_exp = -2
            data_mantissa = data_mantissa
    else:
        data_exp = int(data_exp, 2)
        data_mantissa = data_mantissa

    # 结果符号段确定
    result_signal = data_signal

    # 结果指数段确定
    result_exp = 29-data_exp

    # 结果尾数段确定
    divisor = "1" + data_mantissa  # 除数为1+尾数段
    dividend = "10000000000"  # 被除数始终是1

    # 数据预处理与归一化,这里需要保证dividend<2d/3,这个约束条件可以认为是默认的f
    dividend = "0000" + dividend  # 小数点前2位以及一位符号位即0 00.010000000000
    divisor = "000" + divisor+"0"  # 小数点前2位以及一位符号位即0 00.1xxxxxx0f

    w = []  # 中间部分和结果
    q = []  # int
    for i in range(20):
        w.append(0)
    for i in range(15):
        q.append(0)

    d = divisor
    D = d[3:7]  # 五位0.1xxx 这里应该可以优化
    w[0] = dividend  # 初始化被除数dividend位第一个部分和结果

    for i in range(8):
        shift_w = shiftbinary(w[i], 2)
        if debug == 1:
            print("w[i] = ", w[i])
            print("shift_w = ", shift_w)
        P = shift_w[0:6]
        if debug == 1:
            print("P = ", P)
        q[i] = QDS2(P, D)
        if debug == 1:
            print("q = ", q)
        w[i+1] = comp2int(shift_w)-q[i]*int(d[1:], 2)
        if debug == 1:
            print("w[i+1] = ", w[i+1])
        w[i+1] = int2comp15(w[i+1])
        if debug == 1:
            print("w[i+1] = ", w[i+1])

    # 将冗余结果修正,快速结果转化On-the-Fly Conversion
    if q[0] <= 0:
        print(q[0])
        print("q[0] error")
    for i in range(len(q)):
        if q[-i-1] < 0:
            q[-i-2] = q[-i-2]-1
            q[-i-1] = q[-i-1]+4

    # 将结果转化为binary
    frac = ""
    for i in q:
        if i == 0:
            frac = frac + "00"
        elif i == 1:
            frac = frac + "01"
        elif i == 2:
            frac = frac + "10"
        elif i == 3:
            frac = frac + "11"
    if debug == 1:
        print("frac = ", frac)

    if result_exp <= 0:
        frac = shiftbinary(frac, result_exp-1)
        result_exp = 0
        if frac[1] == "1":
            result_exp = result_exp+1

    # 舍入模块
    result_mantissa = ""
    if frac[12] == "0":
        frac = frac[0:12]
    elif frac[12] == "1":
        frac = "{:012b}".format(int(frac[0:12], 2)+1)

    # 规格化数舍入后的进位处理
    if frac[0] == "1":
        result_exp = result_exp + 1
        result_mantissa = frac[1:11]
    else:
        result_mantissa = frac[2:]

    # 溢出处理
    if result_exp > 30:
        result_mantissa = "1111111111"
        result_exp = 30

    result_exp = "{:05b}".format(result_exp)

    result = bit_to_value(result_signal, result_exp, result_mantissa)
    return result, result_signal, result_exp, result_mantissa


def invertion(data, debug):
    data_signal, data_exp, data_mantissa = fp_to_bit(data)
    if (data_signal == "0"):
        result_signal = "1"
    else:
        result_signal = "0"
    result_exp = data_exp
    result_mantissa = data_mantissa
    result = bit_to_value(result_signal, result_exp, result_mantissa)
    return result, result_signal, result_exp, result_mantissa


def addition_simple(data1, data2, debug):
    data1_signal, data1_exp, data1_mantissa = fp_to_bit(data1)
    data2_signal, data2_exp, data2_mantissa = fp_to_bit(data2)
    if int(data1_exp+data1_mantissa, 2) >= int(data2_exp+data2_mantissa, 2):
        data_max = data1
        data_min = data2
        signal_max = data1_signal
        exp_max = data1_exp
        mantissa_max = data1_mantissa
        signal_min = data2_signal
        exp_min = data2_exp
        mantissa_min = data2_mantissa
    else:
        data_max = data2
        data_min = data1
        signal_max = data2_signal
        exp_max = data2_exp
        mantissa_max = data2_mantissa
        signal_min = data1_signal
        exp_min = data1_exp
        mantissa_min = data1_mantissa
    if debug == 1:
        print("mantissa_max", mantissa_max)
        print("mantissa_min", mantissa_min)
    frac_max = "01"+mantissa_max+"00000000000"
    frac_min = "01"+mantissa_min+"00000000000"

    shift_number = int(exp_max, 2) - int(exp_min, 2)  # 向大数靠齐 相等or有正值
    frac_min = shiftbinary(frac_min, -shift_number)

    if debug == 1:
        print("shift_number_min", shift_number)
        print(frac_min)

    flag = (int(signal_max, 2) != int(signal_min, 2))
    result_signal = signal_max

    if flag == 0:
        result_frac = addbinary(frac_max, frac_min)
    else:
        result_frac = addbinary_negative(frac_max, frac_min)  # 23位
    if debug == 1:
        print("result_frac:", result_frac)

    # 提出（左移）一个1到小数点前面，用以判断这个数能否规格化表示
    if result_frac[0:2] == "01":
        shift_number = 0
    elif result_frac[0:3] == "001":
        shift_number = 1
    elif result_frac[0:4] == "0001":
        shift_number = 2
    elif result_frac[0:5] == "00001":
        shift_number = 3
    elif result_frac[0:6] == "000001":
        shift_number = 4
    elif result_frac[0:7] == "0000001":
        shift_number = 5
    elif result_frac[0:8] == "00000001":
        shift_number = 6
    elif result_frac[0:9] == "000000001":
        shift_number = 7
    elif result_frac[0:10] == "0000000001":
        shift_number = 8
    elif result_frac[0:11] == "00000000001":
        shift_number = 9
    elif result_frac[0:12] == "000000000001":
        shift_number = 10
    elif result_frac[0:13] == "0000000000001":  # 这句的意思是小数点后11位中必然存在1
        shift_number = 11
    else:
        shift_number = 0  # 此处待验证，意思是没有其他情况了

    postshift_exp = int(exp_max, 2)-shift_number
    postshift_frac = shiftbinary(result_frac, shift_number)
    if debug == 1:
        print("shift_number", shift_number)
        print("postshift_exp:", postshift_exp)
        print("postshift_frac:", postshift_frac)

    if len(postshift_frac) != 23:
        print("postshift_frac lenth error")

    # 第一次舍入，判断结果尾数的第13位 2_10_1
    if postshift_frac[12] == "1":
        retain_frac = int(postshift_frac[0:12], 2) + 1
        retain_frac = "{:012b}".format(retain_frac)
    else:
        retain_frac = postshift_frac[0:12]
    if debug == 1:
        print("retain_frac", retain_frac)

    # 第二次舍入,判断结果尾数的第1位
    if retain_frac[0] == "1":
        result_exp = postshift_exp + 1
        result_frac = retain_frac[1:11]
    else:
        result_exp = postshift_exp
        result_frac = retain_frac[2:]
    if debug == 1:
        print("result_frac", result_frac)

    # ----------------------------
    if len(result_frac) != 10:
        print("尾数位宽第二次舍入出错")
    # ----------------------------

    if (result_exp >= 31):
        result_exp = 30
        result_frac = "1111111111"
    elif (result_exp <= 0):
        result_exp = 1
        result_frac = "0000000000"
    else:
        result_exp = result_exp
        result_frac = result_frac

    # 特殊情况处理
    if data_min == 0:
        result = data_max
        result_signal = signal_max
        result_exp = exp_max
        result_mantissa = mantissa_max
    elif signal_max != signal_min and exp_max == exp_min and mantissa_max == mantissa_min:
        result = 0
        result_signal = "0"
        result_exp = "00000"
        result_mantissa = "0000000000"
    else:
        result_exp = "{:05b}".format(result_exp)
        result_mantissa = result_frac

    result = bit_to_value(result_signal, result_exp, result_mantissa)

    return result, result_signal, result_exp, result_mantissa


para = 1/(math.log(math.e, 2))
para_signal, para_exp, para_mantissa = fp_to_bit(para)
para = bit_to_value(para_signal, para_exp, para_mantissa)

index_list_ln_128 = []
result_list_ln_128 = []
ln_look_up_table_ln_128 = {}

for i in range(0, 128):
    index_128 = "{:07b}".format(i)
    index_list_ln_128.append(index_128)
    data_1 = (int(index_128+"000", 2)/1024)+1
    result_1 = math.log(data_1, math.e)
    data_2 = (int(index_128+"001", 2)/1024)+1
    result_2 = math.log(data_2, math.e)
    data_3 = (int(index_128+"010", 2)/1024)+1
    result_3 = math.log(data_3, math.e)
    data_4 = (int(index_128+"011", 2)/1024)+1
    result_4 = math.log(data_4, math.e)
    data_5 = (int(index_128+"100", 2)/1024)+1
    result_5 = math.log(data_5, math.e)
    data_6 = (int(index_128+"101", 2)/1024)+1
    result_6 = math.log(data_6, math.e)
    data_7 = (int(index_128+"110", 2)/1024)+1
    result_7 = math.log(data_7, math.e)
    data_8 = (int(index_128+"111", 2)/1024)+1
    result_8 = math.log(data_8, math.e)
    result_128 = (result_1+result_2+result_3+result_4 +
                  result_5+result_6+result_7+result_8)/8
    a, b, c = fp_to_bit(result_128)
    result_128 = bit_to_value(a, b, c)
    result_list_ln_128.append(result_128)

ln_look_up_table_ln_128 = dict(zip(index_list_ln_128, result_list_ln_128))

index_list_exp_15 = []
result_list_exp_15 = []
ln_look_up_table_exp_15 = {}

for i in range(1, 31):
    exp = "{:05b}".format(i)
    index_list_exp_15.append(exp)
    exp_15_result = para*(i-15)
    signal, exp, mantissa = fp_to_bit(exp_15_result)
    exp_15_result = bit_to_value(signal, exp, mantissa)
    result_list_exp_15.append(exp_15_result)

ln_look_up_table_exp_15 = dict(zip(index_list_exp_15, result_list_exp_15))

index_list = []
result_list = []
look_up_table_special_01111 = {}
for i in range(65):
    exp = "01111"
    mantissa = "000"+"{:07b}".format(i)
    index_list.append(mantissa)
    data = bit_to_value("0", exp, mantissa)
    result = math.log(data, math.e)
    a, b, c = fp_to_bit(result)
    result = bit_to_value(a, b, c)
    result_list.append(result)
look_up_table_special_01111 = dict(zip(index_list, result_list))

index_list = []
result_list = []
look_up_table_special_01110 = {}
for i in range(65):
    exp = "01110"
    mantissa = "{:010b}".format(1023-i)
    index_list.append(mantissa)
    data = bit_to_value("0", exp, mantissa)
    result = math.log(data, math.e)
    a, b, c = fp_to_bit(result)
    result = bit_to_value(a, b, c)
    result_list.append(result)
look_up_table_special_01110 = dict(zip(index_list, result_list))


def ln(data, debug):

    data_signal, data_exp, data_mantissa = fp_to_bit(data)

    if (data_exp == "00000"):
        data_exp = "00001"
        data_mantissa = "0000000000"
    else:
        data_exp = data_exp
        data_mantissa = data_mantissa

    mantissa_look_up_index = data_mantissa[0:7]
    mantissa_look_up_result = ln_look_up_table_ln_128[mantissa_look_up_index]
    exp_look_up_result = ln_look_up_table_exp_15[data_exp]

    if debug == 1:
        print("ln", mantissa_look_up_index)
        print("ln", mantissa_look_up_result)
        print("ln", data_exp)
        print("ln", exp_look_up_result)

    result, _, _, _ = addition_simple(
        mantissa_look_up_result, exp_look_up_result, 0)

    if (data_exp == "01111" and int(data_mantissa, 2) <= int("0001000000", 2)):
        result = look_up_table_special_01111[data_mantissa]
    elif (data_exp == "01110" and int(data_mantissa, 2) >= int("1110111111", 2)):
        result = look_up_table_special_01110[data_mantissa]
    else:
        result = result

    result_signal, result_exp, result_mantissa = fp_to_bit(result)

    return result, result_signal, result_exp, result_mantissa


def addbinary_exp(x, y):  # x,y都是二进制字符串输入,支持15位以内的加法，范围外按照溢出处理
    x = int(x, 2)
    y = int(y, 2)
    result = x+y
    result = "{:016b}".format(result)
    if int(result[0]) == 1:
        print("overflow")
    result = result[1:]
    return result


def addbinary_negative_exp(x, y):  # x,y都是二进制字符串输入,支持15位以内的加法，范围外按照溢出处理
    x = int(x, 2)
    y = int(y, 2)
    result = x-y
    result = "{:016b}".format(result)
    if int(result[0]) == 1:
        print("overflow")
    result = result[1:]
    return result


def comp_value(x):  # 针对正数的补偿值
    if (len(x) != 3):
        print("error")
    if x == "000":
        result = "0000"
    if x == "001":
        result = "0001"
    if x == "010":
        result = "0010"
    if x == "011":
        result = "0100"
    if x == "100":
        result = "0101"
    if x == "101":
        result = "0110"
    if x == "110":
        result = "1000"
    if x == "111":
        result = "1010"
    return result


def multiplication_exp(a, b):  # a,b都是浮点数输入，执行浮点数乘法，范围外按照溢出处理
    if a == 0 or b == 0:
        result = 0
    else:
        a_sign, a_exp, a_frac = fp_to_bit(a)
        b_sign, b_exp, b_frac = fp_to_bit(b)

        result_sign = int(a_sign, 2) & int(b_sign, 2)  # 获得结果的符号位
        result_exp = int(a_exp, 2)+int(b_exp, 2)-15  # 获得没有进位的指数符号

        a_frac = "1"+a_frac
        b_frac = "1"+b_frac

        result_frac = int(a_frac, 2)*int(b_frac, 2)
        result_frac = "{:022b}".format(result_frac)
        # print(result_frac)
        # ----------------------------
        if len(result_frac) != 22:
            print("尾数乘法位宽出错")
        # ----------------------------

        # 第一次舍入，判断结果尾数的第13位 2_10_1
        if result_frac[12] == "1":
            result_frac = int(result_frac[0:12], 2) + 1
            result_frac = "{:012b}".format(result_frac)
        else:
            result_frac = result_frac[0:12]
        # ----------------------------
        if len(result_frac) != 12:
            print("尾数位宽第一次舍入出错")
        # ----------------------------
        # print(result_frac)
        # 第二次舍入,判断结果尾数的第1位
        if result_frac[0] == "1":
            result_exp = result_exp + 1
            result_frac = result_frac[1:11]
            # result_frac = int(result_frac[1:11],2)+int(result_frac[11],2)
            # result_frac = "{:010b}".format(result_frac)
        else:
            result_exp = result_exp
            result_frac = result_frac[2:]
        # print(result_frac)
        # ----------------------------
        if len(result_frac) != 10:
            print("尾数位宽第二次舍入出错")
        # ----------------------------
        # print(result_sign,result_exp,result_frac)
        # 第三次舍入，结果指数的上下溢出判断
        if result_exp > int("11110", 2):
            result_exp = "11110"
            result_frac = "1111111111"
        elif result_exp < int("00001", 2):
            result_exp = "00001"
            result_frac = "0000000000"
        else:
            result_exp = "{:05b}".format(result_exp)
            result_exp = result_exp[-5:]
        # ----------------------------
        if len(result_exp) != 5:
            print("指数段舍入出错")
        # ----------------------------

        # print(result_sign,result_exp,result_frac)
        result = bit_to_value(result_sign, result_exp, result_frac)
    return result


# 查找表生成 正数 对于使用内置函数计算出的exp查表值，均通过一次FP16转化 因此会引入误差，理论上 对于exp10010 应该是0误差的
# -------------------------正数尾数查找表，depth = 128----------------------
table_frac_index = []
table_result = []
frac_look_up_table = {}

for i in range(0, 128):
    frac = "{:07b}".format(i)
    frac = frac+"000"
    table_frac_index.append(frac)
    # print(frac)

for j in table_frac_index:
    fp = int(j, 2)
    result = math.exp(fp/1024)
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_result.append(result)

frac_look_up_table = dict(zip(table_frac_index, table_result))

# for i,j in frac_look_up_table.items():
# print(i,j)

# -------------------------正数指数查找表----------------------
table_exp_index = []
table_result = []
exp_look_up_table = {}

for i in range(1, 19):
    exp = "{:05b}".format(i)
    table_exp_index.append(exp)

for i in table_exp_index:
    exp = int(i, 2)
    result = math.exp(math.pow(2, exp-15))
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_result.append(result)

exp_look_up_table = dict(zip(table_exp_index, table_result))

# -------------------------正数偏移系数查找表----------------------
table_offset_index = []
table_result = []
offset_look_up_table = {}

for i in range(4):
    table_offset_index.append(str(i))

for i in table_offset_index:
    result = math.exp(int(i))
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_result.append(result)

offset_look_up_table = dict(zip(table_offset_index, table_result))

# ----------------------------指数表和偏移表融合---------------------------
exp_offset_index = []
table_result = []
exp_offset_look_up_table = {}

for i, j in exp_look_up_table.items():
    if (i == "10010"):
        for a in range(4):
            index = "{:02b}".format(a)+i
            value = j*offset_look_up_table[str(a)]
            exp_offset_index.append("0"+index)
            table_result.append(value)
            # print(index,value)
    elif (i == "10001"):
        for a in range(4):
            index = "{:02b}".format(a)+i
            value = j*offset_look_up_table[str(a)]
            exp_offset_index.append("0"+index)
            table_result.append(value)
            # print(index,value)
    elif (i == "10000"):
        for a in range(2):
            index = "{:02b}".format(a)+i
            value = j*offset_look_up_table[str(a)]
            exp_offset_index.append("0"+index)
            table_result.append(value)
            # print(index,value)
    else:
        index = "00" + i
        value = j*offset_look_up_table[str(0)]
        exp_offset_index.append("0"+index)
        table_result.append(value)
        # print(index,value)

exp_offset_look_up_table = dict(zip(exp_offset_index, table_result))


table_frac_index = []
table_result = []
frac_negative_look_up_table = {}

for i in range(0, 128):
    frac = "{:07b}".format(i)
    frac = frac+"000"
    table_frac_index.append(frac)

for j in table_frac_index:
    fp = int(j, 2)
    result = math.exp(-(fp/1024))
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_result.append(result)

frac_negative_look_up_table = dict(zip(table_frac_index, table_result))

# -------------------------负数指数查找表----------------------
table_exp_index = []
table_result = []
exp_negative_look_up_table = {}

for i in range(1, 19):
    exp = "{:05b}".format(i)
    table_exp_index.append(exp)

for i in table_exp_index:
    exp = int(i, 2)
    result = math.exp(-math.pow(2, exp-15))
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_result.append(result)

exp_negative_look_up_table = dict(zip(table_exp_index, table_result))

# -------------------------负数偏移系数查找表----------------------
table_offset_index = []
table_negative_result = []
offset_negative_look_up_table = {}

for i in range(4):
    table_offset_index.append(str(i))

for i in table_offset_index:
    result = math.exp(-int(i))
    result_sign, result_exp, result_frac = fp_to_bit(result)
    result = bit_to_value(result_sign, result_exp, result_frac)  # 模仿FP16的计算误差
    table_negative_result.append(result)


offset_negative_look_up_table = dict(
    zip(table_offset_index, table_negative_result))

# ------------------------------指数表和偏移表融合------------------------------------

exp_offset_negative_index = []
table_negative_result = []
exp_offset_negative_look_up_table = {}

for i, j in exp_negative_look_up_table.items():
    if (i == "10010"):
        for a in range(4):
            index = "{:02b}".format(a)+i
            value = j*offset_negative_look_up_table[str(a)]
            exp_offset_negative_index.append("1"+index)
            table_negative_result.append(value)
            # print(index,value)
    elif (i == "10001"):
        for a in range(4):
            index = "{:02b}".format(a)+i
            value = j*offset_negative_look_up_table[str(a)]
            exp_offset_negative_index.append("1"+index)
            table_negative_result.append(value)
            # print(index,value)
    elif (i == "10000"):
        for a in range(2):
            index = "{:02b}".format(a)+i
            value = j*offset_negative_look_up_table[str(a)]
            exp_offset_negative_index.append("1"+index)
            table_negative_result.append(value)
            # print(index,value)
    else:
        index = "00" + i
        value = j*offset_negative_look_up_table[str(0)]
        exp_offset_negative_index.append("1"+index)
        table_negative_result.append(value)
        # print(index,value)

exp_offset_negative_look_up_table = dict(
    zip(exp_offset_negative_index, table_negative_result))


def exp_fp16(data, debug):
    signal, exp, frac = fp_to_bit(data)
    if int(signal, 2) == 0 and int(exp+frac, 2) > int("100100110001011", 2):
        exp = "10010"
        frac = "0110001100"
    elif int(signal, 2) == 1 and int(exp+frac, 2) > int("100100011011010", 2):
        exp = "10010"
        frac = "0011011011"
    elif exp == "00000":  # 这里把0和非规范数放在一起处理了
        exp = "00001"
        frac = "0000001000"

    if exp == "10010":
        offset = frac[1:3]
    elif exp == "10001":
        offset = frac[0:2]
    elif exp == "10000":
        offset = "0" + frac[0:1]
    else:
        offset = "00"

    exp_offset_index = signal+offset+exp

    if signal == "0":
        result_exp_offset = exp_offset_look_up_table[exp_offset_index]
    else:
        result_exp_offset = exp_offset_negative_look_up_table[exp_offset_index]
    if debug == 1:
        print(exp_offset_index)
        print("result_exp_offset:", result_exp_offset)

    shift_number = int(exp, 2)-15
    frac_shift = shiftbinary(frac, shift_number)
    frac_index = frac_shift[:-3]+"000"

    if signal == "0":
        result_frac = frac_look_up_table[frac_index]
    else:
        result_frac = frac_negative_look_up_table[frac_index]

    if debug == 1:
        print(frac_index)
        print("result_frac:", result_frac)

    result_exp_offset_signal, result_exp_offset_exp, result_exp_offset_frac = fp_to_bit(
        result_exp_offset)
    # print("result_exp_offset",result_exp_offset_signal,result_exp_offset_exp,result_exp_offset_frac)
    result_frac_signal, result_frac_exp, result_frac_frac = fp_to_bit(
        result_frac)
    # print("result_frac",result_frac_signal,result_frac_exp,result_frac_frac)

    # result_table,_,_,_ = multiplication_noloss_all(result_exp_offset,result_frac)
    result_table = multiplication_exp(result_exp_offset, result_frac)

    result_signal, result_exp, result_frac = fp_to_bit(result_table)
    # print("result_table",result_signal,result_exp,result_frac)

    if signal == "0":
        middle_result = addbinary_exp(
            result_exp+result_frac, comp_value(frac_shift[7:]))
    elif signal == "1":
        middle_result = addbinary_negative_exp(
            result_exp+result_frac, comp_value(frac_shift[7:]))
    result_exp_comp = middle_result[0:5]
    result_frac_comp = middle_result[5:]
    result_comp = bit_to_value(
        result_signal, result_exp_comp, result_frac_comp)
    return result_comp, result_signal, result_exp_comp, result_frac_comp


def sigmoid(data, debug=False):
    data_signal, data_exp, data_mantissa = fp_to_bit(data)
    addition_constant = bit_to_value("0", "01111", "0000000000")

    result, result_sign, result_exp, result_mantissa = invertion(data, debug)

    result, result_sign, result_exp, result_mantissa = exp_fp16(result, debug)

    result, result_sign, result_exp, result_mantissa = addition_noloss_all(
        result, addition_constant, debug)

    result, result_sign, result_exp, result_mantissa = reciprocal(
        result, debug)

    result_fp16 = result_sign+result_exp+result_mantissa

    return result


def round_off(x: int, y: int) -> int:
    return (x + y - 1) // y * y


def psum_transform(A: torch.Tensor, dtype: str) -> torch.Tensor:
    shape = A.shape

    assert len(shape) == 3, "Expect tensor dim == 3, but got %d !" % len(shape)
    assert dtype in [
        "int32", "fp16", "bf16"], "Expect dtype in ['int32', 'fp16', 'bf16'], but got %s!" % dtype

    oc = shape[0]
    h = shape[1]
    w = shape[2]

    if dtype == "fp16" or dtype == "bf16":
        oc_group = round_off(oc, 32) // 32
        oc_64 = 32
    elif dtype == "int32":
        oc_group = round_off(oc, 64) // 64
        oc_64 = 64

    A_pad = F.pad(A, [0, 0, 0, 0, 0, oc_group * oc_64 - oc])
    A_reorder = A_pad.reshape(oc_group, oc_64, h, w)
    A_reorder = A_reorder.permute(0, 2, 3, 1)

    return A_reorder


def psum_expand_store(A: torch.Tensor, dtype: str, path, store_type: Optional[str] = None) -> None:
    shape = A.shape

    assert len(shape) == 4, "Expect tensor dim == 4, but got %d !" % len(shape)
    assert shape[-1] % 32 == 0, "Expect the last dim of A is 32, but got %d, try to run ifmap_transform() first!" % shape[-1]
    assert dtype in [
        "int32", "fp16", "bf16"], "Expect dtype in ['int32', 'fp16', 'bf16'], but got %s!" % dtype

    ddr_list = []

    A_expand = A.reshape([-1])
    if dtype == "fp16":
        A_expand = A_expand.half().numpy()
    elif dtype == "bf16":
        A_expand = A_expand.to(torch.bfloat16).numpy()
    elif dtype == "int32":
        A_expand = A_expand.to(torch.int).numpy()

    for i in range(A_expand.shape[0]):
        if dtype == "fp16" or dtype == "bf16":
            if i % 32 == 0:
                ddr_line = ""
            ddr_line = half2hex_tensor(A_expand[i]) + ddr_line
            if i % 32 == 31:
                ddr_list.append(ddr_line)
        elif dtype == "int32":
            if store_type == "sram":
                if i % 64 == 0:
                    ddr_line = ""
                ddr_line = int2hex_complement(A_expand[i], 32) + ddr_line
                if i % 64 == 63:
                    ddr_list.append(ddr_line)
            elif store_type == "ddr":
                if i % 16 == 0:
                    ddr_line = ""
                ddr_line = int2hex_complement(A_expand[i], 32) + ddr_line
                if i % 16 == 15:
                    ddr_list.append(ddr_line)

    ddr_file = open(path, "w")
    for i in range(len(ddr_list)):
        ddr_file.write(ddr_list[i] + '\n')

    ddr_file.close()


def int2bin_complement(int_num: int, bit_width: int = 0) -> str:
    if (int_num >= 0):
        bin_string = bin(int_num)[2:]
    else:
        bin_string = bin(trueform_to_complement(int_num, bit_width))[2:]
    bin_len = len(bin_string)
    if(bit_width <= bin_len):
        return bin_string
    else:
        loss_len = bit_width - bin_len
        zero_string = []
        for i in range(loss_len):
            zero_string.append('0')
        zero_string = "".join(zero_string)
        return (zero_string + bin_string)


def int2hex_complement(int_num: int, bit_width: int = 0) -> str:
    if (int_num >= 0):
        hex_string = hex(int_num)[2:]
    else:
        hex_string = hex(trueform_to_complement(int_num, bit_width))[2:]
    hex_len = len(hex_string)
    hex_width = int(bit_width / 4)
    if(hex_width == hex_len):
        return hex_string
    elif (hex_width < hex_len):
        print("ERROR: int2hex_complement")
    else:
        loss_len = hex_width - hex_len
        zero_string = []
        for i in range(loss_len):
            zero_string.append('0')
        zero_string = "".join(zero_string)
        return (zero_string + hex_string)


def trueform_to_complement(intdata: int, bit_width: int = 0) -> int:
    if (intdata > 0):
        return intdata
    else:
        if (bit_width == 0):
            bin_string = bin(intdata)[2:]
            bin_len = len(bin_string)
            binary_range = 2 ** bin_len
        else:
            binary_range = 2 ** bit_width
        return (binary_range + intdata)
