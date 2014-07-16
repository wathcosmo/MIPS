module bj(pc_src, cancel, branch);
    input [2:0] pc_src;
    input branch;
    output reg cancel;
    
    initial
    begin
        cancel <= 0;
    end
    
    always @(*)
    begin
        case (pc_src)
            1:  if (branch) cancel <= 1;
                else cancel <= 0;
            2: cancel <= 1;
            3: cancel <= 1;
            default: cancel <= 0;
        endcase
    end
    
endmodule