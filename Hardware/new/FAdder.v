`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 12:02:19
// Design Name: 
// Module Name: FAdder
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


module FAdder(
    input A,
    input B,
    input Cin,
    output S,
    output Cout
    );
    assign S = A ^ B ^ Cin;
    assign Cout = (A & B) | ((A ^ B) & Cin); 
endmodule
