module receiver(sysclk, reset, uart_rx, rx_data, rx_status);
	input sysclk, reset, uart_rx;
	output reg [7:0] rx_data;
	output reg rx_status;
	reg clk;
	reg [7:0] cnt;
	reg [3:0] digit, cnt2;
	reg [7:0] tdata;
	reg [3:0] mem;
	
	initial
	begin
		clk = 0; 
		cnt = 0;
		cnt2 = 0;
		digit = 0;
		rx_status = 0;
		rx_data = 0;
		mem = 0;
	end
	
	always @(posedge sysclk)
	begin
		if (cnt == 161) 
		begin
			clk <= ~clk;
			cnt <= 0;
		end
		else cnt <= cnt + 1;
		
		if ((mem == 10) && (digit == 0)) rx_status <= 1;
		mem <= digit;
		
		if (rx_status == 1) rx_status <= 0;
	end
	
	always @(posedge clk or negedge reset)
	begin
		if (~reset)
		begin
			cnt2 = 0;
			digit = 0;
			rx_data = 0;
		end
		else if (digit == 0)
		begin
			if (uart_rx == 0) 
			begin
				digit <= 1;
				cnt2 <= 0;
			end
		end 
		else if (digit == 1)
		begin
		    if (cnt2 == 15) digit <= 2;
			cnt2 <= cnt2 + 1;
		end
		else if (digit == 10)
		begin
			if (cnt2 == 0) 
			begin
				rx_data <= tdata;
			end
			else if (cnt2 == 15) digit <= 0;
			cnt2 <= cnt2 + 1;
		end
		else
		begin
			if (cnt2 == 15) digit <= digit + 1;
			else if (cnt2 == 7) tdata[digit - 2] <= uart_rx;
			cnt2 <= cnt2 + 1;
		end
	end
	

endmodule
