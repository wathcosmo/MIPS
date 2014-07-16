module Dig_Decode(x, hex);
	input [3:0] x;
	output reg [6:0] hex;
	
	always @(*)
	begin
		case (x)
		4'd0: hex = 7'b1000000;
		4'd1: hex = 7'b1111001;
		4'd2: hex = 7'b0100100;
		4'd3: hex = 7'b0110000;
		4'd4: hex = 7'b0011001;
		4'd5: hex = 7'b0010010;
		4'd6: hex = 7'b0000010;
		4'd7: hex = 7'b1111000;
		4'd8: hex = 7'b0000000;
		4'd9: hex = 7'b0010000;
        4'ha: hex = 7'b0001000;
        4'hb: hex = 7'b0000011;
        4'hc: hex = 7'b1000110;
        4'hd: hex = 7'b0100001;
        4'he: hex = 7'b0000110;
        4'hf: hex = 7'b0001110;
		endcase
	end
endmodule
