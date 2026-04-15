`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 12:37:31
// Design Name: 
// Module Name: LogicCore
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


module LogicCore(
    input [31:0] A,
    input [31:0] B,
    input [4:0] logic,
    output [31:0] logicOut
    );
    assign logicOut = (logic == 5'b00110) ? (A & B) : 
                      (logic == 5'b00111) ? (A | B) :  
                      (logic == 5'b01000) ? (~A) :     
                      (logic == 5'b10101) ? (A ^ B) :  
                      32'b0;
endmodule
