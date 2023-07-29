/*
 * @Author: weizema weizema@smail.nju.edu.cn
 * @Date: 2023-07-28 09:54:31
 * @LastEditors: weizema weizema@smail.nju.edu.cn
 * @LastEditTime: 2023-07-28 18:50:01
 * @FilePath: /vcu_compiler/csrc/vcu_code.h
 * @Description:
 */
#pragma once

#include <cstdint>
#include <fstream>
#include <vector>

namespace VCU_CODE {

enum ACTIVATION_TYPE {
  NONE       = 0,
  RELU       = 1,
  LEAKY_RELU = 2,
  SIGMOID    = 3,
  TANH       = 4,
  SELU       = 5,
  MISH       = 6,
  SOFTPLUS   = 7,
  SWISH      = 8,
  GELU       = 9
};

enum VCUCODE_BITS {
  OPCODE_BITS   = 4,
  MODE_BITS     = 2,
  CONSTANT_BITS = 3,
  FREE_BITS     = 16 - OPCODE_BITS - MODE_BITS - CONSTANT_BITS
};

enum VCUCODE_OPCODE {
  ADD = 0b0000,
  MUL = 0b0001,
  LOG = 0b0010,
  INV = 0b0011,
  EXP = 0b0100,
  REC = 0b0101,
  CMP = 0b0110,
  STP = 0b1111
};

enum VCUCODE_MODE {
  SOURCE_TO_ITER  = 0b00,
  SOURCE_TO_CONST = 0b01,
  ITER_TO_ITER    = 0b10,
  ITER_TO_CONST   = 0b11
};

enum VCUCODE_CONSTANT {
  GLOBAL_REG_0 = 0b000,
  GLOBAL_REG_1 = 0b001,
  GLOBAL_REG_2 = 0b010,
  CONST_REG    = 0b011,
  PARAM_REG    = 0b100,
  RESADD_REG   = 0b101
};

typedef struct VCUCode {
  uint16_t CONSTANT : CONSTANT_BITS;
  uint16_t MODE : MODE_BITS;
  uint16_t OPCODE : OPCODE_BITS;
  uint16_t FREE : FREE_BITS;
} VCUCode;

typedef struct CODE16bit {
  uint16_t code;
} CODE16bit;

union CODE {
  VCUCode   vcu_code;
  CODE16bit code;
};

uint16_t get_VCUCode(uint16_t OPCODE, uint16_t MODE, uint16_t CONSTANT);

}  // namespace VCU_CODE
