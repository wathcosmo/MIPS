`timescale 1ns/1ps
module Exc(clk, reset, instruct, pc, tm_data, um_data,
            reg_dst, reg_wr, alu_src1, alu_src2, alu_fun,
             sign, mem_wr, mem_rd, mem2reg, extop, luop,
            conba, data_a0, branch, alu_out, wdata,
            tm_wr, tm_rd, um_wr, um_rd
            );
    
    parameter Xp = 26;
    parameter Ra = 31;
    input clk, reset;
    input [31:0] instruct, pc, tm_data, um_data;
    input [5:0] alu_fun;
    input [1:0] reg_dst, mem2reg;
    input reg_wr, alu_src1, alu_src2, sign, mem_wr, mem_rd;
    input extop, luop;
    output reg [31:0] conba;
    output [31:0] data_a0, wdata, alu_out;
    output branch;
    output reg tm_wr, tm_rd, um_wr, um_rd;
    wire [31:0] data_b0, dm_data;
    wire [15:0] imm16;
    wire [4:0] shamt, rs, rt, rd;
    reg [4:0] addrc;
    reg [31:0] im_ext, data_a, data_b, data_b1, data_c, rdata;
    reg dm_wr, dm_rd;
    
    RegFile rf(reset, clk, rs, data_a0, rt, data_b0, reg_wr, 
        addrc, data_c);
    
    DataMem dm(reset, clk, dm_rd, dm_wr, alu_out, data_b0, dm_data);
    
    ALU alu1(data_a, data_b, alu_fun, sign, alu_out);
    
    assign imm16 = instruct[15:0];
    assign shamt = instruct[10:6];
    assign rs = instruct[25:21];
    assign rt = instruct[20:16];
    assign rd = instruct[15:11];
    assign branch = alu_out[0];
    assign wdata = data_b0;
    
    always @(*)  //choose alu_src
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
            data_b <= data_b1;
        else
            data_b <= data_b0;
        
        if (alu_src1)
            data_a <= {27'b0,shamt[4:0]};
        else
            data_a <= data_a0;
    end
    
    always @(*)  //choose reg write data
    begin
        case(mem2reg)
            0: data_c <= alu_out;
            1: data_c <= rdata;
            2: data_c <= pc + 4;
        endcase
    end
    
    always @(*)  //choose reg_dst
    begin
        case(reg_dst)
            0: addrc <= rd;
            1: addrc <= rt;
            2: addrc <= Ra;
            3: addrc <= Xp;
        endcase    
    end
    
    always @(*)  //choose mem from DM, Per, Uart
    begin
        if (mem_wr)
        begin
            if (alu_out[30])
            begin
                if (alu_out[7:0] < 8'h15) 
                begin
                  tm_wr <= 1;
                  um_wr <= 0;
                  dm_wr <= 0;
                end
                else 
                begin
                  tm_wr <= 0;
                  um_wr <= 1;
                  dm_wr <= 0;
                end
            end
            else 
            begin
              tm_wr <= 0;
              um_wr <= 0;
              dm_wr <= 1;
            end
        end
        else
        begin
            tm_wr <= 0;
            um_wr <= 0;
            dm_wr <= 0;
        end
        
        if (mem_rd)
        begin
            if (alu_out[30])
            begin
                if (alu_out[7:0] < 8'h15) 
                begin
                    tm_rd <= 1;
                    um_rd <= 0;
                    dm_rd <= 0;
                    rdata <= tm_data;
                end
                else 
                begin
                    um_rd <= 1;
                    tm_rd <= 0;
                    dm_rd <= 0;
                    rdata <= um_data;
                end
            end
            else 
            begin
                dm_rd <= 1;
                um_rd <= 0;
                tm_rd <= 0;
                rdata <= dm_data;
            end
        end
        else
        begin
            dm_rd <= 0;
            um_rd <= 0;
            tm_rd <= 0;
        end
        
    end
    
    
endmodule

