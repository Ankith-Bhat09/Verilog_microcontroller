`timescale 1ns / 1ps

module control_unit_tb;

    reg [6:0] opcode;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire MemToReg;
    wire [1:0] ALUSrc;
    wire [2:0] ALUOp;

    // Instantiate the control unit
    control_unit uut (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    // Waveform dump setup
    initial begin
        $dumpfile("control_unit_waveform.vcd");  // VCD output file
        $dumpvars(0, control_unit_tb);           // Dump all signals in this module
    end

    // Stimulus
    initial begin
        opcode = 7'b0000000;  #10;
        opcode = 7'b0110011;  #10; // R-type
        opcode = 7'b0000011;  #10; // Load
        opcode = 7'b0100011;  #10; // Store
        opcode = 7'b1100011;  #10; // Branch
        opcode = 7'b0010011;  #10; // I-type
        opcode = 7'b1101111;  #10; // JAL
        opcode = 7'b1100111;  #10; // JALR
        opcode = 7'b0110111;  #10; // LUI
        opcode = 7'b0010111;  #10; // AUIPC

        $finish;
    end

endmodule
