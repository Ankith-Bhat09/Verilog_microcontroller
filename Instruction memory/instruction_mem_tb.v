`timescale 1ns/1ps
`include "instruction_mem.v"
module instr_mem_tb;
reg [31:0]address;
wire [31:0]instruction;
instr_mem uut(.address(address),.instruction(instruction));

    initial begin
            $dumpfile("instr_memTB.vdc");
            $dumpvars(0,instr_mem_tb);
        address=0;
    end
    always begin
        #5 address = address + 1;
    end
endmodule