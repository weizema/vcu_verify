`timescale 1ps/1ps

module int32tofp16(data_int32,shift_number,result_fp16);

input wire signed [31:0]data_int32;
input wire signed [5:0]shift_number;

output wire [15:0]result_fp16;

wire [5:0]zero_cnt;

reg [32:0]data_true_form_int33;
reg [31:0]negative_data_temp;

always @(*)
begin
    if(data_int32[31] == 1'b0)
    begin
        data_true_form_int33 = {data_int32[31],1'b0,data_int32[30:0]};
    end
    else
    begin
        negative_data_temp = ~data_int32+1;
        data_true_form_int33 = {data_int32[31],negative_data_temp};
    end
end

lzd lzd(
    .data_int33(data_true_form_int33),
    .zero_cnt(zero_cnt)
);

wire signed [6:0]exp_shift_int32;
wire signed [6:0]exp_shift_int32_temp;
wire [31:0]data_shift_int32;

assign data_shift_int32 = data_true_form_int33[31:0]<<zero_cnt;
assign exp_shift_int32_temp = 31-zero_cnt;
assign exp_shift_int32 = exp_shift_int32_temp-shift_number;

wire [11:0]fraction;

assign fraction = data_shift_int32[31:21]+data_shift_int32[20];

reg signed [6:0]exp_roundoff_int32;
reg [10:0]fraction_roundoff;

always @(*)
begin
    if(fraction[11] == 1'b1)
    begin
        exp_roundoff_int32 = exp_shift_int32 + 1;
        fraction_roundoff = fraction[11:1];
    end
    else
    begin
        exp_roundoff_int32 = exp_shift_int32;
        fraction_roundoff = fraction[10:0];
    end
end

wire signal_fp16;
reg [4:0]exp_fp16;
reg [9:0]mantissa_fp16;
wire [10:0]fraction_roundoff_shift;

assign fraction_roundoff_shift = fraction_roundoff>>-(15+exp_roundoff_int32);

assign signal_fp16 = data_int32[31];

always @(*)
begin
    if(exp_roundoff_int32 >= 16)
    begin
        exp_fp16 = 5'b1111_0;
        mantissa_fp16 = 10'b1111_1111_11;
    end
    else if(exp_roundoff_int32<=15&&exp_roundoff_int32>=-14)
    begin
        exp_fp16 = exp_roundoff_int32+15;
        mantissa_fp16 = fraction_roundoff[9:0];
    end
    else if(exp_roundoff_int32<=-15&&exp_roundoff_int32>=-24)
    begin
        exp_fp16 = 5'b0000_0;
        mantissa_fp16 = fraction_roundoff_shift[10:1]+fraction_roundoff_shift[0];
    end
    else//exp_roundoff_int32<=-25
    begin
        exp_fp16 = 5'b0000_0;
        mantissa_fp16 = 10'b0000_0000_00;
    end
end

assign result_fp16 = {signal_fp16,exp_fp16,mantissa_fp16};

endmodule