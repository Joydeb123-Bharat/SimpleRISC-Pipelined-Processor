`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2026 21:09:00
// Design Name: 
// Module Name: RegBank
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// The main idea of this code is that the user must define the value of the register before using it
// So that it will behave properly else it will have garbage data in it. The main reason is to create a BRAM by remove
// rst signal and do synchronous operations. The register will working will depend on the programmer. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RegBank(
    input clk,    
    // Read Ports (OF Stage)
    input [3:0] rs1,          // Source Register 1 address
    input [3:0] rs2,          // Source Register 2 address
    output [31:0] A,          // Data out 1 (Must be wire!)
    output [31:0] B,          // Data out 2 (Must be wire!)
    // Write Ports (WB Stage) 
    input W,                  // Write Enable (isWb from WB stage)
    input [3:0] rd,           // Destination Register address (from WB stage)
    input [31:0] WriteData    // Data to write (from WB stage)
    );
    reg [31:0] RB [0:15];
    //Asynchronous read
    assign A = (rs1 == 4'b0) ? 32'b0 : ((W && (rs1 == rd)) ? WriteData : RB[rs1]);
    assign B = (rs2 == 4'b0) ? 32'b0 : ((W && (rs2 == rd)) ? WriteData : RB[rs2]);
    //Synchronous Write
    always@(posedge clk)
    begin
        if(W &&(rd !=4'b0))
            RB[rd] <= WriteData;
    end
endmodule
