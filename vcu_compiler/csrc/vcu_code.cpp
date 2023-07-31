/*
 * @Author: weizema
 * @Date: 2023-07-28 09:54:35
 * @LastEditors: weizema
 * @LastEditTime: 2023-07-30 20:08:21
 * @Description: 
 */
#include "vcu_code.h"
#include <iomanip>

namespace VCU_CODE {

uint16_t get_VCUCode(uint16_t OPCODE, uint16_t MODE, uint16_t CONSTANT)
{
  VCUCode code;
  code.OPCODE   = OPCODE;
  code.MODE     = MODE;
  code.CONSTANT = CONSTANT;
  code.FREE     = 0;
  union CODE converter;
  converter.vcu_code = code;
  return converter.code.code;
}

}  // namespace VCU_CODE
