import vcu_compiler_cpp


def get_vcu_execute_insn(
    path: str,
    para_stride: int,
    fpu_work: int,
    resadd_para_type: int,
    resadd_ram_valid: int,
    multi_para: int,
    para_ram_valid: int,
    ram_data_out_type: int,
    ram_data_in_type: int,
    ram_out_mode: int,
    compute_length: int,
    fpu: int,
    resadd_ram_in_address: int,
    para_ram_in_address: int,
    data_ram_out_address: int,
    data_ram_in_address: int
) -> None:
    vcu_compiler_cpp.get_VCUExecuteINSN(
        para_stride,
        fpu_work,
        resadd_para_type,
        resadd_ram_valid,
        multi_para,
        para_ram_valid,
        ram_data_out_type,
        ram_data_in_type,
        ram_out_mode,
        compute_length,
        fpu,
        resadd_ram_in_address,
        para_ram_in_address,
        data_ram_out_address,
        data_ram_in_address,
        path
    )


def get_vcu_config_insn(
    path: str,
    adder_constant_0: int,
    adder_constant_1: int,
    adder_constant_2: int,
    multiplication_constant_0: int,
    multiplication_constant_1: int,
    multiplication_constatn_2: int,
    compare_constant: int,
) -> None:

    vcu_compiler_cpp.get_VCUConfigINSN(
        adder_constant_0,
        adder_constant_1,
        adder_constant_2,
        multiplication_constant_0,
        multiplication_constant_1,
        multiplication_constatn_2,
        compare_constant,
        path
    )


def get_vcu_code(
    opcode: int,
    mode: int,
    constant: int
):
    code = vcu_compiler_cpp.get_VCUcode(opcode, mode, constant)
    return code