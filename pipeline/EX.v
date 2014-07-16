module EX(clk, reset, pc, instruct, alu_src1, alu_src2, alu_fun,
            sign, reg_dst, reg_wr, mem_rd, mem_wr, mem2reg, data_a0_e,
            data_b0_e, data_w, data_b1, im_ext, reg_wr_w, addr_w,
            data_m, data_b0_nxt, pc_mem, mem_rd_m, mem_wr_m, mem2reg_m, reg_wr_m, addr_m, rt_e, addr_e2fwd, data_e2fwd);
    parameter Xp = 26;
    parameter Ra = 31;
    input clk, reset;
    input [31:0] pc, instruct, data_b1, im_ext, data_a0_e, data_b0_e;
    input [31:0] data_w;
    input alu_src1, alu_src2, sign, reg_wr, reg_wr_w, mem_wr, mem_rd;
    input [5:0] alu_fun;
    input [4:0] addr_w;
    input [1:0] mem2reg, reg_dst;
    output reg [31:0] data_m, pc_mem, data_b0_nxt;
    output reg mem_rd_m, mem_wr_m, reg_wr_m;
    output reg [4:0] addr_m;
    output reg [1:0] mem2reg_m;
    output [4:0] rt_e;
    output reg [4:0] addr_e2fwd;
    output [31:0] data_e2fwd;
    reg [31:0] data_a, data_b, data_a0, data_b0;
    wire [31:0] aluout;
    wire [4:0] shamt, rs, rt, rd;
    
    ALU alu1(data_a, data_b, alu_fun, sign, aluout);
    
    assign shamt = instruct[10:6];
    assign rs = instruct[25:21];
    assign rt = instruct[20:16];
    assign rd = instruct[15:11];
    assign rt_e = rt;
    assign data_e2fwd = aluout;
    
    
    always @(*)  //choose alu_src
    begin
        if (alu_src2)
            data_b <= data_b1;
        else
            data_b <= data_b0;
        
        if (alu_src1)
            data_a <= {27'b0,shamt[4:0]};
        else
            data_a <= data_a0;
        
    end
    
    always @(*)
    begin
        case(reg_dst)
            0: addr_e2fwd <= rd;
            1: addr_e2fwd <= rt;
            2: addr_e2fwd <= Ra;
            3: addr_e2fwd <= Xp;
        endcase  
    end
    
    always @(posedge clk or negedge reset)  //updata EX/MEM
    begin
        if (~reset)
        begin
            mem_rd_m <= 0;
            mem_wr_m <= 0;
            reg_wr_m <= 0;
            addr_m <= 0;
			pc_mem <= 0;
        end
        else
        begin
            data_m <= aluout;
            pc_mem <= pc;
            mem_rd_m <= mem_rd;
            mem_wr_m <= mem_wr;
            mem2reg_m <= mem2reg;
            reg_wr_m <= reg_wr;
            data_b0_nxt <= data_b0;
            addr_m <= addr_e2fwd;  
        end
    end
    
    always @(*) //forwarding
    begin
        if (reg_wr_m && (addr_m != 0) && (addr_m == rs)) 
            data_a0 <= data_m;
        else if (reg_wr_w && (addr_w != 0) && ( (addr_m != rs) 
            || ~reg_wr_m) && (addr_w == rs))
            data_a0 <= data_w;
        else data_a0 <= data_a0_e;
        
        if (reg_wr_m && (addr_m != 0) && (addr_m == rt)) 
            data_b0 <= data_m;
        else if (reg_wr_w && (addr_w != 0) && ( (addr_m != rt) 
            || ~reg_wr_m) && (addr_w == rt))
            data_b0 <= data_w;
        else data_b0 <= data_b0_e;
    end
    
    
    
    
endmodule
