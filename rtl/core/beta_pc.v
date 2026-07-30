// PC - /beta/pc
//
// PCSEL: 0 PC+4, 1 branch target (PC+4+4*SXT(C)), 2 JT (jump, built
// upstream in beta_core), 3 illop vector, 4 irq vector.
//
// PC[31] is the supervisor bit - both adders below leave it alone and
// just pass it through, so ADD/branch math can never flip the cpu into
// supervisor mode on its own.

module beta_pc (
    input  wire        CLK,
    input  wire        RESET,
    input  wire [15:0] ID,
    input  wire [31:0] JT,
    input  wire [2:0]  PCSEL,

    output wire [31:0] PC,
    output wire [31:0] PC_OFFSET,
    output wire [31:0] PC_INC
);

    reg [31:0] pc_reg;
    assign PC = pc_reg;

    wire [31:0] pc_plus4 = pc_reg + 32'd4;
    assign PC_INC = {pc_reg[31], pc_plus4[30:0]};

    wire [31:0] disp = {{14{ID[15]}}, ID[15:0], 2'b00};   // 4*SXT(C)
    wire [31:0] pc_offset_sum = pc_plus4 + disp;
    assign PC_OFFSET = {pc_reg[31], pc_offset_sum[30:0]};

    reg [31:0] pc_next;
    always @(*) begin
        case (PCSEL)
            3'd0: pc_next = PC_INC;
            3'd1: pc_next = PC_OFFSET;
            3'd2: pc_next = JT;
            3'd3: pc_next = 32'h80000004;
            3'd4: pc_next = 32'h80000008;
            default: pc_next = PC_INC;
        endcase
    end

    always @(posedge CLK) begin
        if (RESET)
            pc_reg <= 32'h80000000;
        else
            pc_reg <= pc_next;
    end

endmodule
