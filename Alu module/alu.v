module alu (
    input wire [31:0] a, b,
    input wire [3:0] alu_control, // ALU control signal
    output reg [31:0] result
);

    always @(*) begin
        case (alu_control)
            4'b0000: result = a + b;  // ADD
            4'b0001: result = a - b;  // SUB
            4'b0010: result = a & b;  // AND
            4'b0011: result = a | b;  // OR
            4'b0100: result = a ^ b;  // XOR
            4'b0101: result = (a < b) ? 1 : 0;  // SLT
            4'b0110: result = (a < b) ? 1 : 0;  // SLTU
            default: result = 32'b0;
        endcase
    end
endmodule