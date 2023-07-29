`timescale 1ps/1ps

module lzd(data_int33,zero_cnt);

input wire[32:0]data_int33;
output reg [5:0]zero_cnt;

wire [15:0]data_left;
wire [15:0]data_right;

reg [4:0]zero_cnt_left;
reg [4:0]zero_cnt_right;

assign data_left = data_int33[31:16];
assign data_right = data_int33[15:0];

always@(*)
begin
    casex(data_left)
        16'b1xxx_xxxx_xxxx_xxxx:zero_cnt_left = 5'd0;
        16'b01xx_xxxx_xxxx_xxxx:zero_cnt_left = 5'd1;
        16'b001x_xxxx_xxxx_xxxx:zero_cnt_left = 5'd2;
        16'b0001_xxxx_xxxx_xxxx:zero_cnt_left = 5'd3;
        16'b0000_1xxx_xxxx_xxxx:zero_cnt_left = 5'd4;
        16'b0000_01xx_xxxx_xxxx:zero_cnt_left = 5'd5;
        16'b0000_001x_xxxx_xxxx:zero_cnt_left = 5'd6;
        16'b0000_0001_xxxx_xxxx:zero_cnt_left = 5'd7;
        16'b0000_0000_1xxx_xxxx:zero_cnt_left = 5'd8;
        16'b0000_0000_01xx_xxxx:zero_cnt_left = 5'd9;
        16'b0000_0000_001x_xxxx:zero_cnt_left = 5'd10;
        16'b0000_0000_0001_xxxx:zero_cnt_left = 5'd11;
        16'b0000_0000_0000_1xxx:zero_cnt_left = 5'd12;
        16'b0000_0000_0000_01xx:zero_cnt_left = 5'd13;
        16'b0000_0000_0000_001x:zero_cnt_left = 5'd14;
        16'b0000_0000_0000_0001:zero_cnt_left = 5'd15;
        16'b0000_0000_0000_0000:zero_cnt_left = 5'd16;
        default:zero_cnt_left = 0;
    endcase
end

always@(*)
begin
    casex(data_right)
        16'b1xxx_xxxx_xxxx_xxxx:zero_cnt_right = 5'd0;
        16'b01xx_xxxx_xxxx_xxxx:zero_cnt_right = 5'd1;
        16'b001x_xxxx_xxxx_xxxx:zero_cnt_right = 5'd2;
        16'b0001_xxxx_xxxx_xxxx:zero_cnt_right = 5'd3;
        16'b0000_1xxx_xxxx_xxxx:zero_cnt_right = 5'd4;
        16'b0000_01xx_xxxx_xxxx:zero_cnt_right = 5'd5;
        16'b0000_001x_xxxx_xxxx:zero_cnt_right = 5'd6;
        16'b0000_0001_xxxx_xxxx:zero_cnt_right = 5'd7;
        16'b0000_0000_1xxx_xxxx:zero_cnt_right = 5'd8;
        16'b0000_0000_01xx_xxxx:zero_cnt_right = 5'd9;
        16'b0000_0000_001x_xxxx:zero_cnt_right = 5'd10;
        16'b0000_0000_0001_xxxx:zero_cnt_right = 5'd11;
        16'b0000_0000_0000_1xxx:zero_cnt_right = 5'd12;
        16'b0000_0000_0000_01xx:zero_cnt_right = 5'd13;
        16'b0000_0000_0000_001x:zero_cnt_right = 5'd14;
        16'b0000_0000_0000_0001:zero_cnt_right = 5'd15;
        16'b0000_0000_0000_0000:zero_cnt_right = 5'd16;
        default:zero_cnt_right = 0;
    endcase
end

always @(*)
begin
    if(zero_cnt_left == 5'd16)
    begin
        zero_cnt = zero_cnt_left + zero_cnt_right;
    end
    else
    begin
        zero_cnt = zero_cnt_left;
    end
end

endmodule