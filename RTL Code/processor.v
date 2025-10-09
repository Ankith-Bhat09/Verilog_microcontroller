module processor(clk1, clk2, reset);
//Input and output ports
input clk1, clk2;
input reset;
//***********************************************************************\\
// Parameters
// Register type
parameter ADD=6'b000001;    // ADD rs1 rs2 rd
parameter SUB=6'b000010;    // SUB rs1 rs2 rd
parameter AND=6'b000011;    // AND rs1 rs2 rd
parameter OR=6'b000100;     // OR rs1 rs2 rd
parameter XOR=6'b000101;    // XOR rs1 rs2 rd
// Immediate type
parameter ADDI=6'b000110;   // ADDI rs1 rd imm
parameter SUBI=6'b000111;   // SUBI rs1 rd imm
parameter ANDI=6'b001000;   // ANDI rs1 rd imm
parameter ORI=6'b001001;    // ORI rs1 rd imm
parameter Load=6'b001010;   // Load rs1 rd
parameter Store=6'b001011;  // Store rs1 rd

// Immediate type with check for opcode

parameter shiftR=6'b010001; // shiftR rs1 rd imm
parameter shiftL=6'b010010; // shiftL rs1 rd imm
parameter branch=6'b100000; // branch rs1 imm
parameter Jmp=6'b100001;    // Jmp imm
parameter Beq=6'b100010;    // Beq rs1 rs2 imm
parameter Blt=6'b100011;    // Blt rs1 rs2 imm
parameter Bgt=6'b100100;    // Bgt rs1 rs2 imm
parameter Nop=6'b000000;    // Nop
parameter Halt=6'b111111;   // Halt

//***********************************************************************\\
// Operation type
parameter rr_ALU=4'b0001, ri_ALU=4'b0010, ri_Load=4'b0011, ri_Store=4'b0100;
parameter ri_shiftR=4'b0101, ri_shiftL=4'b0110;
parameter r_branch=4'b0111;
parameter r_Nop=4'b1000, r_Halt=4'b1001;
//***********************************************************************\\
//Internal register and wires
reg [31:0] PC,if_id_ir;
reg [31:0] mem[0:255];
reg [31:0] regfile[0:31];
reg halted;
reg taken_branch;
reg [31:0] if_id_npc, id_ex_npc;
reg [31:0] id_ex_a, id_ex_b, id_ex_imm;
reg [31:0] id_ex_ir;
reg [3:0] id_ex_optype;
reg [31:0] ex_mem_ir;
reg [3:0] ex_mem_optype;
reg [31:0] ex_mem_ALUout, ex_mem_b;
reg ex_mem_cond;
reg [31:0] mem_wb_ir;
reg [3:0] mem_wb_optype;
reg [31:0] mem_wb_ALUout, mem_wb_Loadout;

//***********************************************************************\\
// Instruction Fetch
always @(posedge clk1)
begin
    if(reset)
    begin
        PC<=0;
    end
    if (halted==0)
    begin
        if(((ex_mem_ir[31:26]==branch)&&(ex_mem_cond == 1))||((ex_mem_ir[31:26]==Jmp)&&(ex_mem_cond == 1))||((ex_mem_ir[31:26]==Beq)&&(ex_mem_cond == 1))||((ex_mem_ir[31:26]==Blt)&&(ex_mem_cond == 1))||((ex_mem_ir[31:26]==Bgt)&&(ex_mem_cond == 1)))
        begin
            if_id_ir <= mem[ex_mem_ALUout];
            taken_branch <= 1;
            if_id_npc <= ex_mem_ALUout + 1;
            PC <= ex_mem_ALUout + 1;
        end
        else
        begin
            if_id_ir<=mem[PC];
            PC<=PC+1;
            if_id_npc<=PC+1;
        end
    end
end
//***********************************************************************\\
// Instruction Decode
always @(posedge clk2)
begin
//*********** check for debug here This may be a problem. ***********\\
//if (halted==0)
//begin
//    if(if_id_ir[31:26]==Jmp)
//    begin
//        PC<=if_id_ir[25:0];
//end
//*********** check for debug here This may be a problem. ***********\\
    if(if_id_ir[25:21]==5'b00000) id_ex_a<=0;
    else id_ex_a<=#2 regfile[if_id_ir[25:21]];

    if(if_id_ir[20:16]==5'b00000) id_ex_b<=0;
    else id_ex_b<=#2 regfile[if_id_ir[20:16]];

    id_ex_imm<= {{16{if_id_ir[15]}},if_id_ir[15:0]};
    id_ex_ir<=if_id_ir;
    id_ex_npc<=if_id_npc;

    case (if_id_ir[31:26])
        ADD: id_ex_optype<=rr_ALU;          // Add
        SUB: id_ex_optype<=rr_ALU;          // Subtract
        AND: id_ex_optype<=rr_ALU;          // And
        OR: id_ex_optype<=rr_ALU;           // Or
        ADDI: id_ex_optype<=ri_ALU;         // Add Immediate
        SUBI: id_ex_optype<=ri_ALU;         // Subtract Immediate
        ANDI: id_ex_optype<=ri_ALU;         // And Immediate
        ORI:  id_ex_optype<=ri_ALU;         // Or Immediate
        Load: id_ex_optype<=ri_Load;        // Load
        Store:id_ex_optype<=ri_Store;       // Store
        shiftR:id_ex_optype<=ri_shiftR;     // Shift Right
        shiftL:id_ex_optype<=ri_shiftL;     // Shift Left
        branch:id_ex_optype<=r_branch;      // Branch
        Jmp:   id_ex_optype<=r_branch;      // Jump
        Beq:   id_ex_optype<=r_branch;      // Branch if Equal
        Blt:   id_ex_optype<=r_branch;      // Branch if Less Than
        Bgt:   id_ex_optype<=r_branch;      // Branch if Greater Than
        Nop:   id_ex_optype<=r_Nop;         // No Operation
        Halt:  id_ex_optype<=r_Halt;        // Halt
        default: id_ex_optype<=r_Nop;
    endcase
end
//***********************************************************************\\
// Execute
always @(posedge clk1)
begin
    if(halted==0)
    begin
        ex_mem_ir<=id_ex_ir;
        ex_mem_optype<=id_ex_optype;
        taken_branch<=0;
        case(id_ex_optype)
            rr_ALU: case(id_ex_ir[31:26])
                        ADD: ex_mem_ALUout <= id_ex_a + id_ex_b;    // ADD
                        SUB: ex_mem_ALUout <= id_ex_a - id_ex_b;    // SUB
                        AND: ex_mem_ALUout <= id_ex_a & id_ex_b;    // AND
                        OR:  ex_mem_ALUout <= id_ex_a | id_ex_b;    // OR
                        XOR: ex_mem_ALUout <= id_ex_a ^ id_ex_b;    // XOR
                        default: ex_mem_ALUout <=0;
                    endcase
            ri_ALU: case(id_ex_ir[31:26])
                        ADDI: ex_mem_ALUout <= id_ex_a + id_ex_imm; // ADDI
                        SUBI: ex_mem_ALUout <= id_ex_a - id_ex_imm; // SUBI
                        ANDI: ex_mem_ALUout <= id_ex_a & id_ex_imm; // ANDI
                        ORI:  ex_mem_ALUout <= id_ex_a | id_ex_imm; // ORI
                        default: ex_mem_ALUout <=0;
                    endcase
            ri_Load, ri_Store:
            begin
                ex_mem_ALUout <= id_ex_a + id_ex_imm;
                ex_mem_b <= id_ex_b;
            end
            ri_shiftL,ri_shiftR:
            begin
                case(id_ex_ir[31:26])
                    shiftL: ex_mem_ALUout <= id_ex_a << id_ex_imm; // Shift Left
                    shiftR: ex_mem_ALUout <= id_ex_a >> id_ex_imm; // Shift Right
                    default: ex_mem_ALUout <=0;
                endcase
            end
            r_branch:
            begin
                case(id_ex_ir[31:26])

                    branch:
                    begin
                        ex_mem_ALUout <= id_ex_npc + id_ex_imm;
                        ex_mem_cond <= (id_ex_a==0)? 1:0;
                    end
                    Jmp:
                    begin
                        ex_mem_ALUout <= id_ex_ir[25:0];
                        ex_mem_cond <= 1;
                    end
                    Beq:
                    begin
                        if(id_ex_a==id_ex_b)
                        begin
                            ex_mem_ALUout <= id_ex_npc + id_ex_imm;
                            ex_mem_cond <= 1;
                        end
                        else begin
                            ex_mem_cond <= 0;
                        end
                    end
                    Blt:
                    begin
                        if(id_ex_a < id_ex_b)
                        begin
                            ex_mem_ALUout <= id_ex_npc + id_ex_imm;
                            ex_mem_cond <= 1;
                        end
                        else begin
                            ex_mem_cond <= 0;
                        end
                    end
                    Bgt:
                    begin
                        if(id_ex_a > id_ex_b)
                        begin
                            ex_mem_ALUout <= id_ex_npc + id_ex_imm;
                            ex_mem_cond <= 1;
                        end
                        else begin
                            ex_mem_cond <= 0;
                        end
                    end
                endcase
            end
        endcase
    end
end
//***********************************************************************\\
// Memory
always @(posedge clk2)
begin
    if(halted==0)
    begin
        mem_wb_optype <= ex_mem_optype;
        mem_wb_ir <= ex_mem_ir;
        case(ex_mem_optype)
            rr_ALU, ri_ALU:
                mem_wb_ALUout <= #2 ex_mem_ALUout;
            ri_Load:
                mem_wb_Loadout <= #2 mem[ex_mem_ALUout];
            ri_Store:
                if(taken_branch==0) mem[ex_mem_ALUout] <= #2 ex_mem_b;
        endcase
    end
end
//***********************************************************************\\
// Write Back
always @(posedge clk1)
begin
    if(taken_branch==0)
    begin
        case(mem_wb_optype)
            rr_ALU:
                regfile[mem_wb_ir[15:11]] <= #2 mem_wb_ALUout;
            ri_ALU:
                regfile[mem_wb_ir[20:16]] <=#2 mem_wb_ALUout;
            ri_shiftL:
                regfile[mem_wb_ir[20:16]] <=#2 mem_wb_ALUout;
            ri_shiftR:
                regfile[mem_wb_ir[20:16]] <=#2 mem_wb_ALUout;
            ri_Load:
                regfile[mem_wb_ir[20:16]] <=#2 mem_wb_Loadout;
            r_Halt:
                halted <= 1;
        endcase
    end
end
//***********************************************************************\\
endmodule
