/*
 * @Author: weizema
 * @Date: 2023-07-30 20:09:11
 * @LastEditors: weizema
 * @LastEditTime: 2023-07-30 20:16:46
 * @Description:
 */
#pragma once

#include "instruction.h"
#include "vcu_code.h"
#include <vector>

namespace activation {

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

template<int ACTIVATION_TYPE>
std::pair<std::vector<VCU_INSN::NpuInsn>, std::vector<VCU_CODE::VCUCode>> Activation_func();

}  // namespace activation