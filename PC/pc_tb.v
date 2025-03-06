`timescale 1ns/1ps
`include "pc.v"

module pc_tb;
    reg [31:0] next;
    reg clk;
    reg reset;
    wire [31:0] ppc;
    pc uut(.next(next),.clk(clk),.reset(reset),.ppc(ppc));

    // Clock generation
    initial begin
            $dumpfile("pcTB.vdc");
            $dumpvars(0,pc_tb);
        next=0;
        clk=0;
        reset=0;
    end

    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize inputs
        next = 32'h00000000;
        reset = 1;
        #10;
        
        // Release reset and provide next value
        reset = 0;
        next = 32'h00000001;
        #10;
        
        next = 32'h00000002;
        #10;
        
        next = 32'h00000003;
        #10;
        
        // Assert reset again
        reset = 1;
        #10;
        
        // Release reset and provide next value
        reset = 0;
        next = 32'h00000004;
        #10;
        
        // Finish simulation
        $stop;
    end
endmodule