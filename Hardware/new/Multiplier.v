`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 12:51:18
// Design Name: 
// Module Name: Multiplier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: It is based on the Serial Addition module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Multiplier(
    input clk,
    input rst,      
    input start,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] product, 
    output reg busy,
    output reg done
    );
    // Delearing the Reg and wires
    parameter IDLE = 2'b00, MULTIPLY = 2'b01, DONE = 2'b10;
    reg [1:0] state;
    reg [31:0] a, b;
    reg [5:0] count;
    wire [31:0] asum;
    wire cimmo; 
    // Adder block
    Adder mul_adder (
        .A(product), 
        .B(b), 
        .Cin(1'b0), 
        .S(asum), 
        .Cout(cimmo)
    );
    // FSM
    always @(posedge clk or posedge rst)
    begin
        if (rst) 
        begin
            state <= IDLE;
            product <= 0;
            busy <= 0;
            done <= 0;
            a <= 0;
            b <= 0;
            count <= 0;
        end
        else
        begin
            case(state)
                IDLE: // Reading
                begin
                    done <= 0;
                    if(start) 
                    begin
                        state <= MULTIPLY;
                        busy <= 1;
                        a <= A;       
                        b <= B;        
                        product <= 0;  
                        count <= 6'd32; 
                    end
                end
                MULTIPLY: // Multiplying
                begin
                    if(count == 0) 
                    begin
                        state <= DONE;
                    end
                    else
                    begin
                        if(a[0] == 1'b1) 
                            {product, a} <= {cimmo, asum, a[31:1]};
                        else 
                            {product, a} <= {1'b0, product, a[31:1]};
                        count <= count - 1;
                    end
                end
                DONE: // Done
                begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE; 
                end
                default: state <= IDLE;
            endcase
        end
    end 
endmodule