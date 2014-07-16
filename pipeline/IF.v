module IF(clk, reset, pcifd_wr, cancel, conba, jt, data_a0, branch, pc_src, pc_id, inst, pc_if, instruct);
    parameter ILLOP = 32'h8000_0004;
    parameter XADR = 32'h8000_0008;
    input clk, reset, branch, pcifd_wr, cancel;
    input [31:0] conba, data_a0;
    input [2:0] pc_src;
    input [25:0] jt;
    output reg [31:0] pc_id, inst;
    output wire [31:0] instruct;
    output reg [31:0] pc_if;
    
    initial
    begin
        pc_if = 32'h0040_0000;
    end
    
    ROM rm({1'b0, pc_if[30:0]}, instruct);
    
    always @(posedge clk or negedge reset)
    begin
        if (~reset)
        begin
            pc_if <= 32'h80000000;
			pc_id <= 32'h0;
            inst <= 32'h0;
        end 
        else 
        begin
            if (pcifd_wr)
            begin
                case(pc_src)
                    0: pc_if <= pc_if + 4;
                    1: pc_if <= (branch == 1)? conba : pc_if + 4;
                    2: pc_if[27:0] <= {jt,2'b00};
                    3: pc_if <= data_a0;
                    4: pc_if <= ILLOP;
                    5: pc_if <= XADR;
                endcase
            
                if (cancel) 
                begin
                    inst <= 32'b0;
                    pc_id[30:0] <= 31'b0;
                    pc_id[31] <= pc_if[31];
                end
                else 
                begin
                    pc_id <= pc_if;
                    inst <= instruct;
                end
            end
        end
    end
    
endmodule
