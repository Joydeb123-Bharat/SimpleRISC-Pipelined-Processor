`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 20:36:50
// Design Name: 
// Module Name: EX_MA_Reg
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

module EX_MA_Reg(
    input clk,
    input rst,
    input stall,              // 1: Freeze register
    // Data Inputs
    input [31:0] pc_in,           // Passed through
    input [31:0] aluResult_in,    // The 32-bit answer from your ALU_Top
    input [31:0] op2_in,          // The raw register data (Used if we are doing a STORE)
    input [31:0] instruction_in,  // Passed through
    // MA Stage Control Signals 
    input isLd_in,         // 1 if Load instruction
    input isSt_in,         // 1 if Store instruction  
    // WB Stage Control Signals (
    input isWb_in,         // 1 if writing to Register File
    input isCall_in,       // 1 if CALL instruction
    // Outputs
    output reg [31:0] pc_out,
    output reg [31:0] aluResult_out,
    output reg [31:0] op2_out,
    output reg [31:0] instruction_out,
    // MA stage control signals
    output reg isLd_out,
    output reg isSt_out,
    output reg isWb_out,
    output reg isCall_out
    );
    // For RESET and STALL
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            isLd_out <= 0;
            isSt_out <= 0;
            isWb_out <= 0;
            isCall_out <= 0;
            pc_out <= 0;
            aluResult_out <= 0;
            op2_out <= 0;
            instruction_out <= 0;
        end
        else
        begin
            if(~stall)
            begin
                isLd_out <= isLd_in;
                isSt_out <= isSt_in;
                isWb_out <= isWb_in;
                isCall_out <= isCall_in;
                pc_out <= pc_in;
                aluResult_out <= aluResult_in;
                op2_out <= op2_in;
                instruction_out <= instruction_in;
            end
        end
    end
endmodule
