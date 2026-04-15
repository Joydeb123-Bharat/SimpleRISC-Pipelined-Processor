`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 20:52:02
// Design Name: 
// Module Name: MA_RW_Reg
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

module MA_RW_Reg(
    input clk,
    input rst,
    input stall,              // 1: Freeze register
    // Data Inputs
    input [31:0] pc_in,           // Passed through
    input [31:0] aluResult_in,    // Passed through
    input [31:0] ldResult_in,     // The data just read from Data Memory
    input [31:0] instruction_in,  // Passed through
    // WB Stage Control Signals 
    input        isWb_in,         // 1 if writing to Register File
    input        isCall_in,       // 1 if CALL instruction (Selects PC+4 to write)
    input        isLd_in,         // 1 if Load instruction (Selects ldResult to write)
    // Outputs 
    output reg [31:0] pc_out,
    output reg [31:0] aluResult_out,
    output reg [31:0] ldResult_out,
    output reg [31:0] instruction_out,
    output reg isWb_out,
    output reg isCall_out,
    output reg isLd_out
    );
    // For RESET and STALL
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            pc_out <= 0;
            aluResult_out <= 0;
            ldResult_out <= 0;
            instruction_out <= 0;
            isWb_out <= 0;
            isCall_out <= 0;
            isLd_out <= 0;
        end
        else
        begin
            if(~stall)
            begin
                pc_out <= pc_in;
                aluResult_out <= aluResult_in;
                ldResult_out <= ldResult_in;
                instruction_out <= instruction_in;
                isWb_out <= isWb_in;
                isCall_out <= isCall_in;
                isLd_out <= isLd_in;
            end
        end
    end    
endmodule
