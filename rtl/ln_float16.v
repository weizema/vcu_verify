`timescale 1ps/1ps

module ln_float16(data,data_valid,clk,rst,result,complete);

input wire [15:0]data;
input wire data_valid;
input wire clk;
input wire rst;

output reg [15:0]result;
output reg complete;

reg [15:0]data_temp;

wire signal;
wire [4:0]exponent_temp;
wire [9:0]mantissa_temp;

reg [4:0]exponent;
reg [9:0]mantissa;

wire [6:0]mantissa_index;

reg [15:0]exp_table;
reg [15:0]frac_table;
wire [15:0]result_add;

wire [14:0]rectify_index;
reg [15:0]rectify_result;

always @(posedge clk)
begin
    if(rst)
    begin
        data_temp <= 'd0;
    end
    else 
    begin
        if(data_valid)
        begin
            data_temp <= data;
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

assign signal = data_temp[15];
assign exponent_temp = data_temp[14:10];
assign mantissa_temp = data_temp[9:0];

always @(*)
begin
    if(exponent_temp == 5'b00000)
    begin
        exponent = 5'b00001;
        mantissa = 10'b0000000000;
    end
    else 
    begin
        exponent = exponent_temp;
        mantissa = mantissa_temp;
    end
end

assign mantissa_index = mantissa[9:3];

add_float16_simple add_float16_simple(
    .data1(exp_table),
    .data2(frac_table),
    .result(result_add)
);

assign rectify_index = {exponent,mantissa};

always @(*)
begin
    if((15'b011101110111111<={exponent,mantissa})&&({exponent,mantissa}<=15'b011110001000000))
    begin
        result = rectify_result;
    end
    else
    begin
        result = result_add;
    end
end

always@(*)
begin
    case(rectify_index)
        15'b011110000000000:rectify_result = 16'b0000000000000000;
        15'b011110000000001:rectify_result = 16'b0001001111111111;
        15'b011110000000010:rectify_result = 16'b0001011111111110;
        15'b011110000000011:rectify_result = 16'b0001100111111110;
        15'b011110000000100:rectify_result = 16'b0001101111111100;
        15'b011110000000101:rectify_result = 16'b0001110011111101;
        15'b011110000000110:rectify_result = 16'b0001110111111100;
        15'b011110000000111:rectify_result = 16'b0001111011111010;
        15'b011110000001000:rectify_result = 16'b0001111111111000;
        15'b011110000001001:rectify_result = 16'b0010000001111011;
        15'b011110000001010:rectify_result = 16'b0010000011111010;
        15'b011110000001011:rectify_result = 16'b0010000101111000;
        15'b011110000001100:rectify_result = 16'b0010000111110111;
        15'b011110000001101:rectify_result = 16'b0010001001110110;
        15'b011110000001110:rectify_result = 16'b0010001011110100;
        15'b011110000001111:rectify_result = 16'b0010001101110010;
        15'b011110000010000:rectify_result = 16'b0010001111110000;
        15'b011110000010001:rectify_result = 16'b0010010000110111;
        15'b011110000010010:rectify_result = 16'b0010010001110110;
        15'b011110000010011:rectify_result = 16'b0010010010110101;
        15'b011110000010100:rectify_result = 16'b0010010011110100;
        15'b011110000010101:rectify_result = 16'b0010010100110010;
        15'b011110000010110:rectify_result = 16'b0010010101110001;
        15'b011110000010111:rectify_result = 16'b0010010110110000;
        15'b011110000011000:rectify_result = 16'b0010010111101110;
        15'b011110000011001:rectify_result = 16'b0010011000101101;
        15'b011110000011010:rectify_result = 16'b0010011001101011;
        15'b011110000011011:rectify_result = 16'b0010011010101010;
        15'b011110000011100:rectify_result = 16'b0010011011101000;
        15'b011110000011101:rectify_result = 16'b0010011100100110;
        15'b011110000011110:rectify_result = 16'b0010011101100100;
        15'b011110000011111:rectify_result = 16'b0010011110100011;
        15'b011110000100000:rectify_result = 16'b0010011111100001;
        15'b011110000100001:rectify_result = 16'b0010100000001111;
        15'b011110000100010:rectify_result = 16'b0010100000101110;
        15'b011110000100011:rectify_result = 16'b0010100001001101;
        15'b011110000100100:rectify_result = 16'b0010100001101100;
        15'b011110000100101:rectify_result = 16'b0010100010001011;
        15'b011110000100110:rectify_result = 16'b0010100010101010;
        15'b011110000100111:rectify_result = 16'b0010100011001001;
        15'b011110000101000:rectify_result = 16'b0010100011101000;
        15'b011110000101001:rectify_result = 16'b0010100100000110;
        15'b011110000101010:rectify_result = 16'b0010100100100101;
        15'b011110000101011:rectify_result = 16'b0010100101000100;
        15'b011110000101100:rectify_result = 16'b0010100101100011;
        15'b011110000101101:rectify_result = 16'b0010100110000001;
        15'b011110000101110:rectify_result = 16'b0010100110100000;
        15'b011110000101111:rectify_result = 16'b0010100110111111;
        15'b011110000110000:rectify_result = 16'b0010100111011101;
        15'b011110000110001:rectify_result = 16'b0010100111111100;
        15'b011110000110010:rectify_result = 16'b0010101000011010;
        15'b011110000110011:rectify_result = 16'b0010101000111001;
        15'b011110000110100:rectify_result = 16'b0010101001010111;
        15'b011110000110101:rectify_result = 16'b0010101001110110;
        15'b011110000110110:rectify_result = 16'b0010101010010100;
        15'b011110000110111:rectify_result = 16'b0010101010110010;
        15'b011110000111000:rectify_result = 16'b0010101011010001;
        15'b011110000111001:rectify_result = 16'b0010101011101111;
        15'b011110000111010:rectify_result = 16'b0010101100001101;
        15'b011110000111011:rectify_result = 16'b0010101100101100;
        15'b011110000111100:rectify_result = 16'b0010101101001010;
        15'b011110000111101:rectify_result = 16'b0010101101101000;
        15'b011110000111110:rectify_result = 16'b0010101110000110;
        15'b011110000111111:rectify_result = 16'b0010101110100100;
        15'b011110001000000:rectify_result = 16'b0010101111000011;

        15'b011101111111111:rectify_result = 16'b1001000000000000;
        15'b011101111111110:rectify_result = 16'b1001010000000001;
        15'b011101111111101:rectify_result = 16'b1001011000000001;
        15'b011101111111100:rectify_result = 16'b1001100000000001;
        15'b011101111111011:rectify_result = 16'b1001100100000010;
        15'b011101111111010:rectify_result = 16'b1001101000000010;
        15'b011101111111001:rectify_result = 16'b1001101100000011;
        15'b011101111111000:rectify_result = 16'b1001110000000010;
        15'b011101111110111:rectify_result = 16'b1001110010000011;
        15'b011101111110110:rectify_result = 16'b1001110100000011;
        15'b011101111110101:rectify_result = 16'b1001110110000100;
        15'b011101111110100:rectify_result = 16'b1001111000000101;
        15'b011101111110011:rectify_result = 16'b1001111010000101;
        15'b011101111110010:rectify_result = 16'b1001111100000110;
        15'b011101111110001:rectify_result = 16'b1001111110000111;
        15'b011101111110000:rectify_result = 16'b1010000000000100;
        15'b011101111101111:rectify_result = 16'b1010000001000101;
        15'b011101111101110:rectify_result = 16'b1010000010000101;
        15'b011101111101101:rectify_result = 16'b1010000011000110;
        15'b011101111101100:rectify_result = 16'b1010000100000110;
        15'b011101111101011:rectify_result = 16'b1010000101000111;
        15'b011101111101010:rectify_result = 16'b1010000110001000;
        15'b011101111101001:rectify_result = 16'b1010000111001000;
        15'b011101111101000:rectify_result = 16'b1010001000001001;
        15'b011101111100111:rectify_result = 16'b1010001001001010;
        15'b011101111100110:rectify_result = 16'b1010001010001011;
        15'b011101111100101:rectify_result = 16'b1010001011001011;
        15'b011101111100100:rectify_result = 16'b1010001100001100;
        15'b011101111100011:rectify_result = 16'b1010001101001101;
        15'b011101111100010:rectify_result = 16'b1010001110001110;
        15'b011101111100001:rectify_result = 16'b1010001111001111;
        15'b011101111100000:rectify_result = 16'b1010010000001000;
        15'b011101111011111:rectify_result = 16'b1010010000101001;
        15'b011101111011110:rectify_result = 16'b1010010001001001;
        15'b011101111011101:rectify_result = 16'b1010010001101010;
        15'b011101111011100:rectify_result = 16'b1010010010001010;
        15'b011101111011011:rectify_result = 16'b1010010010101011;
        15'b011101111011010:rectify_result = 16'b1010010011001011;
        15'b011101111011001:rectify_result = 16'b1010010011101100;
        15'b011101111011000:rectify_result = 16'b1010010100001101;
        15'b011101111010111:rectify_result = 16'b1010010100101101;
        15'b011101111010110:rectify_result = 16'b1010010101001110;
        15'b011101111010101:rectify_result = 16'b1010010101101111;
        15'b011101111010100:rectify_result = 16'b1010010110001111;
        15'b011101111010011:rectify_result = 16'b1010010110110000;
        15'b011101111010010:rectify_result = 16'b1010010111010001;
        15'b011101111010001:rectify_result = 16'b1010010111110010;
        15'b011101111010000:rectify_result = 16'b1010011000010010;
        15'b011101111001111:rectify_result = 16'b1010011000110011;
        15'b011101111001110:rectify_result = 16'b1010011001010100;
        15'b011101111001101:rectify_result = 16'b1010011001110101;
        15'b011101111001100:rectify_result = 16'b1010011010010101;
        15'b011101111001011:rectify_result = 16'b1010011010110110;
        15'b011101111001010:rectify_result = 16'b1010011011010111;
        15'b011101111001001:rectify_result = 16'b1010011011111000;
        15'b011101111001000:rectify_result = 16'b1010011100011001;
        15'b011101111000111:rectify_result = 16'b1010011100111010;
        15'b011101111000110:rectify_result = 16'b1010011101011011;
        15'b011101111000101:rectify_result = 16'b1010011101111100;
        15'b011101111000100:rectify_result = 16'b1010011110011101;
        15'b011101111000011:rectify_result = 16'b1010011110111110;
        15'b011101111000010:rectify_result = 16'b1010011111011111;
        15'b011101111000001:rectify_result = 16'b1010100000000000;
        15'b011101111000000:rectify_result = 16'b1010100000010000;
        15'b011101110111111:rectify_result = 16'b1010100000100001;
        default:rectify_result = 16'b0000000000000000;
    endcase
end

always@(*)
begin
    case(mantissa_index)
        7'b0000000:frac_table = 16'b0001101011111100;
        7'b0000001:frac_table = 16'b0010000110110111;
        7'b0000010:frac_table = 16'b0010010011010100;
        7'b0000011:frac_table = 16'b0010011011001001;
        7'b0000100:frac_table = 16'b0010100001011101;
        7'b0000101:frac_table = 16'b0010100101010011;
        7'b0000110:frac_table = 16'b0010101001001000;
        7'b0000111:frac_table = 16'b0010101100111011;
        7'b0001000:frac_table = 16'b0010110000010110;
        7'b0001001:frac_table = 16'b0010110010001110;
        7'b0001010:frac_table = 16'b0010110100000100;
        7'b0001011:frac_table = 16'b0010110101111010;
        7'b0001100:frac_table = 16'b0010110111101111;
        7'b0001101:frac_table = 16'b0010111001100100;
        7'b0001110:frac_table = 16'b0010111011010111;
        7'b0001111:frac_table = 16'b0010111101001010;
        7'b0010000:frac_table = 16'b0010111110111011;
        7'b0010001:frac_table = 16'b0011000000010110;
        7'b0010010:frac_table = 16'b0011000001001110;
        7'b0010011:frac_table = 16'b0011000010000110;
        7'b0010100:frac_table = 16'b0011000010111101;
        7'b0010101:frac_table = 16'b0011000011110100;
        7'b0010110:frac_table = 16'b0011000100101011;
        7'b0010111:frac_table = 16'b0011000101100001;
        7'b0011000:frac_table = 16'b0011000110010111;
        7'b0011001:frac_table = 16'b0011000111001101;
        7'b0011010:frac_table = 16'b0011001000000010;
        7'b0011011:frac_table = 16'b0011001000110111;
        7'b0011100:frac_table = 16'b0011001001101100;
        7'b0011101:frac_table = 16'b0011001010100000;
        7'b0011110:frac_table = 16'b0011001011010100;
        7'b0011111:frac_table = 16'b0011001100000111;
        7'b0100000:frac_table = 16'b0011001100111010;
        7'b0100001:frac_table = 16'b0011001101101101;
        7'b0100010:frac_table = 16'b0011001110100000;
        7'b0100011:frac_table = 16'b0011001111010010;
        7'b0100100:frac_table = 16'b0011010000000010;
        7'b0100101:frac_table = 16'b0011010000011011;
        7'b0100110:frac_table = 16'b0011010000110100;
        7'b0100111:frac_table = 16'b0011010001001100;
        7'b0101000:frac_table = 16'b0011010001100100;
        7'b0101001:frac_table = 16'b0011010001111101;
        7'b0101010:frac_table = 16'b0011010010010101;
        7'b0101011:frac_table = 16'b0011010010101101;
        7'b0101100:frac_table = 16'b0011010011000101;
        7'b0101101:frac_table = 16'b0011010011011100;
        7'b0101110:frac_table = 16'b0011010011110100;
        7'b0101111:frac_table = 16'b0011010100001011;
        7'b0110000:frac_table = 16'b0011010100100011;
        7'b0110001:frac_table = 16'b0011010100111010;
        7'b0110010:frac_table = 16'b0011010101010001;
        7'b0110011:frac_table = 16'b0011010101101000;
        7'b0110100:frac_table = 16'b0011010101111110;
        7'b0110101:frac_table = 16'b0011010110010101;
        7'b0110110:frac_table = 16'b0011010110101100;
        7'b0110111:frac_table = 16'b0011010111000010;
        7'b0111000:frac_table = 16'b0011010111011000;
        7'b0111001:frac_table = 16'b0011010111101110;
        7'b0111010:frac_table = 16'b0011011000000100;
        7'b0111011:frac_table = 16'b0011011000011010;
        7'b0111100:frac_table = 16'b0011011000110000;
        7'b0111101:frac_table = 16'b0011011001000110;
        7'b0111110:frac_table = 16'b0011011001011011;
        7'b0111111:frac_table = 16'b0011011001110001;
        7'b1000000:frac_table = 16'b0011011010000110;
        7'b1000001:frac_table = 16'b0011011010011011;
        7'b1000010:frac_table = 16'b0011011010110000;
        7'b1000011:frac_table = 16'b0011011011000101;
        7'b1000100:frac_table = 16'b0011011011011010;
        7'b1000101:frac_table = 16'b0011011011101111;
        7'b1000110:frac_table = 16'b0011011100000100;
        7'b1000111:frac_table = 16'b0011011100011000;
        7'b1001000:frac_table = 16'b0011011100101101;
        7'b1001001:frac_table = 16'b0011011101000001;
        7'b1001010:frac_table = 16'b0011011101010110;
        7'b1001011:frac_table = 16'b0011011101101010;
        7'b1001100:frac_table = 16'b0011011101111110;
        7'b1001101:frac_table = 16'b0011011110010010;
        7'b1001110:frac_table = 16'b0011011110100110;
        7'b1001111:frac_table = 16'b0011011110111010;
        7'b1010000:frac_table = 16'b0011011111001101;
        7'b1010001:frac_table = 16'b0011011111100001;
        7'b1010010:frac_table = 16'b0011011111110100;
        7'b1010011:frac_table = 16'b0011100000000100;
        7'b1010100:frac_table = 16'b0011100000001110;
        7'b1010101:frac_table = 16'b0011100000010111;
        7'b1010110:frac_table = 16'b0011100000100001;
        7'b1010111:frac_table = 16'b0011100000101010;
        7'b1011000:frac_table = 16'b0011100000110100;
        7'b1011001:frac_table = 16'b0011100000111101;
        7'b1011010:frac_table = 16'b0011100001000111;
        7'b1011011:frac_table = 16'b0011100001010000;
        7'b1011100:frac_table = 16'b0011100001011001;
        7'b1011101:frac_table = 16'b0011100001100011;
        7'b1011110:frac_table = 16'b0011100001101100;
        7'b1011111:frac_table = 16'b0011100001110101;
        7'b1100000:frac_table = 16'b0011100001111110;
        7'b1100001:frac_table = 16'b0011100010000111;
        7'b1100010:frac_table = 16'b0011100010010000;
        7'b1100011:frac_table = 16'b0011100010011001;
        7'b1100100:frac_table = 16'b0011100010100010;
        7'b1100101:frac_table = 16'b0011100010101011;
        7'b1100110:frac_table = 16'b0011100010110100;
        7'b1100111:frac_table = 16'b0011100010111101;
        7'b1101000:frac_table = 16'b0011100011000110;
        7'b1101001:frac_table = 16'b0011100011001111;
        7'b1101010:frac_table = 16'b0011100011010111;
        7'b1101011:frac_table = 16'b0011100011100000;
        7'b1101100:frac_table = 16'b0011100011101001;
        7'b1101101:frac_table = 16'b0011100011110001;
        7'b1101110:frac_table = 16'b0011100011111010;
        7'b1101111:frac_table = 16'b0011100100000011;
        7'b1110000:frac_table = 16'b0011100100001011;
        7'b1110001:frac_table = 16'b0011100100010100;
        7'b1110010:frac_table = 16'b0011100100011100;
        7'b1110011:frac_table = 16'b0011100100100101;
        7'b1110100:frac_table = 16'b0011100100101101;
        7'b1110101:frac_table = 16'b0011100100110101;
        7'b1110110:frac_table = 16'b0011100100111110;
        7'b1110111:frac_table = 16'b0011100101000110;
        7'b1111000:frac_table = 16'b0011100101001110;
        7'b1111001:frac_table = 16'b0011100101010110;
        7'b1111010:frac_table = 16'b0011100101011111;
        7'b1111011:frac_table = 16'b0011100101100111;
        7'b1111100:frac_table = 16'b0011100101101111;
        7'b1111101:frac_table = 16'b0011100101110111;
        7'b1111110:frac_table = 16'b0011100101111111;
        7'b1111111:frac_table = 16'b0011100110000111;
        default:frac_table = 16'b0000000000000000;
    endcase
end

always@(*)
begin
    case(exponent)
        5'b00001:exp_table = 16'b1100100011011010;
        5'b00010:exp_table = 16'b1100100010000010;
        5'b00011:exp_table = 16'b1100100000101001;
        5'b00100:exp_table = 16'b1100011110100000;
        5'b00101:exp_table = 16'b1100011011101111;
        5'b00110:exp_table = 16'b1100011000111110;
        5'b00111:exp_table = 16'b1100010110001100;
        5'b01000:exp_table = 16'b1100010011011010;
        5'b01001:exp_table = 16'b1100010000101001;
        5'b01010:exp_table = 16'b1100001011101111;
        5'b01011:exp_table = 16'b1100000110001100;
        5'b01100:exp_table = 16'b1100000000101001;
        5'b01101:exp_table = 16'b1011110110001100;
        5'b01110:exp_table = 16'b1011100110001100;
        5'b01111:exp_table = 16'b0000000000000000;
        5'b10000:exp_table = 16'b0011100110001100;
        5'b10001:exp_table = 16'b0011110110001100;
        5'b10010:exp_table = 16'b0100000000101001;
        5'b10011:exp_table = 16'b0100000110001100;
        5'b10100:exp_table = 16'b0100001011101111;
        5'b10101:exp_table = 16'b0100010000101001;
        5'b10110:exp_table = 16'b0100010011011010;
        5'b10111:exp_table = 16'b0100010110001100;
        5'b11000:exp_table = 16'b0100011000111110;
        5'b11001:exp_table = 16'b0100011011101111;
        5'b11010:exp_table = 16'b0100011110100000;
        5'b11011:exp_table = 16'b0100100000101001;
        5'b11100:exp_table = 16'b0100100010000010;
        5'b11101:exp_table = 16'b0100100011011010;
        5'b11110:exp_table = 16'b0100100100110011;
        default:exp_table = 16'b0000000000000000;
    endcase
end

endmodule