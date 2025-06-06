`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2025 19:14:04
module ALU_tb;
  parameter WIDTH = 8;
  parameter C_WIDTH = 4;

  reg [WIDTH-1:0] OPA, OPB;
  reg CLK, RST, CE, MODE, CIN;
  reg [1:0] IN_VALID;
  reg [C_WIDTH-1:0] CMD;
  wire [WIDTH:0] RES;
  wire [(2*WIDTH-1):0] MUL_RES;
  wire COUT, OFLOW, G, E, L, ERR;

  // Instantiate the ALU module
  Alu_f #(.WIDTH(WIDTH), .C_WIDTH(C_WIDTH)) alu_inst (
    .OPA(OPA), .OPB(OPB), .CIN(CIN), .CLK(CLK), .RST(RST), .IN_VALID(IN_VALID),
    .CMD(CMD), .CE(CE), .MODE(MODE), .COUT(COUT), .OFLOW(OFLOW), .RES(RES),
    .G(G), .E(E), .L(L), .ERR(ERR), .MUL_RES(MUL_RES)
  );

  // Clock generation
  always #5 CLK = ~CLK;

  initial begin
    // Initialize signals
    CLK = 0;
    RST = 1; CE = 1; MODE = 1; CIN = 0;
    IN_VALID = 2'b11; OPA = 8'b00001111; OPB = 8'b00000010; 

    // Apply Reset
    #10 RST = 0;
    
    // Testing all ALU operations
    CMD = 4'b0000; #10; #15;$display("CMD: ADD, RES: %b, COUT: %b, ERR: %b", RES, COUT, ERR);
    CMD = 4'b0001; #10; #15;$display("CMD: SUB, RES: %b, OFLOW: %b, ERR: %b", RES, OFLOW, ERR);
    CMD = 4'b0010; CIN = 1;#10; #15; $display("CMD: ADD with Carry, RES: %b, COUT: %b, ERR: %b", RES, COUT, ERR);
    CMD = 4'b0011; CIN = 1;#10; #15; $display("CMD: SUB with Borrow, RES: %b, OFLOW: %b, ERR: %b", RES, OFLOW, ERR);
    CMD = 4'b0100; #10; #15; $display("CMD: INC OPA, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0101; #10; #15; $display("CMD: DEC OPA, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0110; #10; #15; $display("CMD: INC OPB, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0111; #10; #15; $display("CMD: DEC OPB, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1000; #10; #15; $display("CMD: Compare, G: %b, E: %b, L: %b, ERR: %b", G, E, L, ERR);
    CMD = 4'b1001; #10; #25; $display("CMD: MUL OPA * OPB, MUL_RES: %b, ERR: %b", MUL_RES, ERR);
    CMD = 4'b1001; IN_VALID = 2'b01; #10; #25; $display("CMD: MUL OPA * OPB, MUL_RES: %b, ERR: %b", MUL_RES, ERR);
    CMD = 4'b1010; IN_VALID = 2'b11; #10; #25; $display("CMD: MUL OPA * OPB_T, MUL_RES: %b, ERR: %b", MUL_RES, ERR);
    CMD = 4'b1010; IN_VALID = 2'b10; #10; #25; $display("CMD: MUL OPA * OPB_T, MUL_RES: %b, ERR: %b", MUL_RES, ERR);
    CMD = 4'b1011; IN_VALID = 2'b11; #10; #15; $display("CMD: Signed ADD, RES: %b, COUT: %b, OFLOW: %b, ERR: %b", RES, COUT, OFLOW, ERR);
    CMD = 4'b1011; IN_VALID = 2'b11; OPA = 8'b11110001; OPB = 8'b11110001; #10; #15; $display("CMD: Signed ADD, RES: %b, COUT: %b, OFLOW: %b, ERR: %b", RES, COUT, OFLOW, ERR);
    CMD = 4'b1100; OPA = 8'b00001111; OPB = 8'b00000010; CE = 1'b0; #10; #15; $display("CMD: Signed SUB, RES: %b, COUT: %b, OFLOW: %b, ERR: %b", RES, COUT, OFLOW, ERR);
    CMD = 4'b1100; OPA = 8'b11110001; OPB = 8'b11110001; CE=1'b1; #10; #15; $display("CMD: Signed SUB, RES: %b, COUT: %b, OFLOW: %b, ERR: %b", RES, COUT, OFLOW, ERR);
    CMD = 4'b1100; OPA = 8'b01010111; OPB = 8'b10101010; #10; #15; $display("CMD: Signed SUB, RES: %b, COUT: %b, OFLOW: %b, ERR: %b", RES, COUT, OFLOW, ERR);
    CMD = 4'b1110; #10; #15;
    CMD = 4'b0000; MODE = 0; #10; #15; $display("CMD: Bitwise AND, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0001; MODE = 0; #10; #15; $display("CMD: Bitwise NAND, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0010; MODE = 0; #10; #15; $display("CMD: Bitwise OR, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0011; MODE = 0; #10; #15; $display("CMD: Bitwise NOR, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0100; MODE = 0; #10; #15; $display("CMD: Bitwise XOR, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0101; MODE = 0; #10; #15; $display("CMD: Bitwise XNOR, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0110; MODE = 0;  #10; #15; $display("CMD: Bitwise NOT (OPA), RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b0111; MODE = 0;  #10; #15; $display("CMD: Bitwise NOT (OPB), RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1000; MODE = 0;  #10; #15; $display("CMD: Shift Right OPA, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1001; MODE = 0;  #10; #15; $display("CMD: Shift Left OPA, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1010; MODE = 0;  #10; #15; $display("CMD: Shift Right OPB, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1011; MODE = 0;  #10; #15; $display("CMD: Shift Left OPB, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1100; MODE = 0;  #10; #15; $display("CMD: Rotate Left, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1100; MODE = 0; IN_VALID = 2'b10;  #10; #15; $display("CMD: Rotate Left, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1100; MODE = 0; OPB = 8'b10000010; IN_VALID = 2'b11; #10; #15; $display("CMD: Rotate Left, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1101; MODE = 0; OPB = 8'b00000010; #10; #15; $display("CMD: Rotate Right, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1101; MODE = 0; OPB = 8'b00000010; IN_VALID = 2'b01; #10; #15; $display("CMD: Rotate Right, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1101; MODE = 0; OPB = 8'b10000010; IN_VALID = 2'b11; #10; #15; $display("CMD: Rotate Right, RES: %b, ERR: %b", RES, ERR);
    CMD = 4'b1111; MODE = 0; OPB = 8'b10000010; IN_VALID = 2'b11; #10; #15;
    $monitor("%t,OPA:%b,OPB:%b,CE:%b,MODE:%b,CIN:%b,IN_VALID:%b,CMD:%b,RES:%b,MUL_RES:%b,G:%b,L:%b,E:%b,COUT:%b,OFLOW:%b,ERR:%b",$time,OPA,OPB,CE,MODE,CIN,IN_VALID,CMD,RES,MUL_RES,G,L,E,COUT,OFLOW,ERR);
    #50 $finish;
  end
endmodule

