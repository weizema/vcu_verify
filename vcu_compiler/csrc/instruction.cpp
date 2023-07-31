/*
 * @Author: weizema
 * @Date: 2023-07-28 09:54:25
 * @LastEditors: weizema
 * @LastEditTime: 2023-07-31 12:36:58
 * @Description: 
 */
#include "instruction.h"

namespace VCU_INSN {
NpuInsn get_VCUExecuteINSN(uint64_t       VCU_INSN_PARA_STRIDE,
                           uint64_t       VCU_INSN_FPU_WORK,
                           uint64_t       VCU_INSN_RESADD_PARA_TYPE,
                           uint64_t       VCU_INSN_RESADD_RAM_VALID,
                           uint64_t       VCU_INSN_MULT_PARA,
                           uint64_t       VCU_INSN_PARA_RAM_VALID,
                           uint64_t       VCU_INSN_RAM_DATA_OUT_TYPE,
                           uint64_t       VCU_INSN_RAM_DATA_IN_TYPE,
                           uint64_t       VCU_INSN_RAM_OUT_MODE,
                           uint64_t       VCU_INSN_COMPUTE_LENGTH,
                           uint64_t       VCU_INSN_FPU,
                           uint64_t       VCU_INSN_RESADD_RAM_IN_ADDRESS,
                           uint64_t       VCU_INSN_PARA_RAM_IN_ADDRESS,
                           uint64_t       VCU_INSN_DATA_RAM_OUT_ADDRESS,
                           uint64_t       VCU_INSN_DATA_RAM_IN_ADDRESS,
                           std::ofstream& buf)
{
  union INSN     converter;
  VCUExecuteINSN vcu_execute                 = {};
  vcu_execute.opcode                         = VCU_INSN_OPCODE;
  vcu_execute.VCU_INSNTYPE                   = EXECUTE_INSN;
  vcu_execute.VCU_FREE_BITS                  = 0;
  vcu_execute.VCU_INSN_PARA_STRIDE           = VCU_INSN_PARA_STRIDE;
  vcu_execute.VCU_INSN_FPU_WORK              = VCU_INSN_FPU_WORK;
  vcu_execute.VCU_INSN_RESADD_PARA_TYPE      = VCU_INSN_RESADD_PARA_TYPE;
  vcu_execute.VCU_INSN_RESADD_RAM_VALID      = VCU_INSN_RESADD_RAM_VALID;
  vcu_execute.VCU_INSN_MULT_PARA             = VCU_INSN_MULT_PARA;
  vcu_execute.VCU_INSN_PARA_RAM_VALID        = VCU_INSN_PARA_RAM_VALID;
  vcu_execute.VCU_INSN_RAM_DATA_OUT_TYPE     = VCU_INSN_RAM_DATA_OUT_TYPE;
  vcu_execute.VCU_INSN_RAM_DATA_IN_TYPE      = VCU_INSN_RAM_DATA_IN_TYPE;
  vcu_execute.VCU_INSN_RAM_OUT_MODE          = VCU_INSN_RAM_OUT_MODE;
  vcu_execute.VCU_INSN_COMPUTE_LENGTH_0      = VCU_INSN_COMPUTE_LENGTH & 0b1111111;
  vcu_execute.VCU_INSN_COMPUTE_LENGTH_1      = ((VCU_INSN_COMPUTE_LENGTH >> 7) & 0b11111);
  vcu_execute.VCU_INSN_FPU                   = VCU_INSN_FPU;
  vcu_execute.VCU_INSN_RESADD_RAM_IN_ADDRESS = VCU_INSN_RESADD_RAM_IN_ADDRESS;
  vcu_execute.VCU_INSN_PARA_RAM_IN_ADDRESS   = VCU_INSN_PARA_RAM_IN_ADDRESS;
  vcu_execute.VCU_INSN_DATA_RAM_OUT_ADDRESS  = VCU_INSN_DATA_RAM_OUT_ADDRESS;
  vcu_execute.VCU_INSN_DATA_RAM_IN_ADDRESS   = VCU_INSN_DATA_RAM_IN_ADDRESS;
  converter.vcu_execute                      = vcu_execute;
  
  buf << std::hex << std::setw(16) << std::setfill('0') << converter.npuinsn.high64 << std::hex << std::setw(16)
      << std::setfill('0') << converter.npuinsn.low64 << std::endl;

  return converter.npuinsn;
}

NpuInsn get_VCUConfigINSN(uint64_t       VCU_CONFIG_ADDER_CONSTANT_0,
                          uint64_t       VCU_CONFIG_ADDER_CONSTANT_1,
                          uint64_t       VCU_CONFIG_ADDER_CONSTANT_2,
                          uint64_t       VCU_CONFIG_MULTIPLICATION_CONSTANT_0,
                          uint64_t       VCU_CONFIG_MULTIPLICATION_CONSTANT_1,
                          uint64_t       VCU_CONFIG_MULTIPLICATION_CONSTANT_2,
                          uint64_t       VCU_CONFIG_COMPARE_CONSTANT,
                          std::ofstream& buf)
{
  union INSN    converter;
  VCUConfigINSN vcu_config                        = {};
  vcu_config.opcode                               = VCU_INSN_OPCODE;
  vcu_config.VCU_INSNTYPE                         = CONFIG_INSN;
  vcu_config.VCU_CONFIG_ADDER_CONSTANT_0          = VCU_CONFIG_ADDER_CONSTANT_0;
  vcu_config.VCU_CONFIG_ADDER_CONSTANT_1          = VCU_CONFIG_ADDER_CONSTANT_1;
  vcu_config.VCU_CONFIG_ADDER_CONSTANT_2          = VCU_CONFIG_ADDER_CONSTANT_2;
  vcu_config.VCU_CONFIG_MULTIPLICATION_CONSTANT_0 = VCU_CONFIG_MULTIPLICATION_CONSTANT_0;
  vcu_config.VCU_CONFIG_MULTIPLICATION_CONSTANT_1 = VCU_CONFIG_MULTIPLICATION_CONSTANT_1;
  vcu_config.VCU_CONFIG_MULTIPLICATION_CONSTANT_2 = VCU_CONFIG_MULTIPLICATION_CONSTANT_2;
  vcu_config.VCU_CONFIG_COMPARE_CONSTANT          = VCU_CONFIG_COMPARE_CONSTANT;
  vcu_config.VCU_CONFIG_FREE                      = 0;
  converter.vcu_config                            = vcu_config;

  buf << std::hex << std::setw(16) << std::setfill('0') << converter.npuinsn.high64 << std::hex << std::setw(16)
      << std::setfill('0') << converter.npuinsn.low64 << std::endl;

  return converter.npuinsn;
}
}  // namespace VCU_INSN
