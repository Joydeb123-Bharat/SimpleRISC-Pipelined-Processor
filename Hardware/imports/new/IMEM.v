`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 12:15:48
// Design Name: 
// Module Name: IMEM
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


module IMEM(
    input clk,
    input [31:0] PC,
    output [31:0] Inst
    );
    reg [31:0] IM [0:1023];
    initial
    begin
    $readmemb("C:/Users/joyde/OneDrive/Desktop/SimpleRISC/Files/output.hex",IM);
    end
    assign Inst = IM[PC[11:2]];
endmodule
