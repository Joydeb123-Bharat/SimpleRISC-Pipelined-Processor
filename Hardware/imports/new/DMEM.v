`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 12:15:48
// Design Name: 
// Module Name: DMEM
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

module DMEM(
    input clk,
    input isSt,
    input isLd,
    input [31:0] Add,
    input [31:0] DataIn,
    output [31:0] DataOut
    );
    reg [31:0] DM [0:1023];
    always@(posedge clk)
    begin
        if(isSt)
            DM[Add[11:2]] <= DataIn;
    end
    assign DataOut = isLd ? DM[Add[11:2]] : 32'b0;
endmodule