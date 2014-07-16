module MEM(clk, reset, alu_out, data_b0, pc, reg_wr, mem_rd, addrc,
            mem_wr, mem2reg, tm_data, um_data,
            alu_out_w, pc_w, addrm_rd, wdata, mem_out, tm_wr, tm_rd, um_wr, um_rd,
            reg_wr_w, mem2reg_w, addrc_w, mem_out2fwd);
    input clk, reset;
    input [31:0] alu_out, pc, data_b0, tm_data, um_data;
    input [4:0] addrc;
    input [1:0] mem2reg;
    input reg_wr, mem_rd, mem_wr;
    output reg [31:0] alu_out_w, pc_w, mem_out;
    output [31:0] wdata;
    output reg [4:0] addrc_w;
    output reg reg_wr_w;
    output reg [1:0] mem2reg_w;
    output reg tm_wr, tm_rd, um_wr, um_rd;
    output [31:0] addrm_rd, mem_out2fwd;
    reg [31:0] mem_m;
    wire [31:0] dm_data;
    reg dm_rd, dm_wr;
    
    DataMem dm(reset, clk, dm_rd, dm_wr, alu_out, data_b0, dm_data);
    
    assign wdata = data_b0;
    assign addrm_rd = alu_out;
    assign mem_out2fwd = mem_m;
    
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
                end
                else 
                begin
                    um_rd <= 1;
                    tm_rd <= 0;
                    dm_rd <= 0;
                end
            end
            else 
            begin
                dm_rd <= 1;
                um_rd <= 0;
                tm_rd <= 0;
            end
        end
        else
        begin
            dm_rd <= 0;
            um_rd <= 0;
            tm_rd <= 0;
        end
        
        if (mem_rd) //choose mem from DM, Per, Uart to read;
            begin
                if (alu_out[30])
                begin
                    if (alu_out[7:0] < 8'h15) mem_m <= tm_data;
                    else mem_m <= um_data;
                end
                else mem_m <= dm_data;
            end 
		else mem_m <= 0;
    end
    
    always @(posedge clk or negedge reset)  //updata MEM/WB
    begin
        if (~reset)
        begin
            reg_wr_w <= 0;
			pc_w <= 0;
        end
        else
        begin
            alu_out_w <= alu_out;
            pc_w <= pc;
            reg_wr_w <= reg_wr;
            addrc_w <= addrc;
            mem2reg_w <= mem2reg;
            mem_out <= mem_m;   
        end
    end
endmodule
