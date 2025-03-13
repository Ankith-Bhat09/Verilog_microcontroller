`timescale 1ns / 1ps
module data_memory_tb;
    // Testbench signals
    reg clk, mem_read, mem_write;
    reg [1:0] mem_size;
    reg [31:0] address, write_data;
    wire [31:0] read_data;
    // Instantiate the memory module
    data_memory uut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );
    // Clock Generation
    always #5 clk = ~clk; // 10ns clock cycle
    initial begin
        // Initialize signals
        clk = 0;
        mem_read = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;
        mem_size = 2'b10; // Default to word access
        // Display header
        $display("Time | Address | Write Data | Read Data | Mem Read | Mem Write | Mem Size");
        $monitor("%4t | %h | %h | %h | %b | %b | %b", 
                 $time, address, write_data, read_data, mem_read, mem_write, mem_size);
        // Test Read from Initialized Memory
        #10 mem_read = 1; mem_size = 2'b10; address = 32'h00000000;  // Read word from memory[0]
        #10 address = 32'h00000004;               // Read word from memory[1]
        #10 address = 32'h00000008;               // Read word from memory[2]
        #10 mem_read = 0;
        // Test Byte Store and Load
        #10 mem_write = 1; mem_size = 2'b00; address = 32'h00000010; write_data = 32'h000000AB;
        #10 mem_write = 0; 
        #10 mem_read = 1; address = 32'h00000010; // Read byte from memory[4]
        #10 mem_read = 0;
        // Test Half-Word Store and Load
        #10 mem_write = 1; mem_size = 2'b01; address = 32'h00000012; write_data = 32'h0000CDEF;
        #10 mem_write = 0;
        #10 mem_read = 1; address = 32'h00000012; // Read half-word from memory[4]
        #10 mem_read = 0;
        // Test Word Store and Load
        #10 mem_write = 1; mem_size = 2'b10; address = 32'h00000014; write_data = 32'hDEADBEEF;
        #10 mem_write = 0;
        #10 mem_read = 1; address = 32'h00000014; // Read word from memory[5]
        #10 mem_read = 0;

        // End Simulation
        #20 $finish;
    end
endmodule
