// Code your design here
module control_unit (
    input [6:0] opcode,      // 7-bit opcode from instruction[6:0]
    output reg RegWrite,     // Register write enable
    output reg MemRead,      // Memory read enable
    output reg MemWrite,     // Memory write enable
    output reg Branch,       // Branch signal
    output reg MemToReg,     // Select between memory output and ALU result
    output reg [1:0] ALUSrc, // ALU source select
    output reg [2:0] ALUOp   // ALU operation select
);

    always @(*) begin
        // Default values
        RegWrite = 0;
        MemRead = 0;
        MemWrite = 0;
        Branch = 0;
        MemToReg = 0;
        ALUSrc = 2'b00;
        ALUOp = 3'b000;

        case (opcode)
            7'b0110011: begin  // R-type
                RegWrite = 1;
                ALUSrc = 2'b00;
                ALUOp = 3'b010;
            end

            7'b0010011: begin  // I-type (immediate arithmetic)
                RegWrite = 1;
                ALUSrc = 2'b01;
                ALUOp = 3'b011;
            end

            7'b0000011: begin  // Load (e.g., LW)
                RegWrite = 1;
                MemRead = 1;
                MemToReg = 1;
                ALUSrc = 2'b01;
                ALUOp = 3'b000;
            end

            7'b0100011: begin  // Store (e.g., SW)
                MemWrite = 1;
                ALUSrc = 2'b01;
                ALUOp = 3'b000;
            end

            7'b1100011: begin  // Branch (e.g., BEQ)
                Branch = 1;
                ALUOp = 3'b001;
            end

            7'b1101111: begin  // JAL (Jump and Link)
                RegWrite = 1;
                ALUSrc = 2'b10;
            end

            7'b1100111: begin  // JALR (Jump and Link Register)
                RegWrite = 1;
                ALUSrc = 2'b01;
            end

            default: begin
                // Invalid opcode or NOP
            end
        endcase
    end
endmodule
