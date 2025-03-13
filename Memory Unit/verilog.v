`timescale 1ns / 1ps

module data_memory (
    input clk,
    input mem_read, mem_write,
    input [1:0] mem_size,  // 00 = byte, 01 = half-word, 10 = word
    input [31:0] address, write_data,
    output reg [31:0] read_data
);

    // Memory array (256 words = 1024 bytes)
    reg [31:0] memory [0:255];

    // Load memory from a HEX file
    initial begin
        $readmemh("data_memory.hex", memory);
    end

    // Asynchronous Read Operation
    always @(*) begin
        if (mem_read) begin
            case (mem_size)
                2'b00: read_data = {24'b0, memory[address[9:2]][(address[1] ? 15:8) : (address[0] ? 7:0)]}; // Byte load
                2'b01: read_data = {16'b0, memory[address[9:2]][(address[1] ? 31:16) : 15:0]}; // Half-word load
                2'b10: read_data = memory[address[9:2]]; // Word load
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
    // Synchronous Write Operation
    always @(posedge clk) begin
        if (mem_write) begin
            case (mem_size)
                2'b00: memory[address[9:2]][(address[1] ? 15:8) : (address[0] ? 7:0)] <= write_data[7:0]; // Byte store
                2'b01: memory[address[9:2]][(address[1] ? 31:16) : 15:0] <= write_data[15:0]; // Half-word store
                2'b10: memory[address[9:2]] <= write_data; // Word store
            endcase
        end
    end
endmodule
