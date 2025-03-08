module instr_mem (input wire [31:0]address, output wire [31:0]instruction);
reg [31:0] mem [0:127];
    initial begin
        $readmemh("instructions.hex", mem);
    end
    assign instruction = mem[address];
endmodule