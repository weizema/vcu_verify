`timescale 1ps/1ps

module reciprocal(data,data_valid,rst,clk,result,complete);

parameter dividend = 15'b0000_10000000000;

input wire [15:0]data;
input wire data_valid;
input clk;
input rst;

output wire [15:0]result;
output reg complete;

parameter IDLE = 2'b00;
parameter PRE_PROCESS = 2'b01;
parameter COMPUTE = 2'b10;
parameter OVER = 2'b11;

//state information
reg [1:0]state,next_state;

//data 
wire data_signal;
wire [4:0]data_exp;
wire [9:0]data_mantissa;

//state = PRE_PROCESS
reg signed [5:0]exp_pre_process;
reg [9:0]mantissa_pre_process;
reg result_signal;

//state = Q_SEARCH
wire signed [5:0]exp_first;
wire [14:0]divisor;
wire [14:0]shiftw;
reg [14:0]w0;
wire [5:0]p;
wire [2:0]d;
wire [2:0]q;
reg [15:0]a,b;
reg signed [14:0]divisor_s;

reg [3:0]iteration_count;
reg complete_temp;


// reg [4:0]result_exp;
// reg [9:0]result_frac;

assign data_signal = data[15];
assign data_exp = data[14:10];
assign data_mantissa = data[9:0];

always @(*)
begin
    case(state)
        IDLE:
        begin
            if(data_valid)
                next_state = PRE_PROCESS;
            else
                next_state = IDLE;
        end
        PRE_PROCESS:
        begin
            next_state = COMPUTE;
        end
        COMPUTE:
        begin
            if(complete_temp)
                next_state = OVER;
            else
                next_state = COMPUTE;
        end
        OVER:
        begin
            if(complete)
                next_state = IDLE;
            else
                next_state = OVER;
        end
    endcase
end


always @(posedge clk)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

always @(posedge clk)
begin
    if(rst|complete)
    begin
        exp_pre_process <= 'd0;
        mantissa_pre_process <= 'd0;
        result_signal <= 'd0;
    end
    else 
    begin
        if(next_state == PRE_PROCESS)
        begin
            result_signal <= data_signal;
            if(data_exp == 5'b00000)
            begin
                if(data_mantissa[9] == 1'b1)
                begin
                    exp_pre_process <= 0;
                    mantissa_pre_process <= data_mantissa<<1;
                end
                else if(data_mantissa[9:8] == 2'b01)
                begin
                    exp_pre_process <= -1;
                    mantissa_pre_process <= data_mantissa<<2;
                end
                else
                begin
                    exp_pre_process <= -2;
                    mantissa_pre_process <= data_mantissa;
                end
            end
            else
            begin
                exp_pre_process <= data_exp;
                mantissa_pre_process <= data_mantissa;
            end
        end
    end
end

assign exp_first = 29-exp_pre_process;

//Q_SEARCH
assign divisor = {4'b0001,mantissa_pre_process,1'b0};
assign shiftw = {w0[14],w0[13:0]<<2};
assign d = divisor[10:8];
assign p = shiftw[14:9];

QDS QDS(
    .p(p),
    .d(d),
    .q(q)
);

always @(*)
begin
    if(q == 0)//0
        divisor_s <= 15'b0;
    else if(q == 3'b111)//-1
        divisor_s <= divisor;
    else if(q == 3'b110)//-2
        divisor_s <= {divisor[14],divisor[13:0]<<1};
    else if(q == 3'b001)//1
        divisor_s <= {~divisor[14],~divisor[13:0]}+1;
    else if(q == 3'b010)//2
        divisor_s <= {~divisor[14],~(divisor[13:0]<<1)}+1;
end

//on-the-fly conversion
always@(posedge clk)
begin
    if(rst)
    begin
        a <= 'd0;
    end
    else
    begin
        if(next_state == COMPUTE)
            begin
            if(q[2]==0)
                a <= {a[13:0],q[1:0]};
            else
                a <= {b[13:0],q[1:0]};
            end
    end
end


always @(posedge clk)
begin
    if(rst)
    begin
        b <= 14'b0;
    end
    else
    begin
        if(next_state == COMPUTE)
        begin
            case(q)
            3'b010:b <= {a[13:0],2'b01};
            3'b001:b <= {a[13:0],2'b00};
            3'b000:b <= {b[13:0],2'b11};
            3'b111:b <= {b[13:0],2'b10};
            3'b110:b <= {b[13:0],2'b01};
            default:b <= 14'b0;
            endcase
        end
    end 
end

//W_COMPUTE
always @(posedge clk)
begin
    if(rst|complete)
    begin
        iteration_count <= 'd0;
        w0 <= dividend;
    end
    else
    begin
        if(next_state == COMPUTE)
        begin
            w0 <= shiftw + divisor_s;  
            if(iteration_count == 7)
            begin
                iteration_count <= 0;
            end
            else
            begin
                iteration_count <= iteration_count + 1;
            end
        end
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        complete_temp <= 'd0;
    end
    else
    begin
        if(iteration_count == 7)
        begin
            complete_temp <= 1'b1;
        end
        else
        begin
            complete_temp <= 1'b0;
        end
    end
end

reg signed [5:0]exp_second;
reg [15:0]a_temp;

always @(*)
begin
    if(exp_first<=0)
    begin
        a_temp = a>>(-exp_first+1);
        exp_second = 'd0;
        if (a_temp[14] == 1)
            exp_second = 'd1;
    end
    else 
    begin
        a_temp = a;
        exp_second = exp_first;
    end
end

//舍入
reg [11:0]fraction_round_off;
always @(*)
begin
    if(complete_temp == 1)
    begin
        fraction_round_off = a_temp[13:4]+a_temp[3];   
    end
end

reg [9:0]mantissa_carry;
reg [4:0]exp_carry;

always @(*)
begin
    if(a_temp[15] == 1'b1)
    begin
        exp_carry = exp_first + 1;
        mantissa_carry = fraction_round_off[10:1];
    end
    else
    begin
        exp_carry = exp_first;
        mantissa_carry = fraction_round_off[9:0];     
    end
end

reg [4:0]result_exp;
reg [9:0]result_mantissa;


always@(posedge clk)
begin
    if(rst|complete)
    begin
        result_exp <= 'd0;
        result_mantissa <= 'd0;
    end
    else
    begin
        if(state == IDLE)
        begin
            result_exp <= 'd0;
            result_mantissa <= 'd0;
        end
        else if(complete_temp == 1)
        begin
            if(exp_carry>30)
            begin
                result_exp <= 5'b11110;
                result_mantissa <= 10'b1111111111;
            end
            else
            begin
                result_exp <= exp_carry;
                result_mantissa <= mantissa_carry;
            end
        end
    end
end  

always @(posedge clk)
begin
    if(rst)
    begin
        complete <= 0;
    end
    else
    begin
        if(next_state == OVER)
        begin
            complete <= 1'b1;
        end
        else
        begin
            complete <= 1'd0;
        end
    end
end

assign result = {result_signal,result_exp,result_mantissa};

endmodule