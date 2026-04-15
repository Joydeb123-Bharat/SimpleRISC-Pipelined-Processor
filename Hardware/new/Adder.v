`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 12:07:20
// Design Name: 
// Module Name: Adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Adder(
    input [31:0] A,
    input [31:0] B,
    input Cin,
    output [31:0] S,
    output Cout
    );
    wire [31:0] b;
    assign b = B ^ ({32{Cin}});
    genvar i;
    wire [32:0] c;
    assign Cout = c[32];
    assign c[0] = Cin;
    generate
    for(i = 1; i < 33 ; i = i + 1)
    begin: CSABlock
        CSA cs(.A(A[i-1]),.B(b[i-1]),.Cin(c[i-1]),.S(S[i-1]),.Cout(c[i]));
    end
    endgenerate
endmodule
