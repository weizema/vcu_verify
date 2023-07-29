`timescale 1ps/1ps

module operator(state,clk,rst,constant_code,operation_code,configuration_code,
                data,iteration_data,constant_data,constant_para,constant_resadd,
                addition_constant_0,addition_constant_1,addition_constant_2,
                multiplication_constant_0,multiplication_constant_1,multiplication_constant_2,
                compare_constant,
                output_result,operator_complete);

parameter fp_data_width = 16;
parameter FPU_COMPUTE = 3'b010;

parameter ADDITION = 4'b0000;
parameter MULTIOPLICATION = 4'b0001;
parameter LN=4'b0010;
parameter INVERTION = 4'b0011;
parameter EXPONENT = 4'b0100;
parameter RECIPROCAL = 4'b0101;
parameter COMPARE = 4'b0110;
parameter STOP = 4'b1111;

input wire [1:0]state;
input rst;
input clk;

input wire [2:0]constant_code;
input wire [3:0]operation_code;
input wire [1:0]configuration_code;

input wire [fp_data_width-1:0]data;
input wire [fp_data_width-1:0]iteration_data;
input wire [fp_data_width-1:0]constant_data;
input wire [fp_data_width-1:0]constant_para;
input wire [fp_data_width-1:0]constant_resadd;

input wire [fp_data_width-1:0]addition_constant_0;
input wire [fp_data_width-1:0]addition_constant_1;
input wire [fp_data_width-1:0]addition_constant_2;

input wire [fp_data_width-1:0]multiplication_constant_0;
input wire [fp_data_width-1:0]multiplication_constant_1;
input wire [fp_data_width-1:0]multiplication_constant_2;

input wire [fp_data_width-1:0]compare_constant;

output reg [fp_data_width-1:0]output_result;
output wire operator_complete;

wire [fp_data_width-1:0]mult_result;
wire [fp_data_width-1:0]addition_result;
wire [fp_data_width-1:0]ln_result;
wire [fp_data_width-1:0]exp_result;
wire [fp_data_width-1:0]reciprocal_result;
wire [fp_data_width-1:0]invertion_result;
wire [fp_data_width-1:0]comp_result;

reg addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid;
reg [fp_data_width-1:0]input_data;

wire mult_complete;
wire addition_complete;
wire exp_complete;
wire ln_complete;
wire reciprocal_complete;
wire invertion_complete;
wire comp_complete;

reg [fp_data_width-1:0]addition_constant_data;
reg [fp_data_width-1:0]mult_constant_data;

always @(*)
begin
    case(constant_code)
        3'b000:
        begin
            addition_constant_data = addition_constant_0;
            mult_constant_data = multiplication_constant_0;
        end
        3'b001:
        begin
            addition_constant_data = addition_constant_1;
            mult_constant_data = multiplication_constant_1;
        end
        3'b010:
        begin
            addition_constant_data = addition_constant_2;
            mult_constant_data = multiplication_constant_2;
        end
        3'b011:
        begin
            addition_constant_data = constant_data;
            mult_constant_data = constant_data;
        end
        3'b100:
        begin
            addition_constant_data = constant_para;
            mult_constant_data = constant_para;
        end
        3'b101:
        begin
            addition_constant_data = constant_resadd;
            mult_constant_data = constant_resadd;
        end
    endcase
end

//这个地方需要思考一下
reg operator_complete_temp;

always @(posedge clk)
begin
    if(rst)
    begin
        operator_complete_temp <= 'd0;
    end
    else
    begin
        operator_complete_temp <= operator_complete;
    end
end

reg [3:0]operation_code_temp;

always @(*)
begin
    if(operator_complete_temp)
    begin
        operation_code_temp = 4'b1111;
    end
    else
    begin
        operation_code_temp = operation_code;
    end
end


always@(*)
begin
    if(state == FPU_COMPUTE)
    begin
        case(operation_code_temp)
            ADDITION:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b1000000;
            MULTIOPLICATION:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0100000;
            LN:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0010000;
            INVERTION:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0001000;
            EXPONENT:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0000100;
            RECIPROCAL:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0000010;
            COMPARE:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0000001;
            default:{addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0000000;
        endcase
    end
    else
    begin
        {addition_valid,mult_valid,ln_valid,invertion_valid,exp_valid,reciprocal_valid,comp_valid} = 7'b0000000;
    end
end

always @(*)
begin
    case(configuration_code[1])
        1'b0:input_data = data;
        1'b1:input_data = iteration_data;
    endcase
end

always@(*)
begin
    case(operation_code)
        ADDITION:output_result = addition_result;
        MULTIOPLICATION:output_result = mult_result;
        LN:output_result = ln_result;
        INVERTION:output_result = invertion_result;
        EXPONENT:output_result = exp_result;
        RECIPROCAL:output_result = reciprocal_result;
        COMPARE:output_result = comp_result;
    endcase
end

assign operator_complete = mult_complete|addition_complete|exp_complete|ln_complete|reciprocal_complete|invertion_complete|comp_complete;


addition_fp16 addition_fp16(
    .data1(input_data),
    .data2(addition_constant_data),
    .data_valid(addition_valid),
    .clk(clk),
    .rst(rst),
    .result(addition_result),
    .complete(addition_complete)
);

mult_float16 mult_float16(
    .data1(input_data),
    .data2(mult_constant_data),
    .data_valid(mult_valid),
    .clk(clk),
    .rst(rst),
    .result(mult_result),
    .complete(mult_complete)
);

invertion invertion(
    .data(input_data),
    .data_valid(invertion_valid),
    .clk(clk),
    .rst(rst),
    .result(invertion_result),
    .complete(invertion_complete)
);

exp_float16 exp_float16(
    .data(input_data),
    .data_valid(exp_valid),
    .clk(clk),
    .rst(rst),
    .result(exp_result),
    .complete(exp_complete)
);

reciprocal reciprocal(
    .data(input_data),
    .data_valid(reciprocal_valid),
    .rst(rst),
    .clk(clk),
    .result(reciprocal_result),
    .complete(reciprocal_complete)
);

ln_float16 ln_float16(
    .data(input_data),
    .data_valid(ln_valid),
    .clk(clk),
    .rst(rst),
    .result(ln_result),
    .complete(ln_complete)
);

compare compare(
    .data(data),
    .iteration_data(iteration_data),
    .constant_data(constant_data),
    .constant(compare_constant),
    .data_valid(comp_valid),
    .rst(rst),
    .clk(clk),
    .result(comp_result),
    .complete(comp_complete)
    );

endmodule