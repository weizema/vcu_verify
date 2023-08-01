'''
Author: weizema
Date: 2023-07-31 19:38:10
LastEditors: weizema
LastEditTime: 2023-08-01 20:42:55
Description: 
'''
from utils import *


def sigmoid(data, debug=False):
    addition_constant = bit_to_value("0", "01111", "0000000000")

    result, _, _, _ = invertion(data, debug)

    result, _, _, _ = exp_fp16(result, debug)

    result, _, _, _ = addition_noloss_all(
        result, addition_constant, debug)

    result, _, _, _ = reciprocal(
        result, debug)

    return result


def tanh(data, debug=False):
    multiplication_constant = bit_to_value("0", "10000", "0000000000")
    addition_constant = bit_to_value("0", "01111", "0000000000")

    result, _, _, _ = multiplication_noloss_all(
        data, multiplication_constant, debug)
    result, _, _, _ = invertion(result, debug)
    result, _, _, _ = exp_fp16(result, debug)
    result, _, _, _ = invertion(result, debug)
    reg, _, _, _ = addition_noloss_all(result, addition_constant, debug)
    result, _, _, _ = invertion(result, debug)
    result, _, _, _ = addition_noloss_all(result, addition_constant, debug)
    result, _, _, _ = reciprocal(result, debug)
    result, _, _, _ = multiplication_noloss_all(result, reg, debug)

    return result

def leakyrelu(data, debug=False):
    multiplication_constant_0 = bit_to_value("0", "10000", "0000000000")
    multiplication_constant_1 = bit_to_value("0", "01100", "0000000000")
    reg, _, _, _ = multiplication_noloss_all(
        data, multiplication_constant_0, debug)
    result, _, _, _ = multiplication_noloss_all(result, multiplication_constant_1, debug)
    result = reg if data > 0 else result
    return result

def gelu(data, debug=False):
    multiplication_constant_0 = np.half(0.044715)
    multiplication_constant_1 = np.half(np.sqrt(2 / np.pi))
    multiplication_constant_2 = np.half(2)
    multiplication_constant_3 = np.half(0.5)
    addition_constant = bit_to_value("0", "01111", "0000000000")

    result, _, _, _ = multiplication_noloss_all(
        data, multiplication_constant_0, debug)
    result, _, _, _ = multiplication_noloss_all(
        data, result, debug)
    result, _, _, _ = multiplication_noloss_all(
        data, result, debug)
    result, _, _, _ = addition_noloss_all(
        data, result, debug)
    result, _, _, _ = multiplication_noloss_all(
        result, multiplication_constant_1, debug)
    result, _, _, _ = multiplication_noloss_all(
        result, multiplication_constant_2, debug)
    result, _, _, _ = invertion(result, debug)
    result, _, _, _ = exp_fp16(result, debug)
    result, _, _, _ = invertion(result, debug)
    reg, _, _, _ = addition_noloss_all(result, addition_constant, debug)
    result, _, _, _ = invertion(result, debug)
    result, _, _, _ = addition_noloss_all(result, addition_constant, debug)
    result, _, _, _ = reciprocal(result, debug)
    result, _, _, _ = multiplication_noloss_all(result, reg, debug)
    result, _, _, _ = addition_noloss_all(result, addition_constant, debug)
    result, _, _, _ = multiplication_noloss_all(result, data, debug)
    result, _, _, _ = multiplication_noloss_all(result, multiplication_constant_3, debug)

    return result


print(addition_noloss_all(bit_to_value("0", "01101", "0000111110"), bit_to_value("0", "01110", "1111000000"), False))
