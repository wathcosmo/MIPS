module exc(clk, reset, instruct, pc, 
            reg_dst, reg_wr, alu_src1, alu_src2, 
            alu_fun, sign, mem_wr, mem_rd, mem2reg, extop, luop,
            conba, data_a, branch,
            );
    
    parameter Xp = 26;
    parameter Ra = 31;
    input clk, reset;
    input [31:0] instruct, pc;
    input [5:0] alu_fun;
    input [1:0] reg_dst, mem2reg;
    input reg_wr, alu_src1, alu_src2, sign, mem_wr, mem_rd;
    input extop, luop;
    output reg [31:0] conba;
    output [31:0] data_a;
    output branch;
    wire [31:0] data_a0, data_b0, rdata, alu_out;
    wire [15:0] imm16;
    wire [4:0] shamt, rs, rt, rd;
    reg [4:0] addrc;
    reg [31:0] im_ext, data_a, data_b, data_b1, data_c;
    
    RegFile rf(reset, clk, rs, data_a0, rt, data_b0, reg_wr, 
        addrc, data_c);
    
    DataMem dm(reset, clk, mem_rd, mem_wr, alu_out, data_b0, rdata);
    
    
    assign imm16 = instruct[15:0];
    assign shamt = instruct[10:6];
    assign rs = instruct[25:21];
    assign rt = instruct[20:16];
    assign rd = instruct[15:11];
    assign branch = alu_out[0];
    
    always @(*)
    begin
        case(reg_dst)
            0: addrc = rd;
            1: addrc = rt;
            2: addrc = Ra;
            3: addrc = Xp;
        endcase    
    end
    
    always @(*)
    begin
        im_ext[15:0] <= imm16;
        if (extop && (imm16[15] == 1))
            im_ext[31:16] <= 16'hffff;
        else
            im_ext[31:16] <= 0;
            
        conba <=  pc + 4 + (im_ext << 2);
        conba[31] <= pc[31];
        if (luop) 
            data_b1 <= {imm16,16'b0};
        else
            data_b1 <= im_ext;
            
        if (alu_src2)
            data_b <= data_b0;
        else
            data_b <= data_b1;
        
        if (alu_src1)
            data_a <= {27'b0,shamt[4:0]};
        else
            data_a <= data_a0;
    end
    
    always @(*)
    begin
        case(mem2reg)
            0: data_c = alu_out;
            1: data_c = rdata;
            2: data_c = pc + 4;
        endcase
    end
    
    
endmodule
