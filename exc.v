module exc(clk, instruct, reg_dst, reg_wr, alu_src1, alusrc2, 
            alu_fun, sign, mem_wr, mem_rd, mem2reg, extop, luop,
            conba, data_a, branch,
            );
    
    parameter Xp = 26;
    parameter Ra = 31;
    input clk;
    input [31:0] instruct;
    input [5:0] alu_fun;
    input [1:0] reg_dst, mem2reg;
    input reg_wr, alu_src1, alu_src2, sign, mem_wr, mem_rd;
    input extop, luop;
    output [31:0] conba, data_a;
    output branch;
    wire [31:0] alu_out;
    wire [15:0] imm16;
    wire [4:0] shamt, rs, rt, rd;
    
    assign imm16 = instruct[15:0];
    assign shamt = instruct[10:6];
    assign rs = instruct[25:21];
    assign rt = instruct[20:16];
    assign rd = instruct[15:11];
    assign branch = alu_out[0];
    
    
    
    
    
endmodule