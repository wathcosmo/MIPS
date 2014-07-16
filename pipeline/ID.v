module ID(clk, reset, flush, irqout, instruct, pc, data_c, addrc, 
            reg_wr_wb, pc_ex, inst, reg_dst_out, reg_wr_out, alu_src1_out, 
            alu_src2_out, alu_fun_out, sign_out, mem_wr_out, mem_rd_out, mem2reg_out, 
            pc_src, jt, data_a0, data_b0, data_b1, im_ext_out, conba, da, db, rs_i, rt_i, alu_fun_id, sign_id);
    input clk, reset, flush, irqout, reg_wr_wb;
    input [31:0] instruct, pc, data_c;
    input [4:0] addrc;
    output reg [31:0] pc_ex, inst;
    output reg [1:0] reg_dst_out, mem2reg_out;
    output reg [5:0] alu_fun_out;
    output reg [2:0] pc_src;
    output reg reg_wr_out, alu_src1_out, alu_src2_out;
    output reg sign_out, mem_wr_out, mem_rd_out;
    output reg [31:0] data_a0, data_b0, data_b1, im_ext_out, conba;
    output [25:0] jt;
    output sign_id;
    output [5:0] alu_fun_id;
    reg [31:0] im_ext;
    reg [5:0] alu_fun;
    reg [1:0] reg_dst, mem2reg;
    reg irq;
    reg reg_wr, alu_src1, alu_src2, sign, mem_wr, mem_rd, extop, luop;
    wire [4:0] rs, rt;
    output [31:0] da, db;
    output [4:0] rs_i, rt_i;
    
    RegFile rf(reset, clk, rs, da, rt, db, reg_wr_wb, 
        addrc, data_c);
    
    initial
    begin
        irq = 0;
    end
    
    assign jt = instruct[25:0];
    assign rs = instruct[25:21];
    assign rt = instruct[20:16];
    assign rs_i = rs;
    assign rt_i = rt;
    assign alu_fun_id = alu_fun;
    assign sign_id = sign;
    
    always @(*)  //extend
    begin
        im_ext[15:0] <= instruct[15:0];
        if (extop && instruct[15])
            im_ext[31:16] <= 16'hffff;
        else
            im_ext[31:16] <= 0;
            
        conba <=  pc + 4 + (im_ext << 2);
        conba[31] <= pc[31];
    end
    
    always @(posedge clk or negedge reset) //ID/EX
    begin
        if (~reset)
        begin
            irq <= 0;
            pc_ex <= 0;
            inst <= 0;
            mem_rd_out <= 0;
            mem_wr_out <= 0;
            reg_wr_out <= 0;
        end
        else if (flush)
        begin
            inst <= 0;
            pc_ex <= 0;
            reg_wr_out <= 0;
            mem_wr_out <= 0;
            mem_rd_out <= 0;
            alu_src1_out <= 0;
            alu_src2_out <= 0;
        end
        else
        begin
            irq <= irqout;
            pc_ex <= pc;
            inst <= instruct;
            reg_dst_out <= reg_dst;
            reg_wr_out <= reg_wr;
            mem_wr_out <= mem_wr;
            mem_rd_out <= mem_rd;
            mem2reg_out <= mem2reg;
            alu_src1_out <= alu_src1;
            alu_src2_out <= alu_src2;
            alu_fun_out <= alu_fun;
            sign_out <= sign;
            im_ext_out <= im_ext;
            data_a0 <= da;
            data_b0 <= db;
            if (luop) 
                data_b1 <= {instruct[15:0],16'b0};
            else
                data_b1 <= im_ext;
        end
    end
      
    
    
    always @(*)  //decode
    begin       
		reg_dst <= 0;
		reg_wr <= 0;
		mem_rd <= 0;
		mem_wr <= 0;
		mem2reg <= 0;
		alu_src1 <= 0;
		alu_src2 <= 0;
		alu_fun <= 0;
		sign <= 0;
		extop <= 0;
		luop <= 0;
		pc_src <= 0;
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
                            
                            default: if (pc[31] == 0) //exception: undefined inst
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
                    12:  //andi
                    begin
                        reg_dst <= 1;
                        mem2reg <= 0;
                        reg_wr <= 1;
                        alu_src1 <= 0;
                        alu_src2 <= 1;
                        alu_fun <= 6'b011000;
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
                        reg_wr <= 1;
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
                    
                    default: if (pc[31] == 0)  //exception: undefined inst
                                begin
                                    reg_wr <= 1;
                                    pc_src <= 5;
                                    reg_dst <= 3;
                                    mem2reg <= 2;
                                end
                endcase
        
    end
    
endmodule       
     