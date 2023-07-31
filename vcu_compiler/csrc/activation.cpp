/*
 * @Author: weizema
 * @Date: 2023-07-30 20:09:06
 * @LastEditors: weizema
 * @LastEditTime: 2023-07-30 20:18:50
 * @Description:
 */
#include "activation.h"

namespace activation {

template<int ACTIVATION_TYPE>
std::pair<std::vector<VCU_INSN::NpuInsn>, std::vector<VCU_CODE::VCUCode>> Activation_func()
{}

template <> std::pair<std::vector<VCU_INSN::NpuInsn>, std::vector<VCU_CODE::VCUCode>> Activation_func<RELU>()
{
  std::vector<VCU_INSN::NpuInsn> relu_insn;
  std::vector<VCU_CODE::VCUCode> relu_code;

  

  return std::make_pair(relu_insn, relu_code);
}
};