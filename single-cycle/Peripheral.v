`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output reg [31:0] rdata;

output reg [7:0] led;
input [7:0] switch;
output reg [11:0] digi;
output irqout;

reg [31:0] TH, TL, num;
reg [2:0] TCON;
reg [15:0] tm;
reg [3:0] x;
wire [6:0] dig;
assign irqout = TCON[2];

initial
begin
    num = 0;
    x = 0;
    tm = 0;
    digi = 0;
end

Dig_Decode digde(x, dig);

always @(posedge clk)
begin
    tm <= tm + 1;
    case(tm[15:14])
        0: 
        begin
            digi[11:8] <= 4'b0001;
            x <= num[3:0];
        end
        1: 
        begin
            digi[11:8] <= 4'b0010; 
            x <= num[7:4];
        end
        2: 
        begin
            digi[11:8] <= 4'b0100;
            x <= num[11:8];
        end
        3: 
        begin
            digi[11:8] <= 4'b1000;
            x <= num[15:12];
        end
    endcase
end



always@(*) begin
	digi[6:0] <= dig;
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= num;
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
        num <= 0;
		led <= 0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: num <= wdata;
				default: ;
			endcase
		end
	end
end
endmodule

