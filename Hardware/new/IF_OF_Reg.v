`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 23:03:16
// Design Name: 
// Module Name: IF_OF_Reg
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
module IF_OF_Reg(
    input clk,
    input rst,
    input stall,              // 1: Freeze register (keep current outputs)
    input flush,              // 1: Clear register (insert NOP)
    input [31:0] PC_in,       // PC from Fetch stage
    input [31:0] Inst_in,     // Instruction fetched from IMEM
    output reg [31:0] PC_out, 
    output reg [31:0] Inst_out
    );
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            PC_out <= 0;
            Inst_out <= 0;
        end
        else if(~rst && flush)
        begin
            PC_out <= 0;
            Inst_out <= 0;
        end
        else if(~stall)
        begin
            PC_out <= PC_in;
            Inst_out <= Inst_in;
        end
        else if(stall)
        begin
            PC_out <= PC_out;
            Inst_out <= Inst_out;
        end
    end
    
endmodule