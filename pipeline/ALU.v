// ALU
module ALU(
  input  [31:0] A,
  input  [31:0] B,
  input  [5:0] ALUFun,
  input  Sign,
  output reg [31:0] Z
);
    wire [31:0] z, z_add, z_sub, z_and, z_or, z_xor, z_nor, z_sll;
    wire [31:0] z_srl, z_sra, z_eq, z_neq, z_lt, z_lez, z_gez, z_gtz;
    wire v_add, n_add, v_sub, n_sub;

    ADD add(A, B, Sign, z_add, v_add, n_add);
    SUB sub(A, B, Sign, z_sub, v_sub, n_sub);
    AND0 and0(A, B, z_and);              
    OR0 or0(A, B, z_or);                
    XOR0 xor0(A, B, z_xor);              
    NOR0 nor0(A, B, z_nor);              
    ASSIGN assign0(A, B, z);        
    SLL sll(A, B, z_sll);               
    SRL srl(A, B, z_srl);               
    SRA sra(A, B, z_sra);         
    EQ eq(A, B, Sign, z_eq);           
    NEQ neq(A, B, Sign, z_neq);        
    LT lt(A, B, Sign, z_lt);           
    LEZ lez(A, Sign, z_lez);            
    GEZ gez(A, Sign, z_gez);            
    GTZ gtz(A, Sign, z_gtz); 
    
    
  always @(*)
  begin
    case (ALUFun)
        6'b000000: Z <= z_add;
        6'b000001: Z <= z_sub;
        6'b011000: Z <= z_and;
        6'b011110: Z <= z_or;
        6'b010110: Z <= z_xor;
        6'b010001: Z <= z_nor;
        6'b011010: Z <= z;
        6'b100000: Z <= z_sll;
        6'b100001: Z <= z_srl;
        6'b100011: Z <= z_sra;
        6'b110011: Z <= z_eq;
        6'b110001: Z <= z_neq;
        6'b110101: Z <= z_lt;
        6'b111101: Z <= z_lez;
        6'b111001: Z <= z_gez;
        6'b111111: Z <= z_gtz;
		default: Z <= 0;
    endcase
  end

endmodule





// AND
module AND0(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z <= A&B;
  end
endmodule


// OR
module OR0(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z <= A|B;
  end
endmodule


// XOR
module XOR0(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z <= A^B;
  end
endmodule


// NOR
module NOR0(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z <= ~(A|B);
  end
endmodule


// ASSIGN
module ASSIGN(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z <= A;
  end
endmodule              


// SLL
module SLL(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
    Z = B<<A[4:0];
  end
endmodule


// SRL
module SRL(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
always @(*)
begin
  Z = B>>A[4:0];
end
endmodule 
 

// SRA
module SRA(
  input  [31:0] A,
  input  [31:0] B,
  output reg [31:0] Z
);
  always @(*)
  begin
      Z = B>>>A[4:0];
  end
endmodule


// EQ
module EQ(
  input  [31:0] A,
  input  [31:0] B,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, B, Sign, sub, V, N);
  always @(*)
  begin 
  if (sub==0)
      Z <= 1;
  else
      Z <= 0;
  end
endmodule


// NEQ
module NEQ(
  input  [31:0] A,
  input  [31:0] B,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, B, Sign, sub, V, N);
  always @(*)
  begin  
  if (sub==0)
      Z <= 0;
  else
      Z <= 1;
  end
endmodule


// LT
module LT(
  input  [31:0] A,
  input  [31:0] B,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, B, Sign, sub, V, N);
  always @(*)
  begin  
  if (N > 0)
      Z <= 1;
  else
      Z <= 0;
  end
endmodule


// LEZ
module LEZ(
  input  [31:0] A,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, 0, Sign, sub, V, N);
  always @(*)
  begin  
  if (sub==0 || N > 0)
      Z <= 1;
  else
      Z <= 0;
  end
endmodule


// GEZ
module GEZ(
  input  [31:0] A,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, 0, Sign, sub, V, N);
  always @(*)
  begin  
  if (sub==0 || N == 0)
      Z <= 1;
  else
      Z <= 0;
  end
endmodule


// GTZ
module GTZ(
  input  [31:0] A,
  input  Sign,
  output reg [31:0] Z
);
  wire [31:0] sub;
  wire V;
  wire N;

  SUB sub1(A, 0, Sign, sub, V, N);
  always @(*)
  begin  
  if (N == 0)
      Z <= 1;
  else
      Z <= 0;
  end
endmodule



// ADD
module ADD(
  input  [31:0] A, 
  input  [31:0] B,
  input  Sign, 
  output reg [31:0] Z,
  output reg V,
  output reg N
);
  
  reg [32:0] a;
  reg [32:0] b;
  reg [32:0] z;

  always @(*)
  begin
    if (Sign == 0)
    begin
      a <= A;
      b <= B;
      z <= a+b;
      Z <= z;
      V <= z[32];
	  N <= 0;
    end
    else
    begin
	  a <= 0;
	  b <= 0;
	  z <= 0;
      Z <= A+B;
      
      // both positive
      if (A[31]||B[31] == 0)
		begin
		  N <= 0;
          V <= Z[31];
	    end
      
      // both negative
      else if (A[31]&&B[31])
        begin
          N <= 1;
          V <= ~Z[31];
        end

      // one positive, the other negative
      else 
		begin
          N <= Z[31];
		  V <= 0;
		end
     end
  end
     
endmodule



// SUB
module SUB(
  input  [31:0] A, 
  input  [31:0] B,
  input  Sign, 
  output reg [31:0] Z,
  output reg V,
  output reg N
);
  
  reg [31:0] B1;
  reg [32:0] a;
  reg [32:0] b;
  reg [32:0] z;
  
  always @(*)
    begin
	  a <= 0;
	  b <= 0;
	  z <= 0;
	  B1 <= 0;
	  V <= 0;
	  N <= 0;
	
      if (Sign == 0)
      begin
        a <= A;
        B1 <= ~B;
        b <= B1+32'b1;
        z <= a+b;   
        
		Z <= z[31:0];
        V <= !z[32];
        N <= !z[32];
      end
     
      else
      begin
        B1 <= ~B + 32'b1;
        Z <= A+B1;
 
        // A negative, B positive 
        if (A[31]==1 && B[31]==0)
        begin
          N <= 1;
          V <= ~Z[31];
        end
        
        // A positive, B negative
        else if (A[31]==0 && B[31]==1)
        begin
            V <= Z[31]; 
            N <= 0;
        end
        

        // both positive or both negative
        else 
		begin
            N <= Z[31]; 
		end
      end
    end
 
endmodule
   	