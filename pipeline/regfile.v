
module RegFile (reset,clk,addr1,data1,addr2,data2,wr,addr3,data3);
input reset,clk;
input wr;
input [4:0] addr1,addr2,addr3;
output reg [31:0] data1,data2;
input [31:0] data3;

reg [31:0] RF_DATA[31:1];
integer i;

    always @(*) //$0 MUST be all zeros
    begin
        if (addr1 == 5'b0) data1 <= 32'b0;
        else if (addr1 == addr3) data1 <= data3;
        else data1 <= RF_DATA[addr1];
        
        if (addr2 == 5'b0) data2 <= 32'b0;
        else if (addr2 == addr3) data2 <= data3;
        else data2 <= RF_DATA[addr2];
    end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		for(i=1;i<32;i=i+1) RF_DATA[i]<=32'b0;
	end
	else begin
		if (wr && addr3) RF_DATA[addr3] <= data3;
	end
end
endmodule
