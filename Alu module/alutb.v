`timescale 1ns/1ps
`include "alu.v"
module alu_tb;
reg [31:0]a,b;
reg [3:0]control;
wire [31:0]result;
alu uut( .a(a),.b(b),.alu_control(control),.result(result));
initial begin
    $dumpfile("alu_tb.vdc");
    $dumpvars(0,alu_tb);
    a=32'h125068AF;
    b=32'h137825AC;
    control=0;
    end
always #20 control=control+1;
endmodule