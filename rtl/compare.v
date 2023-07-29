`timescale 1ps/1ps

module compare(data,iteration_data,constant_data,constant,data_valid,rst,clk,result,complete);

input wire [15:0]data;
input wire [15:0]constant;
input wire [15:0]iteration_data;
input wire [15:0]constant_data;

input wire data_valid;
input wire rst;
input wire clk;

output wire [15:0]result;
output reg complete;

reg [15:0]data_temp;
reg [15:0]result_temp;
reg select_signal;

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

always@(*)
begin
    if(data_temp[15] != constant[15])
    begin
        select_signal = ~data_temp[15];
    end
    else
    begin
        if(data_temp[15] == 1'b0)
        begin
            if(data_temp[14:0]>= constant[14:0])
            begin
                select_signal = 1'b1;
            end
            else
            begin
                select_signal = 1'b0;
            end
        end
        else
        begin
            if(data_temp[14:0]>= constant[14:0])
            begin
                select_signal = 1'b0;
            end
            else
            begin
                select_signal = 1'b1;
            end
        end
    end
end


always @(*)
begin
    if(select_signal == 1'b1)
    begin
        result_temp = iteration_data;
    end
    else
    begin
        result_temp = constant_data;
    end
end

assign result = result_temp;

endmodule