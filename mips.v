module MIPS(clk, reset, switch, led, digi, uart_rx, uart_tx);
    input clk, reset, uart_rx;
    output uart_tx;
    input [7:0] switch;
    output [7:0] led;
    output [11:0] digi;
    wire irq;
    wire [31:0] conba, data_a, instruct, pc, tm_data, um_data;
    wire [31:0] addr, wdata;
    wire [1:0] reg_dst, mem2reg;
    wire [5:0] alu_fun;
    wire branch, reg_wr, alu_src1, alu_src2;
    wire sign, mem_wr, mem_rd, extop, luop;
    wire tm_wr, tm_rd, um_wr, um_rd;
    
    Ctrl ctl(clk, irq, conba, data_a, branch,
            instruct, pc, reg_dst, reg_wr, alu_src1, alu_src2,
            alu_fun, sign, mem_wr, mem_rd, mem2reg, extop, luop);
    
    Exc  ex(clk, reset, instruct, pc, tm_data, um_data,
            reg_dst, reg_wr, alu_src1, alu_src2, alu_fun,
             sign, mem_wr, mem_rd, mem2reg, extop, luop,
            conba, data_a, branch, addr, wdata,
            tm_wr, tm_rd, um_wr, um_rd
            );
    
    Peripheral phr(reset, clk, tm_rd, tm_wr, addr, wdata, tm_data,
            led, switch, digi, irq);
    
    Uart ut(clk, reset, um_rd, um_wr, addr, wdata, um_data, uart_rx,
            uart_tx);
    
endmodule
