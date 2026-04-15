`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 14:46:46
// Design Name: 
// Module Name: Divide
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// To build the divide and modulus blocks of SIMPLERISC
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Divide(
    input clk,
    input rst,
    input start,
    input [31:0] Dividend,
    input [31:0] Divisor,
    output reg [31:0] Quotient,
    output reg [31:0] Remainder,
    output reg done,
    output reg busy
    );    
    reg [1:0] state;
    reg [5:0] count;     
    parameter IDLE = 2'd0, COMPUTE = 2'd1, DONE = 2'd2;    
    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            state <= IDLE;
            busy <= 0;
            done <= 0;
            Quotient <= 0;
            Remainder <= 0;
            count <= 0;
        end
        else 
        begin
            case(state)
                IDLE: 
                begin
                    done <= 0; 
                    if(start) begin
                        state <= COMPUTE;
                        count <= 6'd32; 
                        busy <= 1;
                        Quotient <= Dividend;
                        Remainder <= 32'd0;
                    end
                end
                
                COMPUTE:
                begin
                    if(count == 0)
                    begin
                        busy <= 0;
                        state <= DONE;
                    end
                    else
                    begin
                        if ({Remainder[30:0], Quotient[31]} >= Divisor) begin
                            Remainder <= {Remainder[30:0], Quotient[31]} - Divisor;
                            Quotient  <= {Quotient[30:0], 1'b1};
                        end 
                        else 
                        begin
                            Remainder <= {Remainder[30:0], Quotient[31]};
                            Quotient  <= {Quotient[30:0], 1'b0};
                        end
                        count <= count - 1;
                    end
                end
                
                DONE: 
                begin
                    done <= 1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule