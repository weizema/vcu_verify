`timescale 1ps/1ps

module exp_float16(data,data_valid,clk,rst,result,complete);

input wire [15:0]data;
input wire data_valid;
input wire clk;
input wire rst;

output reg [15:0]result;
output reg complete;

wire signal;
wire [4:0]exponent_temp;
wire [9:0]mantissa_temp;

reg [4:0]exponent;
reg [9:0]mantissa;

wire signed [5:0]shift_number;
reg signed [5:0]shift_number_abs;
reg [9:0]mantissa_shift; 

reg [1:0]offset_index;
wire [7:0]exp_index;
reg [15:0]exp_table;

reg [7:0]frac_index;
reg [15:0]frac_table;

wire [15:0]result_mult;

wire [2:0]comp_index;
reg  [3:0]comp_val;

reg [15:0]data_temp;

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
    if(signal == 1'b0 && {exponent_temp,mantissa_temp} > 15'b100100110001011)
    begin
        exponent = 5'b10010;
        mantissa = 10'b0110001100;
    end
    else if(signal == 1'b1 && {exponent_temp,mantissa_temp} > 15'b100100011011010)
    begin
        exponent = 5'b10010;
        mantissa = 10'b0011011011;
    end
    else if(exponent_temp == 5'b00000)
    begin
        exponent = 5'b00001;
        mantissa = 10'b0000001000;
    end
    else 
    begin
        exponent = exponent_temp;
        mantissa = mantissa_temp;
    end
end

assign shift_number = exponent-15;

always@(*)
begin
    if(shift_number == 6'd3)
        offset_index = mantissa[8:7];
    else if(shift_number == 6'd2)
        offset_index = mantissa[9:8];
    else if(shift_number == 6'd1)
        offset_index = {1'b0,mantissa[9]};
    else
        offset_index = 2'b00;       
end

assign exp_index = {signal,offset_index,exponent};

always@(*)
begin
    if(shift_number>=0)
    begin
        mantissa_shift = mantissa << shift_number;
        frac_index = {signal,mantissa_shift[9:3]};
    end
    else
    begin
        shift_number_abs = -shift_number;
        mantissa_shift = mantissa >> shift_number_abs;
        frac_index = {signal,mantissa_shift[9:3]};
    end
end

mult_float16_simple mult_float16(
    .data1(exp_table),
    .data2(frac_table),
    .result(result_mult)
);

assign comp_index = mantissa_shift[2:0];

always @(*)
begin
    case(comp_index)
        3'b000:comp_val = 4'b0000;
        3'b001:comp_val = 4'b0001;
        3'b010:comp_val = 4'b0010;
        3'b011:comp_val = 4'b0100;
        3'b100:comp_val = 4'b0101;
        3'b101:comp_val = 4'b0110;
        3'b110:comp_val = 4'b1000;
        3'b111:comp_val = 4'b1010;
        default:comp_val = 4'b0000;
    endcase
end

always @(*)
begin
    if(exponent==5'b00000&&mantissa==10'b0000000000) 
        result = 16'b0_01111_0000000000;
    else if(signal==1'b0&&exponent>5'b10010)
        result = 16'b0_11110_1111111111;
    else if(signal==1'b0&&exponent==5'b10010&&mantissa>10'b0110001011)
        result = 16'b0_11110_1111111111;
    else if(signal==1'b1&&exponent>5'b10010)
        result = 16'b0_00001_0000000000;
    else if(signal==1'b1&&exponent==5'b10010&&mantissa>10'b0011011010)
        result = 16'b0_00001_0000000000;
    else
    begin   
        if(signal)
            result = result_mult - comp_val;
        else
            result = result_mult + comp_val;
    end
end

always@(*)
begin
    case(exp_index)
        8'b00000001:exp_table = 16'b0011110000000000;
        8'b00000010:exp_table = 16'b0011110000000000;
        8'b00000011:exp_table = 16'b0011110000000000;
        8'b00000100:exp_table = 16'b0011110000000001;
        8'b00000101:exp_table = 16'b0011110000000001;
        8'b00000110:exp_table = 16'b0011110000000010;
        8'b00000111:exp_table = 16'b0011110000000100;
        8'b00001000:exp_table = 16'b0011110000001000;
        8'b00001001:exp_table = 16'b0011110000010000;
        8'b00001010:exp_table = 16'b0011110000100001;
        8'b00001011:exp_table = 16'b0011110001000010;
        8'b00001100:exp_table = 16'b0011110010001000;
        8'b00001101:exp_table = 16'b0011110100100011;
        8'b00001110:exp_table = 16'b0011111010011000;
        8'b00001111:exp_table = 16'b0100000101110000;
        8'b00010000:exp_table = 16'b0100011101100100;
        8'b00110000:exp_table = 16'b0100110100000110;
        8'b00010001:exp_table = 16'b0101001011010011;
        8'b00110001:exp_table = 16'b0101100010100011;
        8'b01010001:exp_table = 16'b0101111001001110;
        8'b01110001:exp_table = 16'b0110010001001000;
        8'b00010010:exp_table = 16'b0110100111010010;
        8'b00110010:exp_table = 16'b0110111111101001;
        8'b01010010:exp_table = 16'b0111010101100001;
        8'b01110010:exp_table = 16'b0111101101001110;
        
        8'b10000001:exp_table = 16'b0011110000000000;
        8'b10000010:exp_table = 16'b0011110000000000;
        8'b10000011:exp_table = 16'b0011110000000000;
        8'b10000100:exp_table = 16'b0011101111111111;
        8'b10000101:exp_table = 16'b0011101111111110;
        8'b10000110:exp_table = 16'b0011101111111100;
        8'b10000111:exp_table = 16'b0011101111111000;
        8'b10001000:exp_table = 16'b0011101111110000;
        8'b10001001:exp_table = 16'b0011101111100000;
        8'b10001010:exp_table = 16'b0011101111000001;
        8'b10001011:exp_table = 16'b0011101110000100;
        8'b10001100:exp_table = 16'b0011101100001111;
        8'b10001101:exp_table = 16'b0011101000111011;
        8'b10001110:exp_table = 16'b0011100011011010;
        8'b10001111:exp_table = 16'b0011010111100011;
        8'b10010000:exp_table = 16'b0011000001010101;
        8'b10110000:exp_table = 16'b0010101001100000;
        8'b10010001:exp_table = 16'b0010010010110000;
        8'b10110001:exp_table = 16'b0001111011100110;
        8'b11010001:exp_table = 16'b0001100100010100;
        8'b11110001:exp_table = 16'b0001001101110111;
        8'b10010010:exp_table = 16'b0000110101111111;
        8'b10110010:exp_table = 16'b0000100000001011;
        default:exp_table = 16'b000000000000000;
    endcase
end

always@(*)
begin
    case(frac_index)
        8'b00000000:frac_table = 16'b0011110000000000;
        8'b00000001:frac_table = 16'b0011110000001000;
        8'b00000010:frac_table = 16'b0011110000010000;
        8'b00000011:frac_table = 16'b0011110000011000;
        8'b00000100:frac_table = 16'b0011110000100001;
        8'b00000101:frac_table = 16'b0011110000101001;
        8'b00000110:frac_table = 16'b0011110000110001;
        8'b00000111:frac_table = 16'b0011110000111010;
        8'b00001000:frac_table = 16'b0011110001000010;
        8'b00001001:frac_table = 16'b0011110001001011;
        8'b00001010:frac_table = 16'b0011110001010011;
        8'b00001011:frac_table = 16'b0011110001011100;
        8'b00001100:frac_table = 16'b0011110001100101;
        8'b00001101:frac_table = 16'b0011110001101101;
        8'b00001110:frac_table = 16'b0011110001110110;
        8'b00001111:frac_table = 16'b0011110001111111;
        8'b00010000:frac_table = 16'b0011110010001000;
        8'b00010001:frac_table = 16'b0011110010010001;
        8'b00010010:frac_table = 16'b0011110010011011;
        8'b00010011:frac_table = 16'b0011110010100100;
        8'b00010100:frac_table = 16'b0011110010101101;
        8'b00010101:frac_table = 16'b0011110010110111;
        8'b00010110:frac_table = 16'b0011110011000000;
        8'b00010111:frac_table = 16'b0011110011001010;
        8'b00011000:frac_table = 16'b0011110011010011;
        8'b00011001:frac_table = 16'b0011110011011101;
        8'b00011010:frac_table = 16'b0011110011100111;
        8'b00011011:frac_table = 16'b0011110011110000;
        8'b00011100:frac_table = 16'b0011110011111010;
        8'b00011101:frac_table = 16'b0011110100000100;
        8'b00011110:frac_table = 16'b0011110100001110;
        8'b00011111:frac_table = 16'b0011110100011001;
        8'b00100000:frac_table = 16'b0011110100100011;
        8'b00100001:frac_table = 16'b0011110100101101;
        8'b00100010:frac_table = 16'b0011110100111000;
        8'b00100011:frac_table = 16'b0011110101000010;
        8'b00100100:frac_table = 16'b0011110101001101;
        8'b00100101:frac_table = 16'b0011110101010111;
        8'b00100110:frac_table = 16'b0011110101100010;
        8'b00100111:frac_table = 16'b0011110101101101;
        8'b00101000:frac_table = 16'b0011110101111000;
        8'b00101001:frac_table = 16'b0011110110000011;
        8'b00101010:frac_table = 16'b0011110110001110;
        8'b00101011:frac_table = 16'b0011110110011001;
        8'b00101100:frac_table = 16'b0011110110100100;
        8'b00101101:frac_table = 16'b0011110110101111;
        8'b00101110:frac_table = 16'b0011110110111011;
        8'b00101111:frac_table = 16'b0011110111000110;
        8'b00110000:frac_table = 16'b0011110111010010;
        8'b00110001:frac_table = 16'b0011110111011110;
        8'b00110010:frac_table = 16'b0011110111101001;
        8'b00110011:frac_table = 16'b0011110111110101;
        8'b00110100:frac_table = 16'b0011111000000001;
        8'b00110101:frac_table = 16'b0011111000001101;
        8'b00110110:frac_table = 16'b0011111000011001;
        8'b00110111:frac_table = 16'b0011111000100110;
        8'b00111000:frac_table = 16'b0011111000110010;
        8'b00111001:frac_table = 16'b0011111000111110;
        8'b00111010:frac_table = 16'b0011111001001011;
        8'b00111011:frac_table = 16'b0011111001011000;
        8'b00111100:frac_table = 16'b0011111001100100;
        8'b00111101:frac_table = 16'b0011111001110001;
        8'b00111110:frac_table = 16'b0011111001111110;
        8'b00111111:frac_table = 16'b0011111010001011;
        8'b01000000:frac_table = 16'b0011111010011000;
        8'b01000001:frac_table = 16'b0011111010100110;
        8'b01000010:frac_table = 16'b0011111010110011;
        8'b01000011:frac_table = 16'b0011111011000000;
        8'b01000100:frac_table = 16'b0011111011001110;
        8'b01000101:frac_table = 16'b0011111011011100;
        8'b01000110:frac_table = 16'b0011111011101001;
        8'b01000111:frac_table = 16'b0011111011110111;
        8'b01001000:frac_table = 16'b0011111100000101;
        8'b01001001:frac_table = 16'b0011111100010011;
        8'b01001010:frac_table = 16'b0011111100100001;
        8'b01001011:frac_table = 16'b0011111100110000;
        8'b01001100:frac_table = 16'b0011111100111110;
        8'b01001101:frac_table = 16'b0011111101001101;
        8'b01001110:frac_table = 16'b0011111101011011;
        8'b01001111:frac_table = 16'b0011111101101010;
        8'b01010000:frac_table = 16'b0011111101111001;
        8'b01010001:frac_table = 16'b0011111110001000;
        8'b01010010:frac_table = 16'b0011111110010111;
        8'b01010011:frac_table = 16'b0011111110100110;
        8'b01010100:frac_table = 16'b0011111110110110;
        8'b01010101:frac_table = 16'b0011111111000101;
        8'b01010110:frac_table = 16'b0011111111010101;
        8'b01010111:frac_table = 16'b0011111111100101;
        8'b01011000:frac_table = 16'b0011111111110100;
        8'b01011001:frac_table = 16'b0100000000000010;
        8'b01011010:frac_table = 16'b0100000000001010;
        8'b01011011:frac_table = 16'b0100000000010010;
        8'b01011100:frac_table = 16'b0100000000011011;
        8'b01011101:frac_table = 16'b0100000000100011;
        8'b01011110:frac_table = 16'b0100000000101011;
        8'b01011111:frac_table = 16'b0100000000110011;
        8'b01100000:frac_table = 16'b0100000000111100;
        8'b01100001:frac_table = 16'b0100000001000100;
        8'b01100010:frac_table = 16'b0100000001001101;
        8'b01100011:frac_table = 16'b0100000001010110;
        8'b01100100:frac_table = 16'b0100000001011110;
        8'b01100101:frac_table = 16'b0100000001100111;
        8'b01100110:frac_table = 16'b0100000001110000;
        8'b01100111:frac_table = 16'b0100000001111001;
        8'b01101000:frac_table = 16'b0100000010000010;
        8'b01101001:frac_table = 16'b0100000010001011;
        8'b01101010:frac_table = 16'b0100000010010100;
        8'b01101011:frac_table = 16'b0100000010011101;
        8'b01101100:frac_table = 16'b0100000010100110;
        8'b01101101:frac_table = 16'b0100000010110000;
        8'b01101110:frac_table = 16'b0100000010111001;
        8'b01101111:frac_table = 16'b0100000011000011;
        8'b01110000:frac_table = 16'b0100000011001100;
        8'b01110001:frac_table = 16'b0100000011010110;
        8'b01110010:frac_table = 16'b0100000011100000;
        8'b01110011:frac_table = 16'b0100000011101001;
        8'b01110100:frac_table = 16'b0100000011110011;
        8'b01110101:frac_table = 16'b0100000011111101;
        8'b01110110:frac_table = 16'b0100000100000111;
        8'b01110111:frac_table = 16'b0100000100010001;
        8'b01111000:frac_table = 16'b0100000100011011;
        8'b01111001:frac_table = 16'b0100000100100110;
        8'b01111010:frac_table = 16'b0100000100110000;
        8'b01111011:frac_table = 16'b0100000100111010;
        8'b01111100:frac_table = 16'b0100000101000101;
        8'b01111101:frac_table = 16'b0100000101010000;
        8'b01111110:frac_table = 16'b0100000101011010;
        8'b01111111:frac_table = 16'b0100000101100101;
        8'b10000000:frac_table = 16'b0011110000000000;
        8'b10000001:frac_table = 16'b0011101111110000;
        8'b10000010:frac_table = 16'b0011101111100000;
        8'b10000011:frac_table = 16'b0011101111010001;
        8'b10000100:frac_table = 16'b0011101111000001;
        8'b10000101:frac_table = 16'b0011101110110010;
        8'b10000110:frac_table = 16'b0011101110100010;
        8'b10000111:frac_table = 16'b0011101110010011;
        8'b10001000:frac_table = 16'b0011101110000100;
        8'b10001001:frac_table = 16'b0011101101110101;
        8'b10001010:frac_table = 16'b0011101101100110;
        8'b10001011:frac_table = 16'b0011101101010111;
        8'b10001100:frac_table = 16'b0011101101001001;
        8'b10001101:frac_table = 16'b0011101100111010;
        8'b10001110:frac_table = 16'b0011101100101100;
        8'b10001111:frac_table = 16'b0011101100011110;
        8'b10010000:frac_table = 16'b0011101100001111;
        8'b10010001:frac_table = 16'b0011101100000001;
        8'b10010010:frac_table = 16'b0011101011110011;
        8'b10010011:frac_table = 16'b0011101011100101;
        8'b10010100:frac_table = 16'b0011101011011000;
        8'b10010101:frac_table = 16'b0011101011001010;
        8'b10010110:frac_table = 16'b0011101010111101;
        8'b10010111:frac_table = 16'b0011101010101111;
        8'b10011000:frac_table = 16'b0011101010100010;
        8'b10011001:frac_table = 16'b0011101010010101;
        8'b10011010:frac_table = 16'b0011101010001000;
        8'b10011011:frac_table = 16'b0011101001111011;
        8'b10011100:frac_table = 16'b0011101001101110;
        8'b10011101:frac_table = 16'b0011101001100001;
        8'b10011110:frac_table = 16'b0011101001010100;
        8'b10011111:frac_table = 16'b0011101001000111;
        8'b10100000:frac_table = 16'b0011101000111011;
        8'b10100001:frac_table = 16'b0011101000101111;
        8'b10100010:frac_table = 16'b0011101000100010;
        8'b10100011:frac_table = 16'b0011101000010110;
        8'b10100100:frac_table = 16'b0011101000001010;
        8'b10100101:frac_table = 16'b0011100111111110;
        8'b10100110:frac_table = 16'b0011100111110010;
        8'b10100111:frac_table = 16'b0011100111100110;
        8'b10101000:frac_table = 16'b0011100111011010;
        8'b10101001:frac_table = 16'b0011100111001111;
        8'b10101010:frac_table = 16'b0011100111000011;
        8'b10101011:frac_table = 16'b0011100110111000;
        8'b10101100:frac_table = 16'b0011100110101100;
        8'b10101101:frac_table = 16'b0011100110100001;
        8'b10101110:frac_table = 16'b0011100110010110;
        8'b10101111:frac_table = 16'b0011100110001011;
        8'b10110000:frac_table = 16'b0011100110000000;
        8'b10110001:frac_table = 16'b0011100101110101;
        8'b10110010:frac_table = 16'b0011100101101010;
        8'b10110011:frac_table = 16'b0011100101011111;
        8'b10110100:frac_table = 16'b0011100101010100;
        8'b10110101:frac_table = 16'b0011100101001010;
        8'b10110110:frac_table = 16'b0011100100111111;
        8'b10110111:frac_table = 16'b0011100100110101;
        8'b10111000:frac_table = 16'b0011100100101010;
        8'b10111001:frac_table = 16'b0011100100100000;
        8'b10111010:frac_table = 16'b0011100100010110;
        8'b10111011:frac_table = 16'b0011100100001100;
        8'b10111100:frac_table = 16'b0011100100000010;
        8'b10111101:frac_table = 16'b0011100011111000;
        8'b10111110:frac_table = 16'b0011100011101110;
        8'b10111111:frac_table = 16'b0011100011100100;
        8'b11000000:frac_table = 16'b0011100011011010;
        8'b11000001:frac_table = 16'b0011100011010001;
        8'b11000010:frac_table = 16'b0011100011000111;
        8'b11000011:frac_table = 16'b0011100010111101;
        8'b11000100:frac_table = 16'b0011100010110100;
        8'b11000101:frac_table = 16'b0011100010101011;
        8'b11000110:frac_table = 16'b0011100010100001;
        8'b11000111:frac_table = 16'b0011100010011000;
        8'b11001000:frac_table = 16'b0011100010001111;
        8'b11001001:frac_table = 16'b0011100010000110;
        8'b11001010:frac_table = 16'b0011100001111101;
        8'b11001011:frac_table = 16'b0011100001110100;
        8'b11001100:frac_table = 16'b0011100001101011;
        8'b11001101:frac_table = 16'b0011100001100010;
        8'b11001110:frac_table = 16'b0011100001011001;
        8'b11001111:frac_table = 16'b0011100001010001;
        8'b11010000:frac_table = 16'b0011100001001000;
        8'b11010001:frac_table = 16'b0011100001000000;
        8'b11010010:frac_table = 16'b0011100000110111;
        8'b11010011:frac_table = 16'b0011100000101111;
        8'b11010100:frac_table = 16'b0011100000100110;
        8'b11010101:frac_table = 16'b0011100000011110;
        8'b11010110:frac_table = 16'b0011100000010110;
        8'b11010111:frac_table = 16'b0011100000001110;
        8'b11011000:frac_table = 16'b0011100000000110;
        8'b11011001:frac_table = 16'b0011011111111100;
        8'b11011010:frac_table = 16'b0011011111101100;
        8'b11011011:frac_table = 16'b0011011111011100;
        8'b11011100:frac_table = 16'b0011011111001100;
        8'b11011101:frac_table = 16'b0011011110111101;
        8'b11011110:frac_table = 16'b0011011110101101;
        8'b11011111:frac_table = 16'b0011011110011110;
        8'b11100000:frac_table = 16'b0011011110001111;
        8'b11100001:frac_table = 16'b0011011110000000;
        8'b11100010:frac_table = 16'b0011011101110001;
        8'b11100011:frac_table = 16'b0011011101100010;
        8'b11100100:frac_table = 16'b0011011101010011;
        8'b11100101:frac_table = 16'b0011011101000101;
        8'b11100110:frac_table = 16'b0011011100110110;
        8'b11100111:frac_table = 16'b0011011100101000;
        8'b11101000:frac_table = 16'b0011011100011010;
        8'b11101001:frac_table = 16'b0011011100001011;
        8'b11101010:frac_table = 16'b0011011011111101;
        8'b11101011:frac_table = 16'b0011011011101111;
        8'b11101100:frac_table = 16'b0011011011100010;
        8'b11101101:frac_table = 16'b0011011011010100;
        8'b11101110:frac_table = 16'b0011011011000110;
        8'b11101111:frac_table = 16'b0011011010111001;
        8'b11110000:frac_table = 16'b0011011010101011;
        8'b11110001:frac_table = 16'b0011011010011110;
        8'b11110010:frac_table = 16'b0011011010010001;
        8'b11110011:frac_table = 16'b0011011010000100;
        8'b11110100:frac_table = 16'b0011011001110111;
        8'b11110101:frac_table = 16'b0011011001101010;
        8'b11110110:frac_table = 16'b0011011001011101;
        8'b11110111:frac_table = 16'b0011011001010001;
        8'b11111000:frac_table = 16'b0011011001000100;
        8'b11111001:frac_table = 16'b0011011000111000;
        8'b11111010:frac_table = 16'b0011011000101011;
        8'b11111011:frac_table = 16'b0011011000011111;
        8'b11111100:frac_table = 16'b0011011000010011;
        8'b11111101:frac_table = 16'b0011011000000111;
        8'b11111110:frac_table = 16'b0011010111111011;
        8'b11111111:frac_table = 16'b0011010111101111;
        default:frac_table = 16'b0000000000000000;
    endcase
end
endmodule