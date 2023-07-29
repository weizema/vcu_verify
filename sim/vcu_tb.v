`timescale 1ps/1ps

module vcu_tb();

parameter INSN_WIDTH = 128;

parameter ACC_DATA_WIDTH = 2048;
parameter PARA_DATA_WIDTH = 1024;
parameter OFMAP_DATA_WIDTH = 512;
parameter INP_DATA_WIDTH = 512;
parameter OPCODE_DATA_WIDTH = 16;
parameter RESADD_DATA_RAM = 1024;

parameter ACC_ADDRESS_WIDTH = 12;
parameter PARA_ADDRESS_WIDTH = 5;
parameter OFMAP_ADDRESS_WIDTH = 12;    
parameter INP_ADDRESS_WIDTH = 10;
parameter OPCODE_ADDRESS_WIDTH = 10;
parameter RESADD_ADDRESS_WIDTH = 9;        
     
parameter CLK_PERIOD = 10;

reg clk;
reg rst;

reg [INSN_WIDTH-1:0]insn;
// reg insn_valid;
reg work_en;

// wire insn_back;
wire vcu_done;

//acc_ram
wire [ACC_ADDRESS_WIDTH-1:0]w_addr_acc;
wire [ACC_ADDRESS_WIDTH-1:0]r_addr_acc;
wire [ACC_DATA_WIDTH-1:0]w_data_acc;
wire [ACC_DATA_WIDTH-1:0]r_data_acc;
wire w_en_acc;
wire r_en_acc;

//para_ram
wire [PARA_ADDRESS_WIDTH-1:0]w_addr_para;
wire [PARA_ADDRESS_WIDTH-1:0]r_addr_para;
wire w_en_para;
wire r_en_para;
wire [PARA_DATA_WIDTH-1:0]w_data_para;
wire [PARA_DATA_WIDTH-1:0]r_data_para;

//ofmap_ram
wire [OFMAP_ADDRESS_WIDTH-1:0]w_addr_ofmap;
wire [OFMAP_ADDRESS_WIDTH-1:0]r_addr_ofmap;
wire [OFMAP_DATA_WIDTH-1:0]w_data_ofmap;
wire [OFMAP_DATA_WIDTH-1:0]r_data_ofmap;
wire w_en_ofmap;
wire r_en_ofmap;

//inp_ram
wire [INP_ADDRESS_WIDTH-1:0]w_addr_inp;
wire [INP_ADDRESS_WIDTH-1:0]r_addr_inp;
wire [INP_DATA_WIDTH-1:0]w_data_inp;
wire [INP_DATA_WIDTH-1:0]r_data_inp;
wire w_en_inp;
wire r_en_inp;

//opcode_ram
wire [OPCODE_ADDRESS_WIDTH-1:0]w_addr_opcode;
wire [OPCODE_DATA_WIDTH-1:0]w_data_opcode;
wire w_en_opcode;

//res_add_ram
wire [RESADD_DATA_RAM-1:0] w_data_resadd;
wire [RESADD_DATA_RAM-1:0] r_data_resadd;
wire [RESADD_ADDRESS_WIDTH-1:0]w_addr_resadd;
wire [RESADD_ADDRESS_WIDTH-1:0]r_addr_resadd;
wire w_en_resadd;
wire r_en_resadd;


wire acc_data_in_type;
wire acc_data_out_type;
wire ofmap_data_out_type;
wire inp_data_out_type;
wire resadd_data_in_type;

always #CLK_PERIOD clk = ~clk;

integer result_file;

initial
begin
    //dequan_verify
    // result_file = $fopen("../dequan_verify/result_fp16.txt","w");
    // $readmemh("../dequan_verify/psum.dat",two_port_ram_2048x4096_acc.mem);
    // $readmemh("../dequan_verify/psum_shift.dat",two_port_ram_1024x32_para.mem);

    //bias_verify
    // result_file = $fopen("../bias_verify/result_fp16.txt","w");
    // $readmemh("../bias_verify/psum.dat",two_port_ram_2048x4096_acc.mem);
    // $readmemh("../bias_verify/psum_shift.dat",two_port_ram_1024x32_para.mem);
    // $readmemb("../bias_verify/opcode_sigmoid.txt",vcu.two_port_ram_16x1024_opcode.mem);

    //resadd_verify
    result_file = $fopen("../resadd_verify/result_fp16.txt","w");
    $readmemb("../resadd_verify/conv_data.txt",two_port_ram_2048x4096_acc.mem);
    $readmemb("../resadd_verify/resadd_data.txt",two_port_ram_1024x512_resadd.mem);
    $readmemb("../resadd_verify/opcode.txt",vcu.two_port_ram_16x1024_opcode.mem);

    clk = 1;
    rst = 0;
    insn = 'd0;
    // insn_valid = 0;
    work_en <= 0;

    #20
    rst = 1;
    #20
    rst = 0;
    #20
    // insn_valid = 1'b1;
    #20
    work_en <= 1;
    #20
    work_en <= 0;
    #20
    //mish
    insn = 128'b00000000000000000000000000000000000000000000000000000000101000011001000011100011110000000000000000000000000000000000000000000100;
    //bias
    // insn[127:116] = 12'b0;
    // insn[115:104] = 12'b0;
    // insn[103] = 1'b1;
    // insn[102:101] = 2'b01;
    // insn[100:81] = 20'b0000000000_0000000001;
    // insn[80:69] = 12'b0000_0000_1010;
    // insn[68] = 1'b1;
    // insn[67] = 1'b1;
    // insn[66:62] = 5'b00000;
    // insn[61] = 1'b1;
    // insn[60:55] = 6'b000101;
    // insn[54:50] = 5'b00000;
    // insn[49] = 1'b1;
    
    //sigmoid
    // insn[127:116] = 12'b0;
    // insn[115:104] = 12'b0;
    // insn[103] = 1'b0;
    // insn[102:101] = 2'b01;
    // insn[100:81] = 20'b0000000000_0000000100;
    // insn[80:69] = 12'b0000_0000_0010;
    // insn[68] = 1'b1;
    // insn[67] = 1'b1;
    // insn[66:62] = 5'b00000;
    // insn[61] = 1'b0;
    // insn[60:55] = 6'b000000;
    // insn[54:50] = 5'b00000;
    // insn[49] = 1'b0;
end

vcu vcu(
    .insn(insn),
    .work_en(work_en),
    .vcu_done(vcu_done),
    .clk(clk),
    .rst(rst),
    //acc_ram
    .r_data_acc(r_data_acc),
    .r_addr_acc(r_addr_acc),
    .r_en_acc(r_en_acc),
    .w_data_acc(w_data_acc),
    .w_addr_acc(w_addr_acc),
    .w_en_acc(w_en_acc),
    //para_ram
    .r_data_para(r_data_para),
    .r_addr_para(r_addr_para),
    .r_en_para(r_en_para),
    //res_ram
    .w_data_ofmap(w_data_ofmap),
    .w_addr_ofmap(w_addr_ofmap),
    .w_en_ofmap(w_en_ofmap),
    //inp_ram
    .w_data_inp(w_data_inp),
    .w_addr_inp(w_addr_inp),
    .w_en_inp(w_en_inp),
    //opcode_ram
    .w_data_opcode(w_data_opcode),
    .w_addr_opcode(w_addr_opcode),
    .w_en_opcode(w_en_opcode),
    //res_add_ram
    .r_data_resadd(r_data_resadd),
    .r_addr_resadd(r_addr_resadd),
    .r_en_resadd(r_en_resadd),

    .acc_data_in_type(acc_data_in_type),
    .acc_data_out_type(acc_data_out_type),
    .ofmap_data_out_type(ofmap_data_out_type),
    .inp_data_out_type(inp_data_out_type),
    .resadd_data_in_type(resadd_data_in_type)
);

two_port_ram_2048x4096 two_port_ram_2048x4096_acc(
    .w_clk(clk),
    .w_addr(w_addr_acc),
    .w_en(w_en_acc),
    .w_data(w_data_acc),
    .r_clk(clk),
    .r_addr(r_addr_acc),
    .r_en(r_en_acc),
    .r_data(r_data_acc)
);

two_port_ram_1024x32 two_port_ram_1024x32_para(
    .w_clk(clk),
    .w_addr(w_addr_para),
    .w_en(w_en_para),
    .w_data(w_data_para),
    .r_clk(clk),
    .r_addr(r_addr_para),
    .r_en(r_en_para),
    .r_data(r_data_para)
);

two_port_ram_512x4096 two_port_ram_512x4096_ofmap(
    .w_clk(clk),
    .w_addr(w_addr_ofmap),
    .w_en(w_en_ofmap),
    .w_data(w_data_ofmap),
    .r_clk(clk),
    .r_addr(r_addr_ofmap),
    .r_en(r_en_ofmap),
    .r_data(r_data_ofmap)
);

two_port_ram_512x1024 two_port_ram_512x1024_inp(
    .w_clk(clk),
    .w_addr(w_addr_inp),
    .w_en(w_en_inp),
    .w_data(w_data_inp),
    .r_clk(clk),
    .r_addr(r_addr_inp),
    .r_en(r_en_inp),
    .r_data(r_data_inp)
);

two_port_ram_1024x512 two_port_ram_1024x512_resadd(
    .w_clk(clk),
    .w_addr(w_addr_resadd),
    .w_en(w_en_resadd),
    .w_data(w_data_resadd),
    .r_clk(clk),
    .r_addr(r_addr_resadd),
    .r_en(r_en_resadd),
    .r_data(r_data_resadd)
);

integer i;

// always @(*)
// begin
// if(vcu_done)
// begin
//     $fwrite(result_file,"%b\n",two_port_ram_2048x4096_acc.mem);
//     // for(i=0;i<800;i=i+1)
//     // begin
//     //     $fwrite(result_file,"%b\n",two_port_ram_2048x4096_acc.mem[i]);
//     // end
// end


initial begin
#150000
for(i=0;i<800;i=i+1)
begin
    // $fwrite(result_file,"%b\n",two_port_ram_2048x4096_acc.mem[i]);
    $fwrite(result_file,"%b\n",two_port_ram_512x4096_ofmap.mem[i]);
end
end

always @(negedge clk)
begin
if(vcu_done)
begin
        for(i=0;i<800;i=i+1)
    begin
        $fwrite(result_file,"%b\n",two_port_ram_2048x4096_acc.mem[i]);
    end
$finish();
end

end

integer sim_time = 5000000;

initial begin
    #sim_time $finish();
end

// always @(posedge clk)
// begin
//     if(w_en_acc)
//     begin
//         $fwrite(result_file,"%b\n",w_data_acc);
//     end

//     if(vcu.vcu_done)
//     begin
//         $fclose(result_file);
//     end
// end

endmodule

