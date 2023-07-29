`timescale 1ps/1ps

module QDS(p,d,q);

input wire [5:0]p;
input wire [2:0]d;
output reg signed [2:0]q; 

always @(p,d)
begin
    casex(p)
        6'b01010x:q = 2;
        6'b0100xx:q = 2;
        6'b0011xx:q = 2;
        6'b00101x:begin
            casex(d)
                3'b0xx:q = 2;
                3'b10x:q = 2;
                3'b110:q = 2;
                3'b111:q = 1;
            endcase
        end
        6'b00100x:begin
            casex(d)
                3'b0xx:q = 2;
                3'b1xx:q = 1;
            endcase    
        end
        6'b000111:begin
            casex(d)
                3'b00x:q = 2;
                3'b01x:q = 1;
                3'b1xx:q = 1;
            endcase
        end
        6'b000110:begin
            casex(d)
                3'b000:q = 2;
                3'b001:q = 1;
                3'b01x:q = 1;
                3'b1xx:q = 1;
            endcase
        end
        6'b00010x:q = 1;
        6'b000011:q = 1;
        6'b000010:begin
            casex(d)
                3'b00x:q = 1;
                3'b010:q = 1;
                3'b011:q = 0;
                3'b1xx:q = 0;
            endcase
        end
        6'b00000x:q = 0;
        6'b11111x:q = 0;
        6'b111101:begin
            casex(d)
                3'b00x:q = -1;
                3'b010:q = -1;
                3'b011:q = 0;
                3'b1xx:q = 0;
            endcase
        end
        6'b111100:q = -1;
        6'b11101x:q = -1;
        6'b111001:begin
            casex(d)
                3'b000:q = -2;
                3'b001:q = -1;
                3'b01x:q = -1;
                3'b1xx:q = -1;
            endcase
        end
        6'b111000:begin
            casex(d)
                3'b00x:q = -2;
                3'b01x:q = -1;
                3'b1xx:q = -1;
            endcase
        end
        6'b11011x:begin
            casex(d)
                3'b0xx:q = -2;
                3'b1xx:q = -1;
            endcase
        end
        6'b11010x:begin
            casex(d)
                3'b0xx:q = -2;
                3'b10x:q = -2;
                3'b110:q = -2;
                3'b111:q = -1;
            endcase
        end
        6'b1100xx:q = -2;
        6'b1011xx:q = -2;
        6'b101011:q = -2;
        default:q = 3'b011;
    endcase
end

endmodule