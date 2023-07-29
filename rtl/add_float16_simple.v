`timescale 1ps/1ps

module add_float16_simple(data1,data2,result);

input wire [15:0]data1;
input wire [15:0]data2;
output wire [15:0]result;

reg max_signal,min_signal;
reg [4:0]max_exp,min_exp;
reg [9:0]max_mantissa,min_mantissa;

wire [22:0]max_frac,min_frac;
wire flag;

wire [4:0]shift_number_min;
wire [22:0]shift_frac;
reg [22:0]fraction;
reg [3:0]shift_number;

wire signed [6:0]exponent_shift;
wire [22:0]fraction_shift;

wire [11:0]retain_frac;

reg signed [6:0]result_exp_temp_1;
reg [11:0]result_mantissa_temp_1;

reg [4:0]result_exp_temp_2;
reg [9:0]result_mantissa_temp_2;

reg result_signal; 
reg [4:0]result_exp;
reg [9:0]result_mantissa;


always @(*)
begin
    if(data1[14:0]>=data2[14:0])
    begin
        max_signal = data1[15];
        max_exp = data1[14:10];
        max_mantissa = data1[9:0];
        min_signal = data2[15];
        min_exp = data2[14:10];
        min_mantissa = data2[9:0];
    end
    else
    begin
        max_signal = data2[15];
        max_exp = data2[14:10];
        max_mantissa = data2[9:0];
        min_signal = data1[15];
        min_exp = data1[14:10];
        min_mantissa = data1[9:0];
    end
end

assign max_frac = {2'b01,max_mantissa,11'b00000000000};
assign min_frac = {2'b01,min_mantissa,11'b00000000000};
assign flag = max_signal^min_signal;//same:flag = 0 different:flag = 1

assign shift_number_min = max_exp-min_exp;
assign shift_frac = min_frac>>shift_number_min;

always@(*)
begin
    if(flag == 0)
        fraction = max_frac + shift_frac;
    else
        fraction = max_frac - shift_frac;
end

always @(*)
begin
    if(fraction[22:20] == 3'b001)
        shift_number = 1;
    else if(fraction[22:19] == 4'b0001)
        shift_number = 2;
    else if(fraction[22:18] == 5'b00001)
        shift_number = 3;
    else if(fraction[22:17] == 6'b000001)
        shift_number = 4;
    else if(fraction[22:16] == 7'b0000001)
        shift_number = 5;
    else if(fraction[22:15] == 8'b00000001)
        shift_number = 6;
    else if(fraction[22:14] == 9'b000000001)
        shift_number = 7;
    else if(fraction[22:13] == 10'b0000000001)
        shift_number = 8;
    else if(fraction[22:12] == 11'b00000000001)
        shift_number = 9;
    else if(fraction[22:11] == 12'b000000000001)
        shift_number = 10;
    else if(fraction[22:10] == 13'b0000000000001)
        shift_number = 11;
    else
        shift_number = 0;
end

assign exponent_shift = max_exp-shift_number;
assign fraction_shift = fraction<<shift_number;

assign retain_frac = fraction_shift[22:11]+fraction_shift[10];

always@(*)
begin
    if(retain_frac[11] == 1'b1)
    begin
        result_exp_temp_1 = exponent_shift + 1;
        result_mantissa_temp_1 = retain_frac[10:1];
    end
    else
    begin
        result_exp_temp_1 = exponent_shift;
        result_mantissa_temp_1 = retain_frac[9:0];
    end
end

always@(*)
begin
    if(result_exp_temp_1>=31)
    begin
        result_exp_temp_2 = 5'b11110;
        result_mantissa_temp_2 = 10'b1111111111;
    end
    else if(result_exp_temp_1<=0)
    begin
        result_exp_temp_2 = 5'b00000;
        result_mantissa_temp_2 = 10'b0000000000;
    end
    else
    begin
        result_exp_temp_2 = result_exp_temp_1[4:0];
        result_mantissa_temp_2 = result_mantissa_temp_1;
    end
end

always@(*)
begin
    if({min_exp,min_mantissa} == 15'b0000_0000_0000_000)
    begin
        result_signal = max_signal;
        result_exp = max_exp;
        result_mantissa = max_mantissa;
    end
    else if(min_signal != max_signal && {min_exp,min_mantissa} == {max_exp,max_mantissa})
    begin
        result_signal = 1'b0;
        result_exp = 5'b00000;
        result_mantissa = 10'b0000_0000_00;
    end
    else
    begin
        result_signal = max_signal;
        result_exp = result_exp_temp_2;
        result_mantissa = result_mantissa_temp_2;
    end
end

assign result = {result_signal,result_exp,result_mantissa};

endmodule