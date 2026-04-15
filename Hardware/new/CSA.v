`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 12:15:16
// Design Name: 
// Module Name: CSA
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


module CSA(
    input A,
    input B,
    input Cin,
    output S,
    output Cout
    );
    wire [1:0] s,c;
    FAdder FA1(A,B,1'b0,s[0],c[0]);
    FAdder FA2(A,B,1'b1,s[1],c[1]);
    assign S = Cin ? s[1] : s[0];
    assign Cout = Cin ? c[1] : c[0];
endmodule
