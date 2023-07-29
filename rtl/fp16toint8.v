`timescale 1ps/1ps

module fp16toint8(data_fp16,result_int8);

input wire [15:0]data_fp16;

output wire signed [7:0]result_int8;

reg signal_int8;
reg [7:0]true_form_int8;
reg [6:0]complement_int8;

wire signal_fp16;
wire [4:0]exp_fp16;
wire [9:0]mantissa_fp16;

assign signal_fp16 = data_fp16[15];
assign exp_fp16 = data_fp16[14:10];
assign mantissa_fp16 = data_fp16[9:0];

wire[17:0]fraction_fp16;
wire signed[4:0]shift_number;
reg [17:0]fraction_shift_fp16;

assign fraction_fp16 = {7'b0,1'b1,mantissa_fp16};
assign shift_number = exp_fp16-15;

always @(*)
begin
    if(shift_number>=0)
    begin
        fraction_shift_fp16 = fraction_fp16<<shift_number;
    end
    else
    begin
        fraction_shift_fp16 = fraction_fp16>>(-shift_number);
    end
end

always @(*)
begin
    if({exp_fp16,mantissa_fp16}<15'b01110_0000000000)
    begin
        true_form_int8 = 8'b00000000;
        signal_int8 = 1'b0;
    end
    else if(signal_fp16 == 1'b0&&{exp_fp16,mantissa_fp16}>=15'b10101_1111111000)
    begin
        true_form_int8 = 8'b01111111;
        signal_int8 = signal_fp16;
    end
    else if(signal_fp16 == 1'b1&&{exp_fp16,mantissa_fp16}>= 15'b10110_0000000100)
    begin
        true_form_int8 = 8'b10000000;
        signal_int8 = signal_fp16;
    end
    else
    begin
        true_form_int8 = fraction_shift_fp16[17:10]+fraction_shift_fp16[9];
        signal_int8 = signal_fp16;
    end
end

always@(*)
begin
    if(signal_int8 == 1'b0) 
    begin
        complement_int8 = true_form_int8[6:0];
    end
    else
    begin
        complement_int8 = 128-true_form_int8;
    end
end

assign result_int8 = {signal_int8,complement_int8};

endmodule