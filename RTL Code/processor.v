module processor();
//Input and output ports
input clk1, clk2;
input reset;
//***********************************************************************\\
// Parameters
// Register type
parameter ADD=6'b000001, SUB=6'b000010, AND=6'b000011, OR=6'b000100, XOR=6'b000101;
// Immediate type
parameter ADDI=6'b000110, SUBI=6'b000111, ANDI=6'b001000, ORI=6'b001001;
parameter Load=6'b001010, Store=6'b001011;
//imediate type with check for opcode
parameter shiftR=6'b010001, shiftL=6'b010010;
parameter branch=6'b100000, Jmp=6'b100001, Beq=6'b100010, Blt=6'b100011,Bgt=6'b100100;
parameter Nop=6'b000000;
parameter Halt=6'b111111;

//***********************************************************************\\
// Operation type
parameter rr_ALU=4'b0001, ri_ALU=4'b0010, ri_Load=4'b0011, ri_Store=4'b0100;
parameter ri_shiftR=4'b0101, ri_shiftL=4'b0110;
parameter branch=4'b0111;
parameter rr_Nop=4'b1000, rr_Halt=4'b1001;
//***********************************************************************\\
//Internal register and wires
reg [31:0] PC,if_id_ir;
reg [31:0] mem[0:255];
reg [31:0] regfile[0:31];
reg halted;
reg taken_branch;
//***********************************************************************\\
// Instruction Fetch
always @(posedge clk1)
begin
    if(reset)
    begin
        PC<=0;
        mem <=0;
    end
    if (halted==0)
    begin
        if()
        begin
            if_id_ir<=mem[PC];
            PC<=PC+1;
            if_id_npc<=PC;
        end
    end
end
//***********************************************************************\\
// Instruction Decode
always @(posedge clk2)
begin
if (halted==0)
begin
    if(if_id_ir[31:26]==Jmp)
    begin
        PC<=if_id_ir[25:0];
    end
    if(if_id_ir[25:21]==5'b00000) id_ex_a<=0;
    else id_ex_a<=#2 regfile[if_id_ir[25:21]];

    if(if_id_ir[20:16]==5'b00000) id_ex_b<=0;
    else id_ex_b<=#2 regfile[if_id_ir[20:16]];

    id_ex_imm<= {{16{if_id_ir[15]}},if_id_ir[15:0]};
    id_ex_ir<=if_id_ir;
    id_ex_npc<=if_id_npc;

    case (if_id_ir[31:26])
        ADD: id_ex_op<=rr_ALU;  // Add
        SUB: id_ex_op<=rr_ALU;  // Subtract
        AND: id_ex_op<=rr_ALU;  // And
        OR: id_ex_op<=rr_ALU;    // Or
        NOT: id_ex_op<=rr_ALU;  // Not
        ADDI: id_ex_op<=ri_ALU;  // Add Immediate
        SUBI: id_ex_op<=ri_ALU;  // Subtract Immediate
        ANDI: id_ex_op<=ri_ALU;  // And Immediate
        ORI:  id_ex_op<=ri_ALU;   // Or Immediate
        Load: id_ex_op<=ri_Load;  // Load
        Store:id_ex_op<=ri_Store; // Store
        shiftR:id_ex_op<=ri_shiftR; // Shift Right
        shiftL:id_ex_op<=ri_shiftL; // Shift Left
        branch:id_ex_op<=branch; // Branch
        Jmp:   id_ex_op<=branch;   // Jump
        Beq:   id_ex_op<=branch;   // Branch if Equal
        Blt:   id_ex_op<=branch;   // Branch if Less Than
        Bgt:   id_ex_op<=branch;   // Branch if Greater Than
        Nop:   id_ex_op<=rr_Nop;   // No Operation
        Halt:  id_ex_op<=rr_Halt;  // Halt
        default: id_ex_op<=Nop;
    endcase
end
end
//***********************************************************************\\
// Execute
always @(posedge clk1)
begin
    if(halted==0)
    begin
        ex_mem_ir<=id_ex_ir;
        ex_mem_op<=id_ex_op;
        taken_branch<=0;
        case(id_ex_op)
            rr_ALU: case(id_ex_ir[31:26])
                        ADD: ex_mem_ALUout <= id_ex_a + id_ex_b; // ADD
                        SUB: ex_mem_ALUout <= id_ex_a - id_ex_b; // SUB
                        AND: ex_mem_ALUout <= id_ex_a & id_ex_b; // AND
                        OR:  ex_mem_ALUout <= id_ex_a | id_ex_b; // OR
                        XOR: ex_mem_ALUout <= id_ex_a ^ id_ex_b; // XOR
                        default: ex_mem_ALUout <=0;
                    endcase

        endcase
    end
end
//***********************************************************************\\
// Memory
always @(posedge clk2)
begin

            ex_mem_ALUout <= id_ex_a + id_ex_imm; // ADDI
            ex_mem_ALUout <= id_ex_a - id_ex_imm; // SUBI
        endcase
    end
end
//***********************************************************************\\
// Memory
always @(posedge clk2)
begin

end
//***********************************************************************\\
// Write Back
always @(posedge clk1)
begin

end
//***********************************************************************\\
endmodule