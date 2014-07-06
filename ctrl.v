module Ctrl(clk, reset, irq out, conba, data_a0, branch,
            instruct, pc, reg_dst, reg_wr, alu_src1, alu_src2,
            alu_fun, sign, mem_wr, mem_rd, mem2reg, extop, luop);
            
    parameter ILLOP = 32'h8000_0004;
    parameter XADR = 32'h8000_0008;
    input clk, irqout, branch;
    input [31:0] conba, data_a0;
    output [31:0] instruct;
    output reg [31:0] pc;
    output reg [1:0] reg_dst, mem2reg;
    output reg [5:0] alu_fun;
    output reg reg_wr, alu_src1, alu_src2;
    output reg sign, mem_wr, mem_rd, extop, luop;
    wire [25:0] jt;
    reg [2:0] pc_src;
    reg irq;
    
    initial
    begin
        pc = 32'h00400000;   //instruction start address
    end
    
    ROM IF({1'b0, pc[30:0]}, instruct);
    
    assign jt = instruct[25:0];
    
    always @(posedge clk or negedge reset)
    begin
        if (~reset)
        begin
            pc <= 32'h80000000;
        end
        else
        begin
            case(pc_src)
                0: pc <= pc + 4;
                1: pc <= (branch == 1)? conba : pc + 4;
                2: pc[27:0] <= {jt,2'b00};
                3: pc <= data_a0;
                4: pc <= ILLOP;
                5: pc <= XADR;
            endcase
        end    
           
        irq <= irqout;    
    end
    
    always @(*)
    begin
        if (irq && (pc[31] == 0))  // interrupt
        begin
            reg_dst <= 3;
            mem2reg <= 2;
            reg_wr <= 1;
            mem_wr <= 0;
            mem_rd <= 0;
            pc_src <= 4;
        end
        else
        case(instruct[31:26])
                0:  //R-format
                begin
                    reg_dst <= 0;
                    mem2reg <= 0;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 0;
                    alu_fun <= 0;
                    mem_wr <= 0;
                    mem_rd <= 0;    
                    pc_src <= 0;
                    case(instruct[5:0])
                        0:  //sll
                        begin
                            alu_src1 <= 1;
                            alu_fun <= 6'b100000;
                            sign <= 0;
                        end
                        2:  //srl
                        begin
                            alu_src1 <= 1;
                            alu_fun <= 6'b100001;
                            sign <= 0;
                        end
                        3:  //sra
                        begin
                            alu_src1 <= 1;
                            alu_fun <= 6'b100011;
                            sign <= 1;
                        end
                        8:  //jr
                        begin           
                            reg_wr <= 0;
                            pc_src <= 3;
                        end
                        9:  //jalr
                        begin
                            reg_dst <= 2;
                            mem2reg <= 2;  
                            pc_src <= 3;
                        end
                        32:  //add
                        begin
                            alu_fun <= 0;
                            sign <= 1;
                        end
                        33:  //addu
                        begin
                            alu_fun <= 0;
                            sign <= 0;
                        end
                        34:  //sub
                        begin
                            alu_fun <= 6'b000001;
                            sign <= 1;
                        end
                        35:  //subu
                        begin
                            alu_fun <= 6'b000001;
                            sign <=  0;
                        end
                        36:  //and
                        begin
                            alu_fun <= 6'b011000;
                        end
                        37:  //or
                        begin
                            alu_fun <= 6'b011110;
                        end
                        38:  //xor
                        begin
                            alu_fun <= 6'b010110;
                        end
                        39:  //nor
                        begin
                            alu_fun <= 6'b010001;
                        end
                        42:  //slt
                        begin
                            alu_fun <= 6'b110101;
                            sign <= 1;
                        end
                        43:  //sltu
                        begin
                            alu_fun <= 6'b010001;
                            sign <= 0;
                        end
                        
                        default: if (pc[31] == 0)
                            begin
                                pc_src <= 5;
                                reg_dst <= 3;
                                mem2reg <= 2;
                            end
                    endcase
                end
                1:  
                begin
                    case(instruct[20:16])
                        0:  //bltz
                        begin
                            pc_src <= 1;
                            reg_wr <= 0;
                            alu_src1 <= 0;
                            alu_src2 <= 0;
                            alu_fun <= 6'b111101;
                            sign <= 1;
                            mem_wr <= 0;
                            mem_rd <= 0;
                            extop <= 1;
                            luop <= 0;
                        end
                        
                        default: if (pc[31] == 0)
                            begin
                                reg_wr <= 1;
                                pc_src <= 5;
                                reg_dst <= 3;
                                mem2reg <= 2;
                            end
                    endcase
                end
                2:  //j
                begin
                    reg_wr <= 0;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    pc_src <= 2;
                end
                3:  //jal
                begin
                    reg_dst <= 2;
                    mem2reg <= 2;
                    reg_wr <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    pc_src <= 3;
                end
                4:  //beq
                begin
                    reg_wr <= 0;
                    alu_src1 <= 0;
                    alu_src2 <= 0;
                    alu_fun <= 6'b110011;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 1;
                end
                5:  //bne
                begin
                    reg_wr <= 0;
                    alu_src1 <= 0;
                    alu_src2 <= 0;
                    alu_fun <= 6'b110001;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 1;
                end
                6:  //blez
                begin
                    reg_wr <= 0;
                    alu_src1 <= 0;
                    alu_src2 <= 0;
                    alu_fun <= 6'b111101;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 1;
                end
                7:  //bgtz
                begin
                    reg_wr <= 0;
                    alu_src1 <= 0;
                    alu_src2 <= 0;
                    alu_fun <= 6'b111111;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 1;
                end
                8:  //addi
                begin
                    reg_dst <= 1;
                    mem2reg <= 0;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 0;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <=0;
                end
                9:  //addiu
                begin
                    reg_dst <= 1;
                    mem2reg <= 0;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 0;
                    sign <= 0;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 0;
                    luop <= 0;
                    pc_src <=0;
                end
                10:  //slti
                begin
                    reg_dst <= 1;
                    mem2reg <= 0;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 6'b110101;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 1;
                    luop <= 0;
                    pc_src <=0;
                end
                11:  //sltiu
                begin
                    reg_dst <= 1;
                    mem2reg <= 0;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 6'b110101;
                    sign <= 0;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    extop <= 0;
                    luop <= 0;
                    pc_src <=0;
                end
                15:  //lui
                begin
                    reg_dst <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 6'b000000;
                    sign <= 0;
                    mem_wr <= 0;
                    mem_rd <= 0;
                    luop <= 1;
                    pc_src <= 0;
                end
                35:  //lw
                begin
                    reg_dst <= 1;
                    mem2reg <= 1;
                    reg_wr <= 1;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 6'b000000;
                    sign <= 1;
                    mem_wr <= 0;
                    mem_rd <= 1;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 0;
                end
                43:  //sw
                begin
                    reg_wr <= 0;
                    alu_src1 <= 0;
                    alu_src2 <= 1;
                    alu_fun <= 6'b000000;
                    sign <= 1;
                    mem_wr <= 1;
                    mem_rd <=0 ;
                    extop <= 1;
                    luop <= 0;
                    pc_src <= 0;
                end
                
                default: if (pc[31] == 0)  //exception: undefined ins
                            begin
                                reg_wr <= 1;
                                pc_src <= 5;
                                reg_dst <= 3;
                                mem2reg <= 2;
                            end
            endcase
    end
    
    
    
    
endmodule
