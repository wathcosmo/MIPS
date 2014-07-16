module detect(mem_rd_e, rt_e, rs_i, rt_i, flush, pc_ifd_wr);
    input mem_rd_e;
    input [4:0] rt_e, rs_i, rt_i;
    output reg flush, pc_ifd_wr;
    
    initial
    begin
        flush <= 0;
        pc_ifd_wr <= 1;
    end
        
    
    always @(*)
    begin
        if (mem_rd_e && ((rt_e == rs_i) || (rt_e == rt_i)))
        begin
            flush <= 1;
            pc_ifd_wr <= 0;
        end 
        else
        begin
            flush <= 0;
            pc_ifd_wr <= 1;
        end
    end
    
endmodule
