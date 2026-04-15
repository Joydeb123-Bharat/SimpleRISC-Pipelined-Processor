`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2026 22:43:13
// Design Name: 
// Module Name: SimpleRISC_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: The top module of the SimpleRISSC Processor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SimpleRISC_Top(
    input clk,
    input rst,
    output [31:0] probe_out
    );
    //Declearation of wires
    // hazzard wires
    wire pc_stall_w, if_of_stall_w, of_ex_stall_w;
    wire take_branch_w;
    wire [31:0] branch_target_w;
    // Stage 1
    reg  [31:0] pc_current_w;
    wire [31:0] pc_plus_4_w;
    wire [31:0] instruction_fetch_w;
    // IF-OF pipelined register outputs
    wire [31:0] if_of_pc_w;
    wire [31:0] if_of_inst_w;
    // Stage 2
    //control signals
    wire is_immediate_w;
    wire [4:0] alu_signals_w;
    wire is_ret_w, is_beq_w, is_bgt_w, is_ubranch_w;
    wire start_mul_w, start_div_w;
    wire is_ld_w, is_st_w, is_wb_w, is_call_w;
    // Register values
    wire [31:0] reg_A_w, reg_B_w;
    wire [31:0] immx_w;
    wire [31:0] operand_B_mux_w; 
    // OF-EX pipelined register outputs
    wire [31:0] of_ex_pc_w;
    wire [31:0] of_ex_branch_target_w;
    wire [31:0] of_ex_A_w, of_ex_B_w, of_ex_op2_w;
    wire [31:0] of_ex_inst_w;
    wire [4:0]  of_ex_alu_signals_w;
    wire of_ex_is_ret_w, of_ex_is_beq_w, of_ex_is_bgt_w, of_ex_is_ubranch_w;
    wire of_ex_is_ld_w, of_ex_is_st_w, of_ex_is_wb_w, of_ex_is_call_w;
    // Stage 3 wires
    wire [31:0] alu_out_w;
    wire mul_busy_w, div_busy_w;
    wire mul_done_w, div_done_w;
    // EX-MA pipelined register outputs
    wire [31:0] ex_ma_pc_w;
    wire [31:0] ex_ma_alu_out_w;
    wire [31:0] ex_ma_op2_w;
    wire [31:0] ex_ma_inst_w;
    wire ex_ma_is_ld_w, ex_ma_is_st_w, ex_ma_is_wb_w, ex_ma_is_call_w;
    // Stage 4 wires
    wire [31:0] data_mem_read_w;
    // MA-RW pipelined register output
    wire [31:0] ma_rw_pc_w;
    wire [31:0] ma_rw_alu_out_w;
    wire [31:0] ma_rw_ld_result_w;
    wire [31:0] ma_rw_inst_w;
    wire ma_rw_is_wb_w, ma_rw_is_call_w, ma_rw_is_ld_w;
    //Stage 5 wires
    wire [31:0] final_writeback_data_w;
    // For PC + 4 calculation adder
    Adder pcAdder( 
        .A(pc_current_w),
        .B(32'd4),
        .Cin(1'b0),
        .S(pc_plus_4_w),
        .Cout()
        );
    // PC
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            pc_current_w <= 0;
        else if(~pc_stall_w)
            if(take_branch_w)
                pc_current_w <= branch_target_w;
            else
                pc_current_w <= pc_plus_4_w;
    end
    // Instantiations of the module
    // Instrcution Memory
    IMEM imem(
        .clk(clk),
        .PC(pc_current_w),
        .Inst(instruction_fetch_w)
        );
     // IF-OF pipelined register
     IF_OF_Reg if_of_reg(
        .clk(clk),
        .rst(rst),
        .stall(if_of_stall_w),
        .flush(1'b0),
        .PC_in(pc_current_w),
        .Inst_in(instruction_fetch_w),
        .PC_out(if_of_pc_w),
        .Inst_out(if_of_inst_w)
        );
      // Control Unit 
    ControlUnit cu(
        .instruction(if_of_inst_w),
        .isImmediate(is_immediate_w),
        .aluSignals(alu_signals_w),
        .isRet(is_ret_w),
        .isBeq(is_beq_w),
        .isBgt(is_bgt_w),
        .isUBranch(is_ubranch_w),
        .start_mul(start_mul_w),
        .start_div(start_div_w),
        .isLd(is_ld_w),
        .isSt(is_st_w),
        .isWb(is_wb_w),
        .isCall(is_call_w)
    );
    // ImmBTaG 
    ImmBTaG imm_gen(
        .Inst(if_of_inst_w),
        .PC(if_of_pc_w),
        .T(branch_target_w),
        .Imm(immx_w)
    );
    // Register Bank
    wire [3:0] rs1_mux_w = is_ret_w ? 4'd15 : if_of_inst_w[21:18];
    wire [3:0] rs2_mux_w = is_st_w ? if_of_inst_w[25:22] : if_of_inst_w[17:14];
    RegBank reg_file(
        .clk(clk),
        .rs1(rs1_mux_w),
        .rs2(rs2_mux_w),
        .A(reg_A_w),
        .B(reg_B_w),
        .W(ma_rw_is_wb_w),               // Write enable from end of pipeline
        .rd(ma_rw_inst_w[25:22]),        // Destination reg from end of pipeline
        .WriteData(final_writeback_data_w) // Data from end of pipeline
    );
    // Operand B multiplexer
    assign operand_B_mux_w = is_immediate_w ? immx_w : reg_B_w;
    // Early Branch Unit 
    BranchUnit branch_unit(
        .A(reg_A_w),
        .B(reg_B_w),
        .is_BEQ(is_beq_w),
        .is_BGT(is_bgt_w),
        .is_UB(is_ubranch_w | is_ret_w), 
        .Take_Branch(take_branch_w)
    );
    // OF_EX_Reg pipelined register
    OF_EX_Reg of_ex_reg(
        .clk(clk),
        .rst(rst),
        .stall(of_ex_stall_w),
        .flush(1'b0),
        .pc_in(if_of_pc_w),
        .branchTarget_in(branch_target_w),
        .B_in(operand_B_mux_w),
        .A_in(reg_A_w),
        .op2_in(reg_B_w),
        .instruction_in(if_of_inst_w),
        .aluSignals_in(alu_signals_w), 
        .isRet_in(is_ret_w),
        .isBeq_in(is_beq_w),
        .isBgt_in(is_bgt_w),
        .isUBranch_in(is_ubranch_w),
        .isLd_in(is_ld_w),
        .isSt_in(is_st_w),
        .isWb_in(is_wb_w),
        .isCall_in(is_call_w),
        .pc_out(of_ex_pc_w),
        .branchTarget_out(of_ex_branch_target_w),
        .B_out(of_ex_B_w),
        .A_out(of_ex_A_w),
        .op2_out(of_ex_op2_w),
        .instruction_out(of_ex_inst_w),
        .aluSignals_out(of_ex_alu_signals_w),
        .isRet_out(of_ex_is_ret_w),
        .isBeq_out(of_ex_is_beq_w),
        .isBgt_out(of_ex_is_bgt_w),
        .isUBranch_out(of_ex_is_ubranch_w),
        .isLd_out(of_ex_is_ld_w),
        .isSt_out(of_ex_is_st_w),
        .isWb_out(of_ex_is_wb_w),
        .isCall_out(of_ex_is_call_w)
    );
    // ALU_Top
    //For the multiplication and division 
    wire ex_start_mul = (of_ex_inst_w[31:27] == 5'b00010);
    wire ex_start_div = (of_ex_inst_w[31:27] == 5'b00011);
    ALU_Top alu(
        .clk(clk),
        .rst(rst),
        .A(of_ex_A_w),
        .B(of_ex_B_w),
        .ALU_Ctrl(of_ex_alu_signals_w),
        .start_mul(ex_start_mul),
        .start_div(ex_start_div),
        .ALU_Out(alu_out_w),
        .mul_busy(mul_busy_w),
        .mul_done(mul_done_w),
        .div_busy(div_busy_w),
        .div_done(div_done_w)
    );
    // Hazard Unit 
    Hazard_Unit hazard_controller(
        .mul_busy(mul_busy_w),
        .div_busy(div_busy_w),
        .PC_Stall(pc_stall_w),
        .IF_OF_Stall(if_of_stall_w),
        .OF_EX_Stall(of_ex_stall_w)
    );
    // EX_MA_Reg 
    EX_MA_Reg ex_ma_reg(
        .clk(clk),
        .rst(rst),
        .stall(1'b0), // The back half of the pipeline never stalls in this architecture
        .pc_in(of_ex_pc_w),
        .aluResult_in(alu_out_w),
        .op2_in(of_ex_op2_w),
        .instruction_in(of_ex_inst_w),
        .isLd_in(of_ex_is_ld_w),
        .isSt_in(of_ex_is_st_w),
        .isWb_in(of_ex_is_wb_w),
        .isCall_in(of_ex_is_call_w),
        .pc_out(ex_ma_pc_w),
        .aluResult_out(ex_ma_alu_out_w),
        .op2_out(ex_ma_op2_w),
        .instruction_out(ex_ma_inst_w),
        .isLd_out(ex_ma_is_ld_w),
        .isSt_out(ex_ma_is_st_w),
        .isWb_out(ex_ma_is_wb_w),
        .isCall_out(ex_ma_is_call_w)
    );
    // Data Memory 
    DMEM dmem(
        .clk(clk),
        .isSt(ex_ma_is_st_w),
        .isLd(ex_ma_is_ld_w),
        .Add(ex_ma_alu_out_w),
        .DataIn(ex_ma_op2_w),
        .DataOut(data_mem_read_w)
    );
    // MA_RW_Reg 
    MA_RW_Reg ma_rw_reg(
        .clk(clk),
        .rst(rst),
        .stall(1'b0),
        .pc_in(ex_ma_pc_w),
        .aluResult_in(ex_ma_alu_out_w),
        .ldResult_in(data_mem_read_w),
        .instruction_in(ex_ma_inst_w),
        .isWb_in(ex_ma_is_wb_w),
        .isCall_in(ex_ma_is_call_w),
        .isLd_in(ex_ma_is_ld_w),
        .pc_out(ma_rw_pc_w),
        .aluResult_out(ma_rw_alu_out_w),
        .ldResult_out(ma_rw_ld_result_w),
        .instruction_out(ma_rw_inst_w),
        .isWb_out(ma_rw_is_wb_w),
        .isCall_out(ma_rw_is_call_w),
        .isLd_out(ma_rw_is_ld_w)
    );
    // Writeback Multiplexer 
    assign final_writeback_data_w = ma_rw_is_call_w ? (ma_rw_pc_w + 4) : 
                                    (ma_rw_is_ld_w  ? ma_rw_ld_result_w : ma_rw_alu_out_w);
    assign probe_out = final_writeback_data_w; // To help in implementation only.
endmodule
