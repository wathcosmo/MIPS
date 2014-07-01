module ctrl(clk, conba, data_a, irq
            imm16, shamt, rs, rt, rd, 
            pcsrc, reg_dst, reg_wr, alu_src1, alu_src2,
            alu_fun, sign, mem_wr, mem_rd, mem2reg,
            extop, luop);
            
    parameter ILLOP = 32'h8000_0004;
    parameter XADR = 32'h8000_0008;
    wire [31:0] instruct;
    wire [25:0] jt;
    input [31:0]
    
    
    
endmodule
