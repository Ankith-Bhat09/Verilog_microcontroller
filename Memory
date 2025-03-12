module instruction_memory (
    input [31:0] address,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:127]; // 128-word instruction memory

    initial begin
        $readmemh("instructions.mem", memory); // Load instructions from external file
    end

    always @(*) begin
        instruction = memory[address >> 2]; // Fetch instruction based on PC
    end
endmodule
