module fwdbj(data_a_id, data_b_id, rs_i, rt_i, addr_e, addr_m, addr_w,
            reg_wr_e, reg_wr_m, reg_wr_w, data_e, data_m, data_w, mem_m, mem_rd, alu_fun_id, sign_id, data_a, branch);
    input [31:0] data_a_id, data_b_id, data_e, data_m, data_w, mem_m;
    input [4:0] rs_i, rt_i, addr_e, addr_m, addr_w;
    input [5:0] alu_fun_id;
    input mem_rd, reg_wr_e, reg_wr_m, reg_wr_w, sign_id;
    output branch;
    output reg [31:0] data_a;
    reg [31:0] data_b;
    wire [31:0] alu_out;
    
    assign branch = alu_out[0];
    
    ALU aluf(data_a, data_b, alu_fun_id, sign_id, alu_out);
    
    always @(*) //forwarding
    begin
        if (reg_wr_e && (addr_e != 0) && (addr_e == rs_i))
            data_a <= data_e;
        else if (reg_wr_m && (addr_m != 0) && (addr_m == rs_i))
        begin
            if (mem_rd) data_a <= mem_m;
            else data_a <= data_m;
        end
        else if (reg_wr_w && (addr_w != 0) && (addr_w == rs_i))
            data_a <= data_w;
        else data_a <= data_a_id;
            
        if (reg_wr_e && (addr_e != 0) && (addr_e == rt_i))
            data_b <= data_e;
        else if (reg_wr_m && (addr_m != 0) && (addr_m == rt_i))
        begin
            if (mem_rd) data_b <= mem_m;
            else data_b <= data_m;
        end
        else if (reg_wr_w && (addr_w != 0) && (addr_w == rt_i))
            data_b <= data_w;     
        else data_b <= data_b_id;
    end
    
    
endmodule
