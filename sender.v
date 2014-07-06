module sender(sysclk, reset, tx_data, tx_en, tx_status, uart_tx);
	input sysclk, reset, tx_en;
	input [7:0] tx_data;
	output reg tx_status, uart_tx;
	reg clk;
	reg [11:0] cnt;
	reg [3:0] cnt2;
	reg enb;
	
	initial
	begin
		clk = 0;
		cnt = 0;
		tx_status = 1;
		uart_tx = 1;
		cnt2 = 9;
		enb = 0;
	end
	
	always @(posedge sysclk)
	begin
		if (cnt == 2603)
		begin
			cnt <= 0;
			clk <= ~clk;
		end
		else cnt <= cnt + 1;
		if (tx_en) enb <= 1;
		if (cnt2 == 0) enb <= 0;
	end
	
	always @(posedge clk or negedge reset)
	begin
		if (~reset)
		begin
			tx_status <= 1;
			uart_tx <= 1;
		end
		else if (enb)
		begin
			cnt2 <= 0;
			uart_tx <= 0;
			tx_status <= 0;
		end
		else if (cnt2 < 8)
		begin
			uart_tx <= tx_data[cnt2];
			cnt2 <= cnt2 + 1;
		end
		else if (cnt2 == 8)
		begin
			uart_tx <= 1;
			cnt2 <= 9;
		end
		else tx_status <= 1;	
	end
	
endmodule
