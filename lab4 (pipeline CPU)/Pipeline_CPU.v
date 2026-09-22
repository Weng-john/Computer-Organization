`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"
`include "Pipe_Reg.v"

module Pipeline_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  /*your code here*/
  //Internal Signles
  wire [32-1:0] pc_in;
  wire [32-1:0] pc_out;
  wire [32-1:0] pc_add;
  wire [32-1:0] pc_branch;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instr;
  wire RegWrite;
  wire [2-1:0] ALUOp;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire BranchType;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] WriteData;
  wire [32-1:0] RSdata;
  wire [32-1:0] RTdata;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;
  wire sftVariable;
  wire leftRight;
  wire [32-1:0] extendData;
  wire [32-1:0] zeroData;
  wire [32-1:0] ALUsrcData;
  wire [32-1:0] ALUresult;
  wire zero;
  wire overflow;
  wire [5-1:0] shamt;
  wire [32-1:0] sftResult;
  wire [32-1:0] RegData;
  wire [32-1:0] MemData;
  wire [32-1:0] DataNoJal;

//modules
  // IF stage
    Mux2to1 #(
        .size(32)
    ) Mux_jump (
        .data0_i (pc_no_jump),
        .data1_i ({IDEX_pc_add[31:28], IDEX_instr[25:0], 2'b00}),
        .select_i(IDEX_Jump),
        .data_o  (pc_temp)
    );

    Mux2to1 #(
        .size(32)
    ) Mux_jr (
        .data0_i (pc_temp),
        .data1_i (IDEX_RSdata),
        .select_i(JRsrc),
        .data_o  (pc_in)
    );

    Program_Counter PC (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .pc_in_i(pc_in),
        .pc_out_o(pc_out)
    );

    Adder Adder1 (
        .src1_i(pc_out),
        .src2_i(32'd4),
        .sum_o (pc_add)
    );

    Instr_Memory IM (
        .pc_addr_i(pc_out),
        .instr_o  (instr)
    );

  // IF/ID pipeline
    wire [31:0] IFID_pc_add, IFID_instr; 
    Pipe_Reg #(.size(64)) IF_ID_pipeline (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({pc_add, instr}),
        .data_o({IFID_pc_add, IFID_instr})
    );

  // ID stage
    Decoder Decoder (
        .instr_op_i(IFID_instr[31:26]),
        .RegWrite_o(RegWrite),
        .ALUOp_o(ALUOp),
        .ALUSrc_o(ALUSrc),
        .RegDst_o(RegDst),
        .Jump_o(Jump),
        .Branch_o(Branch),
        .BranchType_o(BranchType),
        .MemRead_o(MemRead),
        .MemWrite_o(MemWrite),
        .MemtoReg_o(MemtoReg)
    );

    Reg_File RF (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .RSaddr_i(IFID_instr[25:21]),
        .RTaddr_i(IFID_instr[20:16]),
        .RDaddr_i(MEMWB_RegAddr),
        .RDdata_i(WriteData),
        .RegWrite_i(MEMWB_RegWrite & (~JRsrc)),
        .RSdata_o(RSdata),
        .RTdata_o(RTdata)
    );

    Sign_Extend SE (
        .data_i(IFID_instr[15:0]),
        .data_o(extendData)
    );
  
    Zero_Filled ZF (
        .data_i(IFID_instr[15:0]),
        .data_o(zeroData)
    );

  // ID/EX pipeline
    wire [1:0] IDEX_ALUOp;
    wire IDEX_ALUSrc, IDEX_RegDst, IDEX_Jump, IDEX_Branch, IDEX_BranchType, IDEX_MemRead, IDEX_MemWrite, IDEX_MemtoReg, IDEX_RegWrite;
    Pipe_Reg #(.size(11)) ID_EX_Control (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({ALUOp, ALUSrc, RegDst, Jump, Branch, BranchType, MemRead, MemWrite, MemtoReg, RegWrite}),
        .data_o({IDEX_ALUOp, IDEX_ALUSrc, IDEX_RegDst, IDEX_Jump, IDEX_Branch, IDEX_BranchType, IDEX_MemRead, IDEX_MemWrite, IDEX_MemtoReg, IDEX_RegWrite})
    );

    wire [31:0] IDEX_pc_add, IDEX_RSdata, IDEX_RTdata, IDEX_extendData, IDEX_zeroData, IDEX_instr;
    Pipe_Reg #(.size(192)) ID_EX_Data (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({IFID_pc_add, RSdata, RTdata, extendData, zeroData, IFID_instr}),
        .data_o({IDEX_pc_add, IDEX_RSdata, IDEX_RTdata, IDEX_extendData, IDEX_zeroData, IDEX_instr})
    );

  // EX stage
    Adder Adder2 (
        .src1_i(IDEX_pc_add),
        .src2_i({IDEX_extendData[29:0], 2'b00}),
        .sum_o (pc_branch)
    );

    Mux2to1 #(
        .size(32)
    ) ALU_src2Src (
        .data0_i (IDEX_RTdata),
        .data1_i (IDEX_extendData),
        .select_i(IDEX_ALUSrc),
        .data_o  (ALUsrcData)
    );
  
    ALU ALU (
        .aluSrc1(IDEX_RSdata),
        .aluSrc2(ALUsrcData),
        .ALU_operation_i(ALU_operation),
        .result(ALUresult),
        .zero(zero),
        .overflow(overflow)
    );

    Mux2to1 #(
        .size(5)
    ) Shamt_Src (
        .data0_i (IDEX_instr[10:6]),
        .data1_i (IDEX_RSdata[4:0]),
        .select_i(sftVariable),
        .data_o  (shamt)
    );

    Shifter shifter (
        .leftRight(leftRight),
        .shamt(shamt),
        .sftSrc(ALUsrcData),
        .result(sftResult)
    );

    ALU_Ctrl AC (
        .funct_i(IDEX_instr[5:0]),
        .ALUOp_i(IDEX_ALUOp),
        .ALU_operation_o(ALU_operation),
        .FURslt_o(FURslt),
        .sftVariable_o(sftVariable),
        .leftRight_o(leftRight),
        .JRsrc_o(JRsrc)
    );

    Mux3to1 #(
        .size(32)
    ) RDdata_Source (
        .data0_i (ALUresult),
        .data1_i (sftResult),
        .data2_i (IDEX_zeroData),
        .select_i(FURslt),
        .data_o  (RegData)
    );

    Mux2to1 #(
        .size(5)
    ) Mux_RS_RT (
        .data0_i (IDEX_instr[20:16]),
        .data1_i (IDEX_instr[15:11]),
        .select_i(IDEX_RegDst),
        .data_o  (RegAddrTemp)
    );

    Mux2to1 #(
        .size(5)
    ) Mux_Write_Reg (
        .data0_i (RegAddrTemp),
        .data1_i (5'd31),
        .select_i(IDEX_Jump),
        .data_o  (RegAddr)
    );

  // EX/MEM pipeline
    wire EXMEM_Branch, EXMEM_BranchType, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg, EXMEM_RegWrite;
    Pipe_Reg #(.size(6)) EX_MEM_Control (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({IDEX_Branch, IDEX_BranchType, IDEX_MemRead, IDEX_MemWrite, IDEX_MemtoReg, IDEX_RegWrite}),
        .data_o({EXMEM_Branch, EXMEM_BranchType, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg, EXMEM_RegWrite})
    );

    wire [31:0] EXMEM_pc_branch, EXMEM_RegData, EXMEM_RTdata;
    wire [4:0] EXMEM_RegAddr;
    Pipe_Reg #(.size(101)) EX_MEM_Data (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({pc_branch, RegData, IDEX_RTdata, RegAddr}),
        .data_o({EXMEM_pc_branch, EXMEM_RegData, EXMEM_RTdata, EXMEM_RegAddr})
    );

  // MEM stage
    Data_Memory DM (
        .clk_i(clk_i),
        .addr_i(EXMEM_RegData),
        .data_i(EXMEM_RTdata),
        .MemRead_i(EXMEM_MemRead),
        .MemWrite_i(EXMEM_MemWrite),
        .data_o(MemData)
    );

    Mux2to1 #(
        .size(32)
    ) Mux_branch (
        .data0_i (pc_add),
        .data1_i (EXMEM_pc_branch),
        .select_i(EXMEM_Branch & (~EXMEM_BranchType ^ zero)),
        .data_o  (pc_no_jump)
    );

  // MEM/WB pipeline
    wire MEMWB_MemtoReg, MEMWB_RegWrite;
    Pipe_Reg #(.size(2)) MEM_WB_Control (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({EXMEM_MemtoReg, EXMEM_RegWrite}),
        .data_o({MEMWB_MemtoReg, MEMWB_RegWrite})
    );

    wire [31:0] MEMWB_RegData, MEMWB_MemData;
    wire [4:0] MEMWB_RegAddr;
    Pipe_Reg #(.size(69)) MEM_WB_Data (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({EXMEM_RegData, MemData, EXMEM_RegAddr}),
        .data_o({MEMWB_RegData, MEMWB_MemData, MEMWB_RegAddr})
    );

  // WE stage
    Mux2to1 #(
        .size(32)
    ) Mux_Read_Mem (
        .data0_i (MEMWB_RegData),
        .data1_i (MEMWB_MemData),
        .select_i(MEMWB_MemtoReg),
        .data_o  (DataNoJal)
    );

    Mux2to1 #(
        .size(32)
    ) Mux_Jal (
        .data0_i (DataNoJal),
        .data1_i (IDEX_pc_add),
        .select_i(IDEX_Jump),
        .data_o  (WriteData)
    );
endmodule