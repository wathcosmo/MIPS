`timescale 1ns/1ps

module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;
//localparam ROM_SIZE = 32;
//reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
    if (addr[22] == 0)
    begin
        case(addr[7:2])	//Address Must Be Word Aligned.
            0: data <= 32'h08000003;
            1: data <= 32'h08000010;
            2: data <= 32'h03400008;
            3: data <= 32'h00000820;
            4: data <= 32'h3c014000;
            5: data <= 32'hac200008;
            6: data <= 32'h0000d820;
            7: data <= 32'h3c1bfff0;
            8: data <= 32'hac3b0000;
            9: data <= 32'h241bffff;
            10: data <= 32'h3c1bffff;
            11: data <= 32'hac3b0004;
            12: data <= 32'h201b0003;
            13: data <= 32'hac3b0008;
            14: data <= 32'h201f1000;
            15: data <= 32'h03e00008;
            16: data <= 32'h00000820;
            17: data <= 32'h3c014000;
            18: data <= 32'hac200008;
            19: data <= 32'h0004da00;
            20: data <= 32'h0365d820;
            21: data <= 32'hac3b0014;
            22: data <= 32'h201b0003;
            23: data <= 32'hac3b0008;
            24: data <= 32'h03400008;
           default:	data <= 32'h0800_0000;
        endcase
    end
    else
    begin
        case(addr[22:2])	
            1048576: data <= 32'h0000e820;
            1048577: data <= 32'h3c1d4000;
            1048578: data <= 32'h8fb00020;
            1048579: data <= 32'h32100008;
            1048580: data <= 32'h1200fffd;
            1048581: data <= 32'h8fa4001c;
            1048582: data <= 32'h8fb00020;
            1048583: data <= 32'h32100008;
            1048584: data <= 32'h1200fffd;
            1048585: data <= 32'h8fa5001c;
            1048586: data <= 32'h00808820;
            1048587: data <= 32'h00a09020;
            1048588: data <= 32'h12320008;
            1048589: data <= 32'h02328029;
            1048590: data <= 32'h12000003;
            1048591: data <= 32'h02209820;
            1048592: data <= 32'h02408820;
            1048593: data <= 32'h02609020;
            1048594: data <= 32'h02329022;
            1048595: data <= 32'h02328822;
            1048596: data <= 32'h0810000c;
            1048597: data <= 32'h02201020;
            1048598: data <= 32'hafa2000c;
            1048599: data <= 32'h8fb00020;
            1048600: data <= 32'h32100010;
            1048601: data <= 32'h1600fffd;
            1048602: data <= 32'hafa20018;
           default:	data <= 32'h0800_0000;
        endcase
    end
    
endmodule
