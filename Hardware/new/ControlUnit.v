`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 21:17:48
// Design Name: 
// Module Name: ControlUnit
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

module ControlUnit(
    input [31:0] instruction,
    // OF Stage Control 
    output isImmediate,      // 1 if instruction uses an Immediate (Selects immx for B)
    // EX Stage Control 
    output [4:0] aluSignals, // Tells ALU which math operation to perform
    output isRet,            // 1 if Return from function
    output isBeq,            // 1 if Branch if Equal
    output isBgt,            // 1 if Branch if Greater Than
    output isUBranch,        // 1 if Unconditional Branch (B)
    output start_mul,        // 1 if Multiply instruction
    output start_div,        // 1 if Divide instruction
    // MA Stage Control
    output isLd,             // 1 if Load instruction
    output isSt,             // 1 if Store instruction
    // WB Stage Control 
    output isWb,             // 1 if writing back to Register File
    output isCall            // 1 if CALL instruction (Writes PC+4 to reg)
    );
    //Control logics
    assign isImmediate = instruction[26] ? 1'b1 : 1'b0;
    assign isRet = (instruction[31:27] == 5'b10100) ? 1'b1 : 1'b0;
    assign isBeq = (instruction[31:27] == 5'b10000) ? 1'b1 : 1'b0;
    assign isBgt = (instruction[31:27] == 5'b10001) ? 1'b1 : 1'b0;
    assign isUBranch = (instruction[31:27] == 5'b10010) ? 1'b1 : 1'b0;
    assign start_mul = (instruction[31:27] == 5'b00010) ? 1'b1 : 1'b0;
    assign start_div = (instruction[31:27] == 5'b00011) ? 1'b1 : 1'b0;
    assign isLd = (instruction[31:27] == 5'b01110) ? 1'b1 : 1'b0;
    assign isSt = (instruction[31:27] == 5'b01111) ? 1'b1 : 1'b0;
    assign isCall = (instruction[31:27] == 5'b10011) ? 1'b1 : 1'b0;
    assign isWb = ~(isSt | isBeq | isBgt | isUBranch | isRet);
    assign aluSignals = instruction[31:27];
endmodule
