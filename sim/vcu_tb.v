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
  reg [INSN_WIDTH-1:0]insn_reg[0:9];
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

  integer insn_num;

  initial
    begin
      result_file = $fopen("./result_fp16.dat","w");
      $readmemh("../compiler/insn.dat",insn_reg);
      $readmemh("../data/psum.dat",two_port_ram_2048x4096_acc.mem);
      $readmemh("../data/para.dat",two_port_ram_1024x32_para.mem);
      $readmemh("../compiler/opcode.dat",vcu.two_port_ram_16x1024_opcode.mem);
      $readmemh("../data/resadd.dat",two_port_ram_1024x512_resadd.mem);


      clk = 1;
      rst = 0;
      insn = 'd0;
      // 584574 = 0;
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
       for(insn_num=0;insn_num<`NUM_INSN;insn_num=insn_num+1)
         begin
           insn = insn_reg[insn_num];
           @(posedge vcu_done);
         end

       #1000 
       $fclose(result_file);
       $finish();
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

  initial
    begin
      @(posedge vcu_done)
        begin
          for(i=0;i<`DATA_NUM;i=i+1)
            begin
              $fwrite(result_file,"%h\n",two_port_ram_512x4096_ofmap.mem[i]);
            end
        end
    end

  integer sim_time = 5000000;

  initial
    begin
      #sim_time $finish();
    end

  initial
    begin
      // $dumpfile("npu_whole.vcd");
      // $dumpvars;
      $fsdbDumpfile("vcu.fsdb");
      $fsdbDumpvars(0);
      $fsdbDumpMDA();
    end

endmodule

