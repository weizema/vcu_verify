`timescale 1ps/1ps

module int8tofp16(data_int8,result_fp16);

input wire signed [7:0] data_int8;
output wire [15:0]result_fp16;

wire signal_result_fp16;
wire [4:0]exp_result_fp16;
reg [9:0]mantissa_result_fp16;

wire signal_data_int8;
wire [6:0]complement_data_int8;

assign signal_data_int8 = data_int8[7];
assign complement_data_int8 = data_int8[6:0];

reg [7:0]true_form_data_int8;

always @(*)
begin
    if(signal_data_int8 == 1'b0)
    begin
        true_form_data_int8 = {1'b0,complement_data_int8};
    end
    else
    begin
        true_form_data_int8 = 128-complement_data_int8;
    end
end

reg signed [4:0]exp_result_true;

always @(*)
begin
    casex(true_form_data_int8)
        8'b1xxx_xxxx:
        begin
            exp_result_true = 7;
            mantissa_result_fp16 = {true_form_data_int8[6:0],3'b000};
        end   
        8'b01xx_xxxx:
        begin
            exp_result_true = 6;
            mantissa_result_fp16 = {true_form_data_int8[5:0],4'b0000};     
        end
        8'b001x_xxxx:
        begin
            exp_result_true = 5;
            mantissa_result_fp16 = {true_form_data_int8[4:0],5'b00000};     
        end
        8'b0001_xxxx:
        begin
            exp_result_true = 4;
            mantissa_result_fp16 = {true_form_data_int8[3:0],6'b000000}; 
        end
        8'b0000_1xxx:
        begin
            exp_result_true = 3;
            mantissa_result_fp16 = {true_form_data_int8[2:0],7'b0000000}; 
        end
        8'b0000_01xx:
        begin
            exp_result_true = 2;
            mantissa_result_fp16 = {true_form_data_int8[1:0],8'b00000000}; 
        end
        8'b0000_001x:
        begin
            exp_result_true = 1;
            mantissa_result_fp16 = {true_form_data_int8[0],9'b000000000}; 
        end
        8'b0000_0001:
        begin
            exp_result_true = 0;
            mantissa_result_fp16 = 10'b000000000; 
        end
        8'b0000_0000:
        begin
            exp_result_true = -15;
            mantissa_result_fp16 = 10'b000000000; 
        end
        default:
        begin
            exp_result_true = 0;
            mantissa_result_fp16 = 10'b000000000; 
        end
    endcase
end

assign signal_result_fp16 = signal_data_int8;
assign exp_result_fp16 = exp_result_true+15;
assign result_fp16 = {signal_result_fp16,exp_result_fp16,mantissa_result_fp16};

endmodule