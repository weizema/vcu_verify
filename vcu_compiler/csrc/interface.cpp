/*
 * @Author: weizema
 * @Date: 2023-07-28 09:54:46
 * @LastEditors: weizema
 * @LastEditTime: 2023-07-30 20:08:37
 * @Description: 
 */
#include "instruction.h"
#include "vcu_code.h"
#include <pybind11/pybind11.h>

void get_VCUExecuteINSN(uint64_t    VCU_INSN_PARA_STRIDE,
                        uint64_t    VCU_INSN_FPU_WORK,
                        uint64_t    VCU_INSN_RESADD_PARA_TYPE,
                        uint64_t    VCU_INSN_RESADD_RAM_VALID,
                        uint64_t    VCU_INSN_MULT_PARA,
                        uint64_t    VCU_INSN_PARA_RAM_VALID,
                        uint64_t    VCU_INSN_RAM_DATA_OUT_TYPE,
                        uint64_t    VCU_INSN_RAM_DATA_IN_TYPE,
                        uint64_t    VCU_INSN_RAM_OUT_MODE,
                        uint64_t    VCU_INSN_COMPUTE_LENGTH,
                        uint64_t    VCU_INSN_FPU,
                        uint64_t    VCU_INSN_RESADD_RAM_IN_ADDRESS,
                        uint64_t    VCU_INSN_PARA_RAM_IN_ADDRESS,
                        uint64_t    VCU_INSN_DATA_RAM_OUT_ADDRESS,
                        uint64_t    VCU_INSN_DATA_RAM_IN_ADDRESS,
                        const char* p)
{
  std::ofstream buf;
  buf.open(p);
  VCU_INSN::get_VCUExecuteINSN(VCU_INSN_PARA_STRIDE,
                               VCU_INSN_FPU_WORK,
                               VCU_INSN_RESADD_PARA_TYPE,
                               VCU_INSN_RESADD_RAM_VALID,
                               VCU_INSN_MULT_PARA,
                               VCU_INSN_PARA_RAM_VALID,
                               VCU_INSN_RAM_DATA_OUT_TYPE,
                               VCU_INSN_RAM_DATA_IN_TYPE,
                               VCU_INSN_RAM_OUT_MODE,
                               VCU_INSN_COMPUTE_LENGTH,
                               VCU_INSN_FPU,
                               VCU_INSN_RESADD_RAM_IN_ADDRESS,
                               VCU_INSN_PARA_RAM_IN_ADDRESS,
                               VCU_INSN_DATA_RAM_OUT_ADDRESS,
                               VCU_INSN_DATA_RAM_IN_ADDRESS,
                               buf);
  buf.close();
}

void get_VCUConfigINSN(uint64_t    VCU_CONFIG_ADDER_CONSTANT_0,
                       uint64_t    VCU_CONFIG_ADDER_CONSTANT_1,
                       uint64_t    VCU_CONFIG_ADDER_CONSTANT_2,
                       uint64_t    VCU_CONFIG_MULTIPLICATION_CONSTANT_0,
                       uint64_t    VCU_CONFIG_MULTIPLICATION_CONSTANT_1,
                       uint64_t    VCU_CONFIG_MULTIPLICATION_CONSTANT_2,
                       uint64_t    VCU_CONFIG_COMPARE_CONSTANT,
                       const char* p)
{
  std::ofstream buf;
  buf.open(p);
  VCU_INSN::get_VCUConfigINSN(VCU_CONFIG_ADDER_CONSTANT_0,
                              VCU_CONFIG_ADDER_CONSTANT_1,
                              VCU_CONFIG_ADDER_CONSTANT_2,
                              VCU_CONFIG_MULTIPLICATION_CONSTANT_0,
                              VCU_CONFIG_MULTIPLICATION_CONSTANT_1,
                              VCU_CONFIG_MULTIPLICATION_CONSTANT_2,
                              VCU_CONFIG_COMPARE_CONSTANT,
                              buf);
  buf.close();
}

uint16_t get_VCUcode(uint16_t OPCODE, uint16_t MODE, uint16_t CONSTANT)
{
  uint16_t code = VCU_CODE::get_VCUCode(OPCODE, MODE, CONSTANT);
  return code;
}

PYBIND11_MODULE(vcu_compiler_cpp, m)
{
  m.doc() = "vcu Auto Compiler";
  m.def("get_VCUConfigINSN", &get_VCUConfigINSN, "VCUConfigINSN Interface");
  m.def("get_VCUExecuteINSN", &get_VCUExecuteINSN, "VCUExecuteINSN Interface");
  m.def("get_VCUcode", &get_VCUcode, "VCUCode Interface");
}