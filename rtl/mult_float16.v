`timescale 1ps/1ps

//only logic circuit
module mult_float16(data1,data2,data_valid,clk,rst,result,complete);

input wire [15:0]data1,data2;
input wire data_valid;
input wire clk;
input wire rst;

output wire [15:0]result;
output reg complete;

wire data1_signal,data2_signal;
wire [4:0]data1_exp,data2_exp;
wire [9:0]data1_mantissa,data2_mantissa;

wire result_signal;

reg [10:0]data1_fraction,data2_fraction;
reg [4:0]data1_exponent,data2_exponent;

wire signed [6:0]exponent;
wire [21:0]fraction;

reg [3:0]shift_number;

wire signed [6:0]exponent_shift;
wire [31:0]fraction_shift;

reg signed [6:0]exponent_normalization;
reg [31:0]fraction_nomalization;
reg [11:0]retrain_fraction;
reg [20:0]trunction_fraction;

reg [11:0]fraction_roundoff_first;

reg [9:0]fraction_roundoff_second;
reg [5:0]exponent_roundoff;

reg [4:0]result_exponent;
reg [9:0]result_mantissa;

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

assign result_signal = data1_temp[15]^data2_temp[15];

always @(*)
begin
    if(data1_exp == 5'b00000)
    begin
        data1_exponent = 5'b00001;
        data1_fraction = {1'b0,data1_mantissa};
    end
    else
    begin
        data1_exponent = data1_exp;
        data1_fraction = {1'b1,data1_mantissa};
    end
end

always @(*)
begin
    if(data2_exp == 5'b00000)
    begin
        data2_exponent = 5'b00001;
        data2_fraction = {1'b0,data2_mantissa};
    end
    else
    begin
        data2_exponent = data2_exp;
        data2_fraction = {1'b1,data2_mantissa};
    end
end

assign fraction = data1_fraction*data2_fraction;
assign exponent = data1_exponent+data2_exponent-15;

always @(*)
begin
    if(fraction[21:19] == 3'b001)
        shift_number = 1;
    else if(fraction[21:18] == 4'b0001)
        shift_number = 2;
    else if(fraction[21:17] == 5'b00001)
        shift_number = 3;
    else if(fraction[21:16] == 6'b000001)
        shift_number = 4;
    else if(fraction[21:15] == 7'b0000001)
        shift_number = 5;
    else if(fraction[21:14] == 8'b00000001)
        shift_number = 6;
    else if(fraction[21:13] == 9'b000000001)
        shift_number = 7;
    else if(fraction[21:12] == 10'b0000000001)
        shift_number = 8;
    else if(fraction[21:11] == 11'b00000000001)
        shift_number = 9;
    else if(fraction[21:10] == 12'b000000000001)
        shift_number = 10;
    else
        shift_number = 0;
end

assign exponent_shift = exponent-shift_number;
assign fraction_shift = {fraction<<shift_number,10'b0000000000};

always @(*)
begin
    if(exponent_shift>0)
    begin
        if(fraction_shift[31] == 1'b1)
        begin
            exponent_normalization = exponent_shift + 1;
            fraction_nomalization = fraction_shift;
            retrain_fraction = {1'b0,fraction_nomalization[31:21]};
            trunction_fraction = fraction_nomalization[20:0];
        end
        else
        begin
            exponent_normalization = exponent_shift;
            fraction_nomalization = fraction_shift;
            retrain_fraction = fraction_nomalization[31:20];
            trunction_fraction = {fraction_nomalization[19:0],1'b0};
        end
    end
    else
    begin
        fraction_nomalization = fraction_shift >> (-exponent_shift);
        exponent_normalization = 'd0;
        retrain_fraction = {1'b0,fraction_nomalization[31:21]};
        trunction_fraction = fraction_nomalization[20:0];
    end
end

always @(*)
begin
    if(trunction_fraction>21'b100000000000000000000)
        fraction_roundoff_first = retrain_fraction + 1;
    else if(trunction_fraction == 21'b100000000000000000000)
    begin
        if(retrain_fraction[0] == 1'b1)
            fraction_roundoff_first = retrain_fraction + 1;
        else
            fraction_roundoff_first = retrain_fraction;
    end
    else
        fraction_roundoff_first = retrain_fraction;
end

always@(*)
begin
    if(exponent_normalization == 'd0)
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

always @(*)
begin
    if(data1 == 16'b0000_0000_0000_0000||data2 == 16'b0000_0000_0000_0000)
    begin
        result_exponent = 5'b00000;
        result_mantissa = 10'b0000000000;
    end
    else
    begin
        if(exponent_roundoff > 5'b11110)
        begin
            result_exponent = 5'b11110;
            result_mantissa = 10'b1111111111;
        end
        else
        begin
            result_exponent = exponent_roundoff;
            result_mantissa = fraction_roundoff_second;
        end
    end
end

assign result = {result_signal,result_exponent,result_mantissa};

endmodule