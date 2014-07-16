module Uart(sysclk, reset, um_rd, um_wr, addr, wdata, um_data, uart_rx, uart_tx);
	input sysclk, reset, uart_rx, um_rd, um_wr;
	input [31:0] addr, wdata;
	output uart_tx;
	output reg [31:0] um_data;
	wire rx_status;
	wire tx_status;
	wire [7:0] rx_data;
	reg [7:0] tx_data; 
	reg [7:0] rx_mem;
	reg [31:0] con;
	
    
	receiver u1(sysclk, reset, uart_rx, rx_data, rx_status);
	sender u2(sysclk, reset, tx_data, con[0], tx_status, uart_tx);
	
	initial
	begin
		//con[0] = 0;  //tx_enable
		//con[3] = 0;  //rx_complete
		//con[4] = 0;  //tx_occupied
		con = 0;
		rx_mem = 0;
	end
    
    

    always @(*)
    begin    
        if (um_rd)
        begin
            case(addr[7:0])
                8'h1c: um_data <= {24'b0,rx_mem};
                8'h20: um_data <= con;
				default: um_data <= 0;
            endcase
        end
        else
            um_data <= 0;           
    end
    
	always @(posedge sysclk or negedge reset)
	begin
        if (~reset)
        begin
            con <= 0;
        end
        else 
		begin
		    con[4] <= ~tx_status;
			if (um_wr)
			begin
				if (addr[7:0] == 8'h18)
				begin
					tx_data <= wdata[7:0];
					con[0] <= 1;
				end
			end
			
			if (con[0]) con[0] <= 0;
			
			if (rx_status) 
			begin
				rx_mem <= rx_data;
				con[3] <= 1;
			end 
			
			if (um_rd && (addr[7:0] == 8'h20) && con[3]) con[3] <= 0;
		end	
	end
	
	
endmodule
