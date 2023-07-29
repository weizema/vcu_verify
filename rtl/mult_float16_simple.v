`timescale 1ps/1ps

module mult_float16_simple(data1,data2,result);

input wire [15:0]data1,data2;
output reg [15:0]result;

wire result_signal;

wire signed [6:0]exponent;
reg signed[5:0]exp_roundoff;

wire [10:0]fraction1,fraction2;
wire [21:0]fraction;
reg [11:0]frac_roundoff;

reg [4:0]result_exponent;
reg [9:0]result_fraction;

assign result_signal = data1[15]&data2[15];
assign fraction1 = {1'b1,data1[9:0]};
assign fraction2 = {1'b1,data2[9:0]};
assign fraction = fraction1*fraction2;
assign exponent = data1[14:10]+data2[14:10]-15;

always@(*)
begin
    frac_roundoff = fraction[21:10]+fraction[9];
    if(frac_roundoff[11])
    begin
        exp_roundoff = exponent + 1;
        if(exp_roundoff<=0)
        begin
            result_exponent = 5'b00001;
            result_fraction = 10'b0000000000;
        end
        else if(exp_roundoff>=31)
        begin
            result_exponent = 5'b11110;
            result_fraction = 10'b1111111111;
        end
        else 
        begin
            result_exponent = exp_roundoff[4:0];
            //result_fraction = frac_roundoff[10:1]+frac_roundoff[0];
            result_fraction = frac_roundoff[10:1];
        end
    end
    else 
    begin
        exp_roundoff = exponent;
        if(exp_roundoff<=0)
        begin
            result_exponent = 5'b00001;
            result_fraction = 10'b0000000000;
        end
        else if(exp_roundoff>=31)
        begin
            result_exponent = 5'b11110;
            result_fraction = 10'b1111111111;
        end
        else
        begin
            result_exponent = exp_roundoff[4:0];
            result_fraction = frac_roundoff[9:0];
        end 
    end
end

always@(*)
begin
    if(data1==0||data2==0)
        result = 16'b0_00000_0000000000;
    else
        result = {result_signal,result_exponent,result_fraction};
end

endmodule