`timescale 1ps/1ps

module addition_fp16(data1,data2,data_valid,clk,rst,result,complete);

input wire [15:0]data1,data2;
input wire data_valid;
input wire clk;
input wire rst;

output wire [15:0]result;
output reg complete;

wire data1_signal,data2_signal;
wire [4:0]data1_exp,data2_exp;
wire [9:0]data1_mantissa,data2_mantissa;

reg max_signal,min_signal;
reg [4:0]max_exp_temp,min_exp_temp;
reg [9:0]max_mantissa,min_mantissa;

reg [4:0]max_exp,min_exp;
reg [22:0]max_frac,min_frac;

wire [4:0]shift_number_min;
wire [22:0]shift_frac;

wire flag;

reg [22:0]fraction;

wire signed [6:0]exponent_shift;
wire [22:0]fraction_shift;

reg [15:0]data1_temp,data2_temp;

always @(posedge clk)
begin
    if(rst)
    begin
        data1_temp <= 'd0;
        data2_temp <= 'd0;
    end
    else
    begin
        if(data_valid)
        begin
            data1_temp <= data1;
            data2_temp <= data2;
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        complete <= 'd0;
    end
    else
    begin
        if(data_valid&&!complete)
        begin
            complete <= 1'b1;
        end
        else
        begin
            complete <= 1'd0;
        end
    end
end

assign data1_signal = data1_temp[15];
assign data1_exp = data1_temp[14:10];
assign data1_mantissa = data1_temp[9:0];
assign data2_signal = data2_temp[15];
assign data2_exp = data2_temp[14:10];
assign data2_mantissa = data2_temp[9:0];

always @(*)
begin
    if(data1_temp[14:0]>=data2_temp[14:0])
    begin
        max_signal = data1_signal;
        max_exp_temp = data1_exp;
        max_mantissa = data1_mantissa;
        min_signal = data2_signal;
        min_exp_temp = data2_exp;
        min_mantissa = data2_mantissa;
    end
    else 
    begin
        max_signal = data2_signal;
        max_exp_temp = data2_exp;
        max_mantissa = data2_mantissa;
        min_signal = data1_signal;
        min_exp_temp = data1_exp;
        min_mantissa = data1_mantissa;
    end
end

always @(*)
begin
    if(max_exp_temp == 5'b00000)
    begin
        max_exp = 5'b00001;
        max_frac = {2'b00,max_mantissa,11'b0000_0000_000};
    end
    else
    begin
        max_exp = max_exp_temp;
        max_frac = {2'b01,max_mantissa,11'b0000_0000_000};
    end
end

always @(*)
begin
    if(min_exp_temp == 5'b00000)
    begin
        min_exp = 5'b00001;
        min_frac = {2'b00,min_mantissa,11'b0000_0000_000};
    end
    else
    begin
        min_exp = min_exp_temp;
        min_frac = {2'b01,min_mantissa,11'b0000_0000_000};
    end
end

assign shift_number_min = max_exp-min_exp;
assign shift_frac = min_frac>>shift_number_min;

assign flag = max_signal^min_signal;//same:flag = 0 different:flag = 1

always@(*)
begin
    if(flag == 0)
        fraction = max_frac + shift_frac;
    else
        fraction = max_frac - shift_frac;
end

reg [3:0]shift_number;

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

reg signed [6:0]exponent_normalization;
reg [22:0]fraction_nomalization;
reg [11:0]retrain_fraction;
reg [11:0]trunction_fraction_temp;
wire [21:0]trunction_fraction;

always@(*)
begin
    if(exponent_shift > 0)
    begin
        if(fraction_shift[22] == 1'b1)
        begin
            fraction_nomalization = fraction_shift;
            exponent_normalization = exponent_shift + 1;
            retrain_fraction = {1'b0,fraction_nomalization[22:12]}; 
            trunction_fraction_temp = fraction_nomalization[11:0];
        end
        else
        begin
            fraction_nomalization = fraction_shift;
            exponent_normalization = exponent_shift;
            retrain_fraction = fraction_nomalization[22:11];
            trunction_fraction_temp = {fraction_nomalization[10:0],1'b0}; 
        end
    end
    else
    begin
        fraction_nomalization = fraction_shift>>(-exponent_shift);
        exponent_normalization = 5'b00000;
        retrain_fraction = {1'b0,fraction_nomalization[22:12]}; 
        trunction_fraction_temp = fraction_nomalization[11:0];
    end
end

assign trunction_fraction = {trunction_fraction_temp,10'b0000_0000_00};

reg [11:0]fraction_roundoff_first;

always@(*)
begin
    if(trunction_fraction > 22'b1000_0000_0000_0000_0000_00)
    begin
        fraction_roundoff_first = retrain_fraction + 1;
    end
    else if(trunction_fraction == 22'b1000_0000_0000_0000_0000_00)
    begin
        if(retrain_fraction[0] == 1'b1)
        begin
            fraction_roundoff_first = retrain_fraction + 1;
        end
        else
        begin
            fraction_roundoff_first = retrain_fraction;
        end
    end
    else
    begin
        fraction_roundoff_first = retrain_fraction;
    end
end

reg [9:0]fraction_roundoff_second;
reg [5:0]exponent_roundoff;

always@(*)
begin
    if(exponent_normalization == 0)
    begin
        if(fraction_roundoff_first[10] == 1'b1)
        begin
            exponent_roundoff = 5'b00001;
            fraction_roundoff_second = fraction_roundoff_first[9:0];
        end
        else
        begin
            exponent_roundoff = 5'b00000;
            fraction_roundoff_second = fraction_roundoff_first[9:0];
        end
    end
    else
    begin
        if(fraction_roundoff_first[11] == 1'b1)
        begin
            exponent_roundoff = exponent_normalization + 1;
            fraction_roundoff_second = fraction_roundoff_first[10:1];
        end
        else
        begin
            exponent_roundoff = exponent_normalization;
            fraction_roundoff_second = fraction_roundoff_first[9:0];
        end
    end
end

reg result_signal;
reg [4:0]result_exp;
reg [9:0]result_mantissa;

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
        if(exponent_roundoff > 30)
        begin
            result_exp = 5'b11110;
            result_mantissa = 10'b1111_1111_11;
        end
        else
        begin
            result_exp = exponent_roundoff[4:0];
            result_mantissa = fraction_roundoff_second;
        end
    end
end

assign result = {result_signal,result_exp,result_mantissa};

endmodule