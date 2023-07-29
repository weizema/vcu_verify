module two_port_ram_1024x512
(
    w_clk, w_addr, w_en, w_data,
    r_clk, r_addr, r_en, r_data
);

input w_clk, r_clk;
input w_en, r_en;
input [8:0] w_addr, r_addr;
input [1024-1:0] w_data;
output wire [1024-1:0] r_data;

reg [1024-1:0] mem [0:512-1];

reg [1024-1:0] rdata_reg;
assign r_data = rdata_reg;

always @(posedge w_clk) begin
if (w_en) begin
mem[w_addr] <= w_data;
end
end

always @(posedge r_clk) begin
if (r_en) begin
rdata_reg <= mem[r_addr];
end

end


endmodule

