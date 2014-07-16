module MIPS(sysclk, reset, switch, led, dig1, dig2, dig3, dig4, uart_rx, uart_tx);
    input sysclk, reset, uart_rx;
    output uart_tx;
    input [7:0] switch;
    output [6:0] dig1, dig2, dig3, dig4;
	output [7:0] led;
    wire [11:0] digi;
    wire irq;
    wire [31:0] conba, instruct, inst, tm_data, um_data, im_ext, alu_out;
    wire [31:0] pc_id, pc_ex, pc_mem, pc_wb;
    wire [31:0] addr, wdata, data_c, data_a0_e, data_b0_e, data_b1;
    wire [31:0] data_a_id, data_b_id, data_b0, alu_out_w, mem_out;
    wire [31:0] data_e2fwd, mem_out2fwd, data_ra;
    wire [31:0] pc_if, inst_if;
    wire [1:0] reg_dst, mem2reg_ex, mem2reg_m, mem2reg_m2w;
    wire [5:0] alu_fun, alu_fun_id;
    wire [4:0] addr_w, rs_i, rt_i, rt_e, addrc_e2m, addrc_m2w, addr_e2fwd;
    wire [2:0] pc_src;
    wire [25:0] jt;
    wire branch, reg_wr, alu_src1, alu_src2;
    wire sign, mem_wr_ex, mem_rd_ex, extop, luop;
    wire tm_wr, tm_rd, um_wr, um_rd;
    wire pcifd_wr, cancel, sign_id;
    wire reg_wr_wb, reg_dst_ex, reg_wr_ex, mem_rd_m, mem_wr_m;
    wire reg_wr_m, reg_wr_m2w;
    wire flush;   
	
    
    IF if0(sysclk, reset, pcifd_wr, cancel, conba, jt, data_ra, branch, pc_src, pc_id, instruct, pc_if, inst_if);
    
    ID id0(sysclk, reset, flush, irq, instruct, pc_id, data_c, addr_w, 
       reg_wr_wb, pc_ex, inst, reg_dst, reg_wr_ex, alu_src1, 
       alu_src2, alu_fun, sign, mem_wr_ex, mem_rd_ex, mem2reg_ex, 
       pc_src, jt, data_a0_e, data_b0_e, data_b1, im_ext, conba, data_a_id, data_b_id, rs_i, rt_i, alu_fun_id, sign_id);
    
    EX ex0(sysclk, reset, pc_ex, inst, alu_src1, alu_src2, alu_fun,
       sign, reg_dst, reg_wr_ex, mem_rd_ex, mem_wr_ex, mem2reg_ex, 
       data_a0_e, data_b0_e, data_c, data_b1, im_ext, reg_wr_wb, addr_w,
       alu_out, data_b0, pc_mem, mem_rd_m, mem_wr_m, mem2reg_m, reg_wr_m, addrc_e2m, rt_e, addr_e2fwd, data_e2fwd); 
    
    MEM mem0(sysclk, reset, alu_out, data_b0, pc_mem, reg_wr_m, mem_rd_m, 
        addrc_e2m, mem_wr_m, mem2reg_m, tm_data, um_data,
        alu_out_w, pc_wb, addr, wdata, mem_out, tm_wr, tm_rd, um_wr, um_rd,
        reg_wr_m2w, mem2reg_m2w, addrc_m2w, mem_out2fwd);
    
    WB wb0(sysclk, reset, alu_out_w, pc_wb, mem_out, reg_wr_m2w, 
        mem2reg_m2w, addrc_m2w, data_c, addr_w, reg_wr_wb);
    
    fwdbj fwd(data_a_id, data_b_id, rs_i, rt_i, addr_e2fwd, addrc_e2m, 
        addrc_m2w, reg_wr_ex, reg_wr_m, reg_wr_wb, data_e2fwd, alu_out, data_c, mem_out2fwd, mem_rd_m, alu_fun_id, sign_id,
         data_ra, branch);
    
    detect dtc(mem_rd_ex, rt_e, rs_i, rt_i, flush, pcifd_wr);
    
    bj borj(pc_src, cancel, branch);
    
    Peripheral phr(reset, sysclk, tm_rd, tm_wr, addr, wdata, tm_data,
            led, switch, digi, irq);
    
    digitube_scan ds(digi, dig1, dig2, dig3, dig4);
    
    Uart uat(sysclk, reset, um_rd, um_wr, addr, wdata, um_data, uart_rx,
            uart_tx);
    
endmodule