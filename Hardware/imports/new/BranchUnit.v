`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 15:03:22
// Design Name: 
// Module Name: BranchUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: To take early branch even before going to the 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module BranchUnit(
    input [31:0] A,           // Data from Register 1
    input [31:0] B,           // Data from Register 2 
    input is_BEQ,             // 1 if current instruction is BEQ
    input is_BGT,             // 1 if current instruction is BGT
    input is_UB,              // 1 if current instruction is Unconditional Branch (B/CALL/RET)
    output Take_Branch        // 1 if we should jump, 0 if we should fetch PC+4
    );
    wire checkBGT, checkBEQ;
    wire [31:0] check;
    Adder add_inst(
        .A(A),
        .B(B),
        .Cin(1'b1),
        .S(check),
        .Cout()
    );
    assign checkBEQ = ~|check;
    assign checkBGT = (~check[31]) & (~checkBEQ);
    assign Take_Branch = (checkBEQ & is_BEQ) | (checkBGT & is_BGT) | is_UB;
endmodule