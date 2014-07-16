module WB(clk, reset, alu_out, pc, mem_out, reg_wr, mem2reg, addrc,
            data_c, addrc_out, reg_wr_w);
    input clk, reset;
    input [31:0] alu_out, pc, mem_out;
    input [4:0] addrc;
    input [1:0] mem2reg;
    input reg_wr;
    output reg [31:0] data_c;
    output [4:0] addrc_out;
    output reg_wr_w;
    
    assign addrc_out = addrc;
    assign reg_wr_w = reg_wr;
    
    always @(*)  //choose reg write data
    begin
        case(mem2reg)
            0: data_c <= alu_out;
            1: data_c <= mem_out;
            2: data_c <= pc + 4;
			default: data_c <= 0;
        endcase
    end
    
    
    
endmodule
