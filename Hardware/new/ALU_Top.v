`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 22:11:16
// Design Name: 
// Module Name: ALU_Top
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
module ALU_Top(
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALU_Ctrl,   
    input start_mul,        
    input start_div,         
    output [31:0] ALU_Out,   
    output mul_busy,         
    output mul_done,         
    output div_busy,         
    output div_done         
    );
    // Declearations of the wires used
    wire [31:0] adder_out, logic_out, shift_out, mul_out, div_quotient, div_remainder;
    wire adder_cout;
    wire is_sub = (ALU_Ctrl == 5'b00001);  // For Substraction
    // Instantiations
    Adder add_inst(
        .A(A),
        .B(B),
        .Cin(is_sub),
        .S(adder_out),
        .Cout(adder_cout)
    );
    LogicCore logic_inst(
        .A(A),
        .B(B),
        .logic(ALU_Ctrl), 
        .logicOut(logic_out)
    );
    Barrel_Shifter shift_inst(
        .A(A),
        .B(B),
        .Shift_Ctrl(ALU_Ctrl),
        .Shift_Out(shift_out)
    );
    Multiplier mul_inst(
        .clk(clk),
        .rst(rst),
        .start(start_mul),
        .A(A),
        .B(B),
        .product(mul_out),
        .busy(mul_busy),
        .done(mul_done)
    );
    Divide div_inst(
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .Dividend(A),
        .Divisor(B),
        .Quotient(div_quotient),
        .Remainder(div_remainder),
        .done(div_done),
        .busy(div_busy)
    );
    // Output Multiplexer
    assign ALU_Out = (ALU_Ctrl == 5'b00000) ? adder_out : // ADD
                     (ALU_Ctrl == 5'b00001) ? adder_out : // SUB
                     (ALU_Ctrl == 5'b01001) ? B: //MOV
                     (ALU_Ctrl == 5'b00110 || ALU_Ctrl == 5'b00111 || 
                      ALU_Ctrl == 5'b01000 || ALU_Ctrl == 5'b10101) ? logic_out : // Logical operations
                     (ALU_Ctrl == 5'b01010 || ALU_Ctrl == 5'b01011 || 
                      ALU_Ctrl == 5'b01100) ? shift_out : // SHIFT
                     (ALU_Ctrl == 5'b00010) ? mul_out :  // MUL
                     (ALU_Ctrl == 5'b00011) ? div_quotient : // DIV
                     32'b0;
endmodule