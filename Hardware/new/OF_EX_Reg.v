`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2026 17:37:05
// Design Name: 
// Module Name: OF_EX_Reg
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
module OF_EX_Reg(
    input clk,
    input rst,
    input stall,              
    input flush,
    // Data Inputs (Strictly matching Image 3) 
    input [31:0] pc_in,               // Carried forward for branch logic
    input [31:0] branchTarget_in,     // Computed in OF stage (pc + immx)
    input [31:0] B_in,                // Output of the 'isImmediate' Mux
    input [31:0] A_in,                // op1 from Register File
    input [31:0] op2_in,              // Raw op2 from Reg File (rides to MA stage for Stores)
    input [31:0] instruction_in,      // Carried forward for opcode tracking
    // Control Bus Inputs
    // Execute Stage Signals
    input [4:0]  aluSignals_in,       
    input isRet_in,            
    input isBeq_in,            
    input isBgt_in,            
    input isUBranch_in,        
    // Memory Stage Signals
    input isLd_in,             
    input isSt_in,             
    // Writeback Stage Signals
    input isWb_in,             
    input isCall_in,           
    // Outputs 
    output reg [31:0] pc_out,
    output reg [31:0] branchTarget_out,
    output reg [31:0] B_out,
    output reg [31:0] A_out,
    output reg [31:0] op2_out,
    output reg [31:0] instruction_out,
    // Control signals for next stage
    output reg [4:0]  aluSignals_out,
    output reg isRet_out,
    output reg isBeq_out,
    output reg isBgt_out,
    output reg isUBranch_out,
    output reg isLd_out,
    output reg isSt_out,
    output reg isWb_out,
    output reg isCall_out
    );
    // For RESET, STALL and FLUSH
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            pc_out <= 0;
            branchTarget_out <= 0;
            B_out <= 0;
            A_out <= 0;
            op2_out <= 0;
            instruction_out <= 0;
            aluSignals_out <= 0;
            isRet_out <= 0;
            isBeq_out <= 0;
            isBgt_out <= 0;
            isUBranch_out <= 0;
            isLd_out <= 0;
            isSt_out <= 0;
            isWb_out <= 0;
            isCall_out <= 0;
        end
        else if(flush && ~rst)
        begin
            pc_out <= 0;
            branchTarget_out <= 0;
            B_out <= 0;
            A_out <= 0;
            op2_out <= 0;
            instruction_out <= 0;
            aluSignals_out <= 0;
            isRet_out <= 0;
            isBeq_out <= 0;
            isBgt_out <= 0;
            isUBranch_out <= 0;
            isLd_out <= 0;
            isSt_out <= 0;
            isWb_out <= 0;
            isCall_out <= 0;
        end
        else 
        begin
            if(~stall)
            begin
                pc_out <= pc_in;
                instruction_out <= instruction_in;
                isLd_out <= isLd_in;
                isSt_out <= isSt_in;
                isWb_out <= isWb_in;
                isCall_out <= isCall_in;
                isRet_out <= isRet_in;
                isBeq_out <= isBeq_in;
                isBgt_out <= isBgt_in;
                isUBranch_out <= isUBranch_in;
                aluSignals_out <= aluSignals_in;
                pc_out <= pc_in;
                branchTarget_out <= branchTarget_in;
                B_out <= B_in;
                A_out <= A_in;
                op2_out <= op2_in;
            end
        end
    end
endmodule
