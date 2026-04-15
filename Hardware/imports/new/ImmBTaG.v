`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 11:46:29
// Design Name: 
// Module Name: ImmBTaG
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


module ImmBTaG(
    input [31:0] Inst,
    input [31:0] PC,
    output reg [31:0] T,
    output reg [31:0] Imm
    );
    always@(*)
    begin
        if(Inst[17:16] == 2'b0)
            Imm = {{16{Inst[15]}},Inst[15:0]};
        else if(Inst[17:16] == 2'b01)
            Imm = {{16{1'b0}},Inst[15:0]};
        else if(Inst[17:16] == 2'b10)
            Imm = {Inst[15:0],{16{1'b0}}};
        else
            Imm = 0;
    end
    always@(*)
    begin
        case(Inst[31:27])
            5'b10000, 5'b10001, 5'b10010: T = PC + {{3{Inst[26]}},Inst[26:0], 2'b00};
            default: T = 0;
        endcase
    end
            
endmodule
