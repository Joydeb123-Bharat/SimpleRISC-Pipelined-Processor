`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 21:11:40
// Design Name: 
// Module Name: Barrel_Shifter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: For logical shifting of the operand
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Barrel_Shifter(
    input [31:0] A,
    input [31:0] B,
    input [4:0] Shift_Ctrl,
    output [31:0] Shift_Out
    );
    // Declearation of wires
    parameter LSL = 2'b00, LSR = 2'b01, ASR = 2'b10;
    wire [4:0]shift;
    assign shift = B[4:0];
    //LSR
    wire [31:0] lsr16, lsr8, lsr4, lsr2, lsr1;
    assign lsr16 = shift[4] ? {16'b0, A[31:16]}     : A;
    assign lsr8  = shift[3] ? {8'b0,  lsr16[31:8]}  : lsr16;
    assign lsr4  = shift[2] ? {4'b0,  lsr8[31:4]}   : lsr8;
    assign lsr2  = shift[1] ? {2'b0,  lsr4[31:2]}   : lsr4;
    assign lsr1  = shift[0] ? {1'b0,  lsr2[31:1]}   : lsr2;
    //LSL
    wire [31:0] lsl16, lsl8, lsl4, lsl2, lsl1;
    assign lsl16 = shift[4] ? {A[15:0], 16'b0}      : A;
    assign lsl8  = shift[3] ? {lsl16[23:0], 8'b0}   : lsl16;
    assign lsl4  = shift[2] ? {lsl8[27:0], 4'b0}    : lsl8;
    assign lsl2  = shift[1] ? {lsl4[29:0], 2'b0}    : lsl4;
    assign lsl1  = shift[0] ? {lsl2[30:0], 1'b0}    : lsl2;
    //ASR
    wire [31:0] asr16, asr8, asr4, asr2, asr1;
    assign asr16 = shift[4] ? {{16{A[31]}}, A[31:16]}    : A;
    assign asr8  = shift[3] ? {{8{A[31]}},  asr16[31:8]} : asr16;
    assign asr4  = shift[2] ? {{4{A[31]}},  asr8[31:4]}  : asr8;
    assign asr2  = shift[1] ? {{2{A[31]}},  asr4[31:2]}  : asr4;
    assign asr1  = shift[0] ? {{1{A[31]}},  asr2[31:1]}  : asr2;
    // Shifting
    assign Shift_Out = (Shift_Ctrl == 5'b01010) ? lsl1 :
                       ((Shift_Ctrl == 5'b01011) ? lsr1 :
                       ((Shift_Ctrl == 5'b01100) ? asr1 :
                       32'b0));
endmodule
