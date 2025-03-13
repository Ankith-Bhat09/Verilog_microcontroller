`timescale 1ns / 1ps
module data_memory (
    input clk,
    input mem_read, mem_write,
    input [31:0] address, write_data,
    output reg [31:0] read_data
);
    // Memory array (256 words = 1024 bytes)
    reg [31:0] memory [0:255];
    // Load memory contents from a HEX file during initialization
    initial begin
        $readmemh("data_memory.hex", memory);
    end
    // Asynchronous Read Operation
    always @(*) begin
        if (mem_read)
            read_data = memory[address[9:2]]; // Word-aligned access
        else
            read_data = 32'b0;
    end
    // Synchronous Write Operation (on clock edge)
    always @(posedge clk) begin
        if (mem_write)
            memory[address[9:2]] <= write_data;
    end
endmodule
