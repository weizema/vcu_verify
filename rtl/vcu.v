`timescale 1ps/1ps

module vcu(insn,work_en,
            vcu_done,
            clk,rst,
            r_data_acc,r_addr_acc,r_en_acc,acc_data_in_type,
            w_data_acc,w_addr_acc,w_en_acc,acc_data_out_type,
            r_data_para,r_addr_para,r_en_para,para_data_in_type,
            w_data_ofmap,w_addr_ofmap,w_en_ofmap,ofmap_data_out_type,
            w_data_inp,w_addr_inp,w_en_inp,inp_data_out_type,
            r_data_resadd,r_addr_resadd,r_en_resadd,resadd_data_in_type,
            w_data_opcode,w_addr_opcode,w_en_opcode
            );

parameter INSN_WIDTH = 128;

parameter ACC_DATA_WIDTH = 2048;
parameter PARA_DATA_WIDTH = 1024;
parameter OFMAP_DATA_WIDTH = 512;
parameter INP_DATA_WIDTH = 512;
parameter RESADD_DATA_WIDTH = 1024;
parameter OPCODE_DATA_WIDTH = 16;

parameter ACC_ADDRESS_WIDTH = 12;
parameter OFMAP_ADDRESS_WIDTH = 12;   
parameter PARA_ADDRESS_WIDTH = 5;
parameter OPCODE_ADDRESS_WIDTH = 10;  
parameter INP_ADDRESS_WIDTH = 10;    
parameter RESADD_ADDRESS_WIDTH =  9;

parameter DATA_WIDTH = 16;
parameter ADDRESS_WIDTH = 12;
parameter N = 64;

parameter IDLE = 3'b000;
parameter DATA_PREPARE = 3'b001;
parameter FPU_COMPUTE = 3'b010;
parameter OVER = 3'b011;
parameter PARA_CONFIG = 3'b100; 
parameter QUAN_CONFIG = 3'b101;

input wire [INSN_WIDTH-1:0]insn;

input wire work_en;
output reg vcu_done;

input wire clk;
input wire rst;

//insn input 
input wire [OPCODE_DATA_WIDTH-1:0]w_data_opcode;
input wire [OPCODE_ADDRESS_WIDTH-1:0]w_addr_opcode;
input wire w_en_opcode;

//data input 
input wire [ACC_DATA_WIDTH-1:0]r_data_acc;
output reg [ACC_ADDRESS_WIDTH-1:0]r_addr_acc; 
output reg r_en_acc;

//para input 
input wire [PARA_DATA_WIDTH-1:0]r_data_para;
output reg [PARA_ADDRESS_WIDTH-1:0]r_addr_para; 
output reg r_en_para;

//resadd input 
input wire [RESADD_DATA_WIDTH-1:0]r_data_resadd;
output reg [RESADD_ADDRESS_WIDTH-1:0]r_addr_resadd;
output reg r_en_resadd;

//data output 
output reg [ACC_DATA_WIDTH-1:0]w_data_acc;
output reg [ACC_ADDRESS_WIDTH-1:0]w_addr_acc; 
output reg w_en_acc;

//data output
output reg [OFMAP_DATA_WIDTH-1:0]w_data_ofmap;
output reg [OFMAP_ADDRESS_WIDTH-1:0]w_addr_ofmap; 
output reg w_en_ofmap;

//data output
output reg [INP_DATA_WIDTH-1:0]w_data_inp;
output reg [INP_ADDRESS_WIDTH-1:0]w_addr_inp; 
output reg w_en_inp;

output reg acc_data_in_type;
output reg acc_data_out_type; 
output reg ofmap_data_out_type;
output reg para_data_in_type;
output reg inp_data_out_type;
output reg resadd_data_in_type;

reg insn_valid;
reg work;

reg [2:0]state,next_state;
////////////////////////////////////
reg data_prepare_complete;
reg para_prepare_complete;
wire fpu_config_complete;
reg fpu_compute_coutinue;
reg fpu_done;

reg data_prepare_complete_temp;
reg para_prepare_complete_temp;
/////////////////////////////////////
reg [ADDRESS_WIDTH-1:0]compute_count;
reg [9:0]para_channel_count;
reg [2:0]para_functional_count;

reg fpu_valid;
reg para_config_complete;
reg compute_complete;
reg fpu_done_temp;
reg quan_config_complete;

//insn
reg [ADDRESS_WIDTH-1:0]insn_data_ram_in_address;
reg [ADDRESS_WIDTH-1:0]insn_data_ram_out_address;
reg [PARA_ADDRESS_WIDTH-1:0]insn_para_ram_in_address;
reg [RESADD_ADDRESS_WIDTH-1:0]insn_resadd_ram_in_address;
reg [19:0]insn_fpu;
reg [ADDRESS_WIDTH-1:0]insn_compute_length;
reg [1:0]insn_ram_out_mode;
reg insn_ram_data_in_type;
reg insn_ram_data_out_type;
reg [1:0]insn_para_ram_valid;
reg insn_mult_para;
reg insn_resadd_ram_valid;
reg [1:0]insn_resadd_para_type;
reg insn_type;
reg insn_fpu_work;
reg [9:0]insn_para_channel_stride;
reg [2:0]insn_para_functional_stride;

wire [DATA_WIDTH*N-1:0]data_dequan_int32;

reg [DATA_WIDTH*N-1:0]global_para;
reg [DATA_WIDTH*N-1:0]local_para;

reg [DATA_WIDTH*N-1:0]fpu_data;//64*16=1024
reg [DATA_WIDTH*N-1:0]operator_data_temp;
reg [DATA_WIDTH*N-1:0]fpu_result;//64*16=1024

wire [8*N:0]result_quan;
reg [16*(N/2):0]vcu_result;

reg r_en_opcode;
reg [OPCODE_ADDRESS_WIDTH-1:0]r_addr_opcode;
wire [OPCODE_DATA_WIDTH-1:0]r_data_opcode;

reg [4:0]operator_number;
reg [4:0]operator_count;//max = 31
wire [8:0]execute_code;

wire [DATA_WIDTH*N-1:0]resadd_int8tofp16;
reg [DATA_WIDTH*N-1:0]resadd_data_temp;

reg [DATA_WIDTH-1:0]addition_constant_0;
reg [DATA_WIDTH-1:0]addition_constant_1;
reg [DATA_WIDTH-1:0]addition_constant_2;
reg [DATA_WIDTH-1:0]multiplication_constant_0;
reg [DATA_WIDTH-1:0]multiplication_constant_1;
reg [DATA_WIDTH-1:0]multiplication_constant_2;

reg [DATA_WIDTH-1:0]compare_constant;

reg [DATA_WIDTH*N-1:0]operator_data;
reg [DATA_WIDTH*N-1:0]constant_para;
reg [DATA_WIDTH*N-1:0]constant_resadd;
reg [DATA_WIDTH*N-1:0]iteration_data;
reg [DATA_WIDTH*N-1:0]constant_data;

wire [DATA_WIDTH*N-1:0]output_result;
wire [DATA_WIDTH*N-1:0]vcu_result_temp;

wire operator_complete_all;
wire operator_complete[N-1:0];

wire [3:0]operation_code;
wire [1:0]configuration_code;
wire [2:0]constant_code;

wire [9:0]insn_opcode_sram_address;
wire [9:0]insn_opcode_number;

wire change_para;

//insn process
always @(posedge clk)
begin
    if(rst)
    begin
        insn_valid <= 'd0;
    end
    else
    begin
        if(work_en)
        begin
            insn_valid <= 1'b1;
        end
        else
        begin
            insn_valid <= 1'b0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        insn_data_ram_in_address <= 'd0;
        insn_data_ram_out_address <= 'd0;
        insn_para_ram_in_address <= 'd0;
        insn_resadd_ram_in_address <= 'd0;
        insn_fpu <= 'd0;
        insn_compute_length <= 'd0;
        insn_ram_out_mode <= 'd0;
        insn_ram_data_in_type <= 'd0;
        insn_ram_data_out_type <= 'd0;
        insn_para_ram_valid <= 'd0;
        insn_mult_para <='d0;
        insn_resadd_ram_valid <='d0;
        insn_resadd_para_type <= 'd0;
        insn_fpu_work <= 'd0;
        insn_para_channel_stride <= 'd0;
        insn_type <= 'd0;
        work <='d0;      
    end
    else
    begin
        if(insn_valid)
        begin
            insn_data_ram_in_address <= insn[127:116];
            insn_data_ram_out_address <= insn[115:104];
            insn_para_ram_in_address <= insn[103:99];
            insn_resadd_ram_in_address <= insn[98:89]; 
            insn_fpu <= insn[88:69];
            insn_compute_length <= insn[68:57];
            insn_ram_out_mode <= insn[56:55];
            insn_ram_data_in_type <= insn[54];
            insn_ram_data_out_type <= insn[53];
            insn_para_ram_valid <= insn[52:51];
            insn_mult_para <= insn[50];
            insn_resadd_ram_valid <= insn[49];
            insn_resadd_para_type <= insn[48:47];
            insn_fpu_work <= insn[46];
            insn_para_channel_stride <= insn[45:37] + 1'b1;
            insn_para_functional_stride <= insn[36:34];
            insn_type <= insn[3];
            work <= 1'b1;
        end
        if(vcu_done)
        begin
            work <= 1'b0;
        end
    end
end

always @(*)
begin
    case(state)
    IDLE:
    begin
        if(work&&insn_type)
            next_state = PARA_CONFIG;
        else if(work&&!insn_type&&(insn_para_ram_valid==2'b11))
            next_state = QUAN_CONFIG;
        else if(work&&!insn_type&&((insn_para_ram_valid==2'b10)||(insn_para_ram_valid==2'b00)))
            next_state = DATA_PREPARE;
        else
            next_state = IDLE;
    end
    DATA_PREPARE:
    begin
        if(data_prepare_complete_temp&&insn_fpu_work)
            next_state = FPU_COMPUTE;
        else if(data_prepare_complete_temp&&(!insn_fpu_work))
            next_state = OVER;
        else
            next_state = DATA_PREPARE;
    end
    FPU_COMPUTE:
    begin
        if(fpu_done)
            next_state = OVER;
        else
            next_state = FPU_COMPUTE;
    end
    PARA_CONFIG:
    begin
        if(para_config_complete)
            next_state = OVER;
        else
            next_state = PARA_CONFIG;
    end
    QUAN_CONFIG:
    begin
        if(quan_config_complete)
            next_state = DATA_PREPARE;
        else
            next_state = QUAN_CONFIG;
    end
    OVER:
    begin
        if(vcu_done)
            next_state = IDLE;
        else if(fpu_compute_coutinue)
            next_state = DATA_PREPARE;
    end
    endcase
end

always @(posedge clk)
begin
    if(rst)
    begin
        state <= IDLE;
    end
    else
    begin
        state <= next_state;
    end
end

//address process
always @(posedge clk)
begin
    if(rst)
    begin
        r_addr_acc <= 'd0;
        r_addr_para <= 'd0;
        r_addr_resadd <= 'd0;
        w_addr_ofmap <= 'd0;
        w_addr_inp <= 'd0;
        w_addr_acc <= 'd0;
    end
    else
    begin
        if(state == IDLE)
        begin
            r_addr_acc <= insn_data_ram_in_address;
            r_addr_para <= insn_para_ram_in_address;
            r_addr_resadd <= insn_resadd_ram_in_address;

            if(insn_ram_out_mode == 2'b00)
            begin
                w_addr_inp <= insn_data_ram_out_address;
            end
            else if(insn_ram_out_mode == 2'b01)
            begin
                w_addr_ofmap <= insn_data_ram_out_address;
            end
            else if(insn_ram_out_mode == 2'b10)
            begin
                w_addr_acc <= insn_data_ram_out_address;
            end
        end

        if(r_en_acc)
            r_addr_acc <= r_addr_acc + 1;
        else
            r_addr_acc <= r_addr_acc;

        if(r_en_resadd&&insn_resadd_ram_valid)
            r_addr_resadd <= r_addr_resadd + 1;
        else
            r_addr_resadd <= r_addr_resadd;
        
        if(fpu_compute_coutinue)
        begin
            if(((insn_para_ram_valid == 2'b10)||(insn_para_ram_valid == 2'b11)) && ((para_channel_count==insn_para_channel_stride)&&insn_mult_para))
            begin
                r_addr_para <= r_addr_para + 1'b1;
            end
            else if (((insn_para_ram_valid == 2'b10)||(insn_para_ram_valid == 2'b11)) && ((change_para)&&insn_mult_para))
            begin
                r_addr_para <= insn_para_functional_stride * para_functional_count + para_channel_count;
            end
            else
            begin
                r_addr_para <= r_addr_para;
            end
            
            if(insn_ram_out_mode == 2'b00)
            begin
                w_addr_inp <= w_addr_inp + 1;
            end
            else if(insn_ram_out_mode == 2'b01)
            begin
                w_addr_ofmap <= w_addr_ofmap + 1;
            end
            else if(insn_ram_out_mode == 2'b10)
            begin
                w_addr_acc <= w_addr_acc + 1;
            end
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        para_data_in_type <= 'd0;
        resadd_data_in_type <='d0;
    end
    else
    begin
        para_data_in_type <= ~insn_ram_data_in_type;
        resadd_data_in_type <= insn_resadd_para_type[0];
    end
end

always@(*)
begin
    if(((state!=QUAN_CONFIG)&&(next_state==QUAN_CONFIG)) || ((state!=DATA_PREPARE)&&(next_state==DATA_PREPARE)))
        r_en_para = 1'b1;
    else
        r_en_para = 1'b0;
end

always @(*)
begin
    if((state!=DATA_PREPARE)&&(next_state==DATA_PREPARE)&&(insn_resadd_ram_valid==1'b1))
        r_en_resadd = 1'b1;
    else
        r_en_resadd = 1'b0;
end

reg quan_config_complete_temp;

always @(posedge clk)
begin
    if(rst)
    begin
        constant_para <= 'd0;
        quan_config_complete_temp <= 'd0;
        quan_config_complete <= 'd0;
    end
    else
    begin
        quan_config_complete <= quan_config_complete_temp;

        if(((state==DATA_PREPARE)&&(insn_mult_para||(insn_para_ram_valid==2'b10))))
        begin
            constant_para <= r_data_para;
            // quan_config_complete_temp <= 'd0;  
        end
        else if((state==QUAN_CONFIG&&next_state==DATA_PREPARE)&&(insn_para_ram_valid==2'b11))
        begin
            constant_para <= r_data_para;
            // quan_config_complete_temp <= 1'b1;  
        end
        else
        begin
            constant_para <= constant_para;
            // quan_config_complete_temp <= 'd0;  
        end

        if(next_state==QUAN_CONFIG)
            quan_config_complete_temp <= 1'b1;
        else
            quan_config_complete_temp <= 1'b0;  
    end      
end

//acc_ram
always @(posedge clk)
begin
    if(rst)
    begin
        // r_en_acc <= 'd0;
        data_prepare_complete <= 'd0;
    end
    else
    begin
        if(next_state == DATA_PREPARE)
        begin
            // r_en_acc <= 1'b1;
            data_prepare_complete <= 1'b1;
            // acc_data_in_type <= ~insn_ram_data_in_type;
        end

        // if(r_en_acc)
        // begin
        //     r_en_acc <= 1'd0;
        // end

        if(data_prepare_complete)
        begin
            data_prepare_complete <= 1'b0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
        acc_data_in_type <= 'd0;
    else
        acc_data_in_type <= ~insn_ram_data_in_type;
end

always @(*)
begin
    if((state!=DATA_PREPARE)&&(next_state==DATA_PREPARE))
        r_en_acc = 1'b1;
    else
        r_en_acc = 1'b0;
end


always @(posedge clk)
begin
    if(rst)
    begin
        data_prepare_complete_temp <= 'd0;
    end
    else
    begin
        data_prepare_complete_temp <= data_prepare_complete;
    end
end

always @(*)
begin
    if(insn_ram_data_in_type)
    begin
        if(insn_resadd_para_type == 2'b11)
            operator_data_temp = r_data_acc[1023:0];
        else
            operator_data_temp = {512'b0,r_data_acc[511:0]};
    end
    else
    begin
        operator_data_temp = data_dequan_int32;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        fpu_valid <= 'd0; 
        operator_data <= 'd0;
    end
    else
    begin
        // if((next_state==OVER)&&(insn_fpu_work==1'b0)||(next_state==FPU_COMPUTE)&&(insn_fpu_work==1'b1))
        if(state==DATA_PREPARE)
        begin
            operator_data <= operator_data_temp;
        end
        else
        begin
            operator_data <= operator_data;
        end

        if((state!=FPU_COMPUTE)&&(next_state==FPU_COMPUTE))
        begin
            fpu_valid <= 1'b1;
        end
        else
        begin
            fpu_valid <= 1'b0;
        end

        if(fpu_valid)
        begin
            fpu_valid <= 1'b0;
        end
    end
end

genvar k;
generate
    for(k=0;k<64;k=k+1)
    begin:int8tofp16
    int8tofp16 int8tofp16(
        .data_int8(r_data_resadd[8*(k+1)-1:8*k]),
        .result_fp16(resadd_int8tofp16[16*(k+1)-1:16*k])
    );
    end
endgenerate

always @(*)
begin
    if(insn_resadd_para_type[1]==1'b0)
        resadd_data_temp = resadd_int8tofp16;//int8
    else if(insn_resadd_para_type[1]==1'b1)
        resadd_data_temp = r_data_resadd;//fp16
end

always @(*)
begin
    if(insn_resadd_para_type==2'b11)
        resadd_data_in_type = 1'b1;
    else
        resadd_data_in_type = 1'b0;
end

always @(posedge clk) 
begin
    if(rst)
    begin
        constant_resadd <= 'd0;
    end
    else
    begin
        if((state==DATA_PREPARE)&&insn_resadd_ram_valid)
        begin
            constant_resadd <= resadd_data_temp;
        end
        else
        begin
            constant_resadd <= constant_resadd;
        end
    end
end

assign vcu_result_temp = insn_fpu_work?fpu_result:operator_data;

///////////////////////////////////////////////并行度问题需要额外讨论
always @(*)
begin
    if(insn_ram_data_out_type)
    begin
        vcu_result = vcu_result_temp[511:0];
    end
    else
    begin
        vcu_result = result_quan;
    end
end

//output address process
//回存的数据全�?512bit，包括回存进acc_ram�?
always @(posedge clk)
begin
    if(rst)
    begin
        w_data_ofmap <= 'd0;
        w_data_inp <= 'd0;
        w_data_acc <= 'd0;
        w_en_ofmap <= 'd0;
        w_en_inp <= 'd0;
        w_en_acc <= 'd0;
    end
    else
    begin
        if(next_state == OVER)
        begin
            if(insn_ram_out_mode== 2'b00)
            begin
                w_data_inp <= vcu_result_temp;
                w_en_inp <= 1'b1;
            end
            else if(insn_ram_out_mode== 2'b01)
            begin
                w_data_ofmap <= vcu_result_temp;
                w_en_ofmap <= 1'b1;
            end
            else if(insn_ram_out_mode == 2'b10)
            begin
                w_en_acc <= 1'b1;
                if(insn_fpu_work)
                    w_data_acc <= {1024'b0,vcu_result_temp};
                else
                    w_data_acc <= {1536'b0,vcu_result_temp};
            end
        end

        if(w_en_ofmap)
        begin
            w_en_ofmap <= 'd0;
        end

        if(w_en_inp)
        begin
            w_en_inp <= 'd0;
        end

        if(w_en_acc)
        begin
            w_en_acc <= 'd0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        inp_data_out_type <= 'd0;
        ofmap_data_out_type <= 'd0;
        acc_data_out_type <= 'd0;
    end
    else
    begin
        if(insn_ram_out_mode== 2'b00)
            inp_data_out_type <= ~insn_ram_data_out_type;
        else if(insn_ram_out_mode== 2'b00)
            ofmap_data_out_type <= ~insn_ram_data_out_type;
        else if(insn_ram_out_mode == 2'b10)
            acc_data_out_type <= ~insn_ram_data_out_type;
    end
end

// always @(*)
// begin
//     if((state!=OVER)&&(next_state==OVER))
//     begin
//         if(insn_ram_out_mode== 2'b00)
//             w_en_inp = 1'b1;
//         else
//             w_en_inp = 1'b0;

//         if(insn_ram_out_mode== 2'b01)
//             w_en_ofmap = 1'b1;
//         else
//             w_en_ofmap = 1'b0;

//         if(insn_ram_out_mode == 2'b10)
//             w_en_acc = 1'b1;
//         else
//             w_en_acc = 1'b0;
//     end
//     else
//     begin
//         w_en_inp = 1'b0;
//         w_en_ofmap = 1'b0;
//         w_en_acc = 1'b0;
//     end
// end


always @(posedge clk)
begin
    if(rst)
    begin
        compute_count <= 'd0;
        // fpu_compute_coutinue <= 'd0;
        vcu_done <= 'd0;
        fpu_done_temp <= 'd0;
        para_channel_count <= 'd0;
    end
    else
    begin
        if(work)
        begin
            fpu_done_temp <= fpu_done;

            // if(compute_count == insn_compute_length+1)
            if(vcu_done)
            begin
                compute_count <= 'd0;
            end
            else
            begin
                if(data_prepare_complete_temp)
                begin
                    compute_count <= compute_count + 1;
                end
                else
                begin
                    compute_count <= compute_count;
                end

                // if(data_prepare_complete_temp)
                // begin
                    // fpu_compute_coutinue <= 1'b1;
                // end
            end

            if(next_state == OVER)
            begin
                if(insn_type == 1'b1)
                begin
                    vcu_done <= 1'b1;

                end
                else
                begin
                    if(compute_count == insn_compute_length)
                    begin
                        vcu_done <= 1'b1;
                    end
                    else
                    begin
                        vcu_done <= 1'b0;
                    end
                end
            end

            if((para_channel_count==insn_para_channel_stride)&&insn_mult_para)
            begin
                para_channel_count <= 'd0;
            end
            else
            begin
                if(fpu_done)
                begin
                    para_channel_count <= para_channel_count + 1;
                end
                else
                begin
                    para_channel_count <= para_channel_count;
                end
            end
        end

        // if(fpu_compute_coutinue)
        // begin
        //     fpu_compute_coutinue <= 1'b0;
        // end

        if(vcu_done)
        begin
            vcu_done <= 'd0;
        end
    end
end

always @(*)
begin
    if((compute_count<insn_compute_length)&&(state==OVER))
        fpu_compute_coutinue = 1'b1;
    else
        fpu_compute_coutinue = 1'b0;
end

genvar m;
generate
    for(m=0;m<N;m=m+1)
    begin:quantize
    fp16toint8 fp16toint8(
        .data_fp16(vcu_result_temp[16*(m+1)-1:16*m]),
        .result_int8(result_quan[8*(m+1)-1:8*m])
        );
    end
endgenerate

genvar j;
generate
    for(j=0;j<N;j=j+1)
    begin:dequantize
        int32tofp16 int32tofp16( 
            .data_int32(r_data_acc[32*(j+1)-1:32*j]),
            .shift_number(constant_para[16*j+5:16*j]),
            .result_fp16(data_dequan_int32[16*(j+1)-1:16*j])
            );
    end
endgenerate

assign insn_opcode_sram_address = insn_fpu[19:10];
assign insn_opcode_number = insn_fpu[9:0];

always @(posedge clk)
begin
    if(rst)
    begin
        addition_constant_0 <= 16'b0_01111_0000000000;
        addition_constant_1 <= 16'b0_01111_0000000000;
        addition_constant_2 <= 16'b0_01111_0000000000;
        multiplication_constant_0 <= 16'b0_00000_0000000000;
        multiplication_constant_1 <= 'd0;
        multiplication_constant_2 <= 'd0;
        compare_constant <= 'd0;
        para_config_complete <= 1'b0;
    end
    else
    begin
        if(next_state == PARA_CONFIG)
        begin
            addition_constant_0 <= insn[19:4];
            addition_constant_1 <= insn[35:20];
            addition_constant_2 <= insn[51:36];
            multiplication_constant_0 <= insn[67:52];
            multiplication_constant_1 <= insn[83:68];
            multiplication_constant_2 <= insn[99:84];
            compare_constant <= insn[115:100];
            para_config_complete <= 1'b1;
        end
        else
        begin
            addition_constant_0 <= addition_constant_0;
            addition_constant_1 <= addition_constant_1;
            addition_constant_2 <= addition_constant_2;
            multiplication_constant_0 <= multiplication_constant_0;
            multiplication_constant_1 <= multiplication_constant_1;
            multiplication_constant_2 <= multiplication_constant_2;
            compare_constant <= global_para[111:96];
            para_config_complete <= 1'b0;
        end
    end
end

/////////可能不太需要
always @(posedge clk)
begin
    if(rst)
    begin
        operator_number <= 'd0;
    end
    else
    begin
        if(fpu_valid)
        begin
            operator_number <= insn_opcode_number;
        end
    end
end

//opcode ram address
always @(posedge clk)
begin
    if(rst)
    begin
        r_addr_opcode <= 'd0;
    end
    else
    begin
        if(fpu_valid)
        begin
            r_addr_opcode <= insn_opcode_sram_address;
        end
        else
        begin
            if(operator_complete_all)
            begin
                r_addr_opcode <= r_addr_opcode + 1;
            end
            else
            begin
                r_addr_opcode <= r_addr_opcode;
            end
        end
    end
end

//opcode ram enable
always @(posedge clk)
begin
    if(rst)
    begin
        r_en_opcode <= 'd0;
    end
    else
    begin
        if(fpu_valid)
        begin
            r_en_opcode <= 1'b1;
        end
        else if(compute_complete)
        begin
            r_en_opcode <= 1'b0;
        end
        else
        begin
            r_en_opcode <= r_en_opcode;
        end
    end
end

two_port_ram_16x1024 two_port_ram_16x1024_opcode(
    .w_clk(clk), 
    .w_addr(w_addr_opcode), 
    .w_en(w_en_opcode), 
    .w_data(w_data_opcode),
    .r_clk(clk), 
    .r_addr(r_addr_opcode), 
    .r_en(r_en_opcode), 
    .r_data(r_data_opcode)
);

assign execute_code = r_data_opcode[8:0];// low bit cut
assign operation_code = execute_code[8:5];
assign configuration_code = execute_code[4:3];
assign constant_code = execute_code[2:0];

always @(posedge clk)
begin
    if(rst)
    begin
        iteration_data <= 'd0;
        constant_data <= 'd0; 
    end
    else
    begin
        if(operator_complete_all == 1'b1)
        begin
            if(configuration_code[0] == 1'b0)
            begin
                iteration_data <= output_result;
            end
            else
            begin
                constant_data <= output_result;
            end
        end
        else
        begin
            iteration_data <= iteration_data;
            constant_data <= constant_data;
        end
    end
end

always@(posedge clk)
begin
    if(rst)
    begin
        fpu_result <= 'd0;
        fpu_done <= 'd0;
    end
    else
    begin
        if(compute_complete)
        begin
            fpu_done <= 1'b1;
            fpu_result <= iteration_data;
        end
        else
        begin
            fpu_done<= 'd0;
            fpu_result <= 'd0;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        operator_count <= 'd0;
    end
    else
    begin
        if(operator_count < insn_opcode_number)
        begin
            if(operator_complete_all == 1'b1)
            begin
                operator_count <= operator_count + 1;
            end
            else
            begin
                operator_count <= operator_count;
            end
        end
        else
        begin
            operator_count <= 'd0;
        end
    end
end

always @(*)
begin
    if(operator_count == insn_opcode_number)
    begin
        compute_complete = 1'b1;
    end
    else
    begin
        compute_complete = 1'b0;
    end
end

assign operator_complete_all = operator_complete[0];//

genvar i;
generate
    for(i=0;i<=N-1;i=i+1)
    begin:operator
    operator operator(
    .clk(clk),
    .rst(rst),
    .state(state[1:0]),
    .constant_code(constant_code),
    .operation_code(operation_code),
    .configuration_code(configuration_code),
    .data(operator_data[16*(i+1)-1:16*i]),
    .iteration_data(iteration_data[16*(i+1)-1:16*i]),
    .constant_data(constant_data[16*(i+1)-1:16*i]),
    .constant_para(constant_para[16*(i+1)-1:16*i]),
    .constant_resadd(constant_resadd[16*(i+1)-1:16*i]),
    .addition_constant_0(addition_constant_0),
    .addition_constant_1(addition_constant_1),
    .addition_constant_2(addition_constant_2),
    .compare_constant(compare_constant),
    .multiplication_constant_0(multiplication_constant_0),
    .multiplication_constant_1(multiplication_constant_1),
    .multiplication_constant_2(multiplication_constant_2),
    .output_result(output_result[16*(i+1)-1:16*i]),
    .operator_complete(operator_complete[i]),
    .change_para(change_para)
    );
    end
endgenerate

endmodule