`timescale 1ns / 1ps
module memory_tb;
    // Testbench signals
    reg clk, mem_read, mem_write;
    reg [31:0] instr_address, data_address, write_data;
    wire [31:0] instruction, read_data;
    // Instantiate the memory system
    memory_system uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .instr_address(instr_address),
        .data_address(data_address),
        .write_data(write_data),
        .instruction(instruction),
        .read_data(read_data)
    );
    // Clock generation (10ns cycle)
    always #5 clk = ~clk;
    // Memory initialization
    reg [31:0] instruction_memory [0:127]; // Instruction storage
    reg [31:0] data_memory [0:127]; // Data storage
    initial begin
        // Load instructions from input.txt
        $readmemh("input.txt", instruction_memory);
        // Initialize signals
        clk = 0;
        mem_read = 0;
        mem_write = 0;
        instr_address = 0;
        data_address = 0;
        write_data = 0;
        // Test Instruction Memory (ROM)
        #10 instr_address = 32'h00000000;
        #10 instr_address = 32'h00000004;
        #10 instr_address = 32'h00000008;
        // Test Data Memory (RAM)
        #10 mem_write = 1; data_address = 32'h00000010; write_data = 32'hDEADBEEF;
        #10 mem_write = 0;
        #10 mem_read = 1; data_address = 32'h00000010; // Read from memory
        #10 mem_read = 0;
        // Additional read/write tests
        #10 mem_write = 1; data_address = 32'h00000014; write_data = 32'hCAFEBABE;
        #10 mem_write = 0;
        #10 mem_read = 1; data_address = 32'h00000014;
        #10 mem_read = 0;
        // End simulation
        #50 $finish;
    end
    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Instr Addr: %h | Instr: %h | Data Addr: %h | Write Data: %h | Read Data: %h",
                 $time, instr_address, instruction, data_address, write_data, read_data);
    end
endmodule
