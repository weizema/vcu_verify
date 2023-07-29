`timescale 1ps/1ps

module invertion(data,data_valid,rst,clk,result,complete);

input wire [15:0]data;
input wire data_valid;
input wire rst;
input wire clk;

output wire [15:0]result;
output reg complete;

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

assign result[15]=~data_temp[15];
assign result[14:0] = data_temp[14:0];

endmodule