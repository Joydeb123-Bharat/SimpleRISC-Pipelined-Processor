`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2026 17:28:49
// Design Name: 
// Module Name: Hazard_Unit
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
module Hazard_Unit(
    input mul_busy,         // From ALU_Top (Execute Stage)
    input div_busy,         // From ALU_Top (Execute Stage)
    
    output PC_Stall,        // 1: Freezes the Program Counter
    output IF_OF_Stall,     // 1: Freezes the Fetch/Operand Fetch Register
    output OF_EX_Stall      // 1: Freezes the Operand Fetch/Execute Register
    );
    wire stall;
    assign stall = (mul_busy | div_busy) ? 1'b1 : 1'b0;
    assign PC_Stall = stall;
    assign IF_OF_Stall = stall;
    assign OF_EX_Stall = stall;
endmodule