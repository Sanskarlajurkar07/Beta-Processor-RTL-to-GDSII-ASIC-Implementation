// control logic (the "control ROM") - /beta/ctl
// straight opcode -> control signal table, values pulled from the
// unpipelined beta control table in the course notes.

module beta_ctl (
    input  wire [5:0] op,
    input  wire       reset,
    input  wire       irq,     // already gated to user mode by beta_core
    input  wire       z,       // Reg[Ra]==0, tapped off radata

    output reg         asel,
    output reg         bsel,
    output reg  [5:0]  alufn,
    output reg         moe,
    output reg         mwr,
    output reg         ra2sel,
    output reg  [1:0]  wdsel,
    output reg         wasel,
    output reg         werf,
    output reg  [2:0]  pcsel
);

    // alufn codes, see beta_alu.v for what the bits mean
    localparam [5:0] ALUFN_ADD   = 6'b010000;
    localparam [5:0] ALUFN_SUB   = 6'b010001;
    localparam [5:0] ALUFN_CMPEQ = 6'b000011;
    localparam [5:0] ALUFN_CMPLT = 6'b000101;
    localparam [5:0] ALUFN_CMPLE = 6'b000111;
    localparam [5:0] ALUFN_AND   = 6'b101000;
    localparam [5:0] ALUFN_OR    = 6'b101110;
    localparam [5:0] ALUFN_XOR   = 6'b100110;
    localparam [5:0] ALUFN_XNOR  = 6'b101001;
    localparam [5:0] ALUFN_A     = 6'b101010;
    localparam [5:0] ALUFN_SHL   = 6'b110000;
    localparam [5:0] ALUFN_SHR   = 6'b110001;
    localparam [5:0] ALUFN_SRA   = 6'b110011;

    localparam [5:0]
        OP_ADD=6'h20, OP_SUB=6'h21, OP_CMPEQ=6'h24, OP_CMPLT=6'h25, OP_CMPLE=6'h26,
        OP_AND=6'h28, OP_OR=6'h29,  OP_XOR=6'h2A,   OP_XNOR=6'h2B,
        OP_SHL=6'h2C, OP_SHR=6'h2D, OP_SRA=6'h2E,
        OP_ADDC=6'h30, OP_SUBC=6'h31, OP_CMPEQC=6'h34, OP_CMPLTC=6'h35, OP_CMPLEC=6'h36,
        OP_ANDC=6'h38, OP_ORC=6'h39, OP_XORC=6'h3A, OP_XNORC=6'h3B,
        OP_SHLC=6'h3C, OP_SHRC=6'h3D, OP_SRAC=6'h3E,
        OP_LD=6'h18, OP_ST=6'h19, OP_JMP=6'h1B, OP_BEQ=6'h1C, OP_BNE=6'h1D, OP_LDR=6'h1F;

    reg illegal;

    always @(*) begin
        // defaults = the ROM's don't-care rows
        alufn   = 6'b0;
        asel    = 1'b0;
        bsel    = 1'b0;
        moe     = 1'b0;
        mwr     = 1'b0;
        pcsel   = 3'd0;
        ra2sel  = 1'b0;
        wasel   = 1'b0;
        wdsel   = 2'b00;
        werf    = 1'b0;
        illegal = 1'b0;

        case (op)
            // OP class: Reg[Rc] <- Reg[Ra] op Reg[Rb]
            OP_ADD:   begin alufn=ALUFN_ADD;   wdsel=2'b01; werf=1; end
            OP_SUB:   begin alufn=ALUFN_SUB;   wdsel=2'b01; werf=1; end
            OP_CMPEQ: begin alufn=ALUFN_CMPEQ; wdsel=2'b01; werf=1; end
            OP_CMPLT: begin alufn=ALUFN_CMPLT; wdsel=2'b01; werf=1; end
            OP_CMPLE: begin alufn=ALUFN_CMPLE; wdsel=2'b01; werf=1; end
            OP_AND:   begin alufn=ALUFN_AND;   wdsel=2'b01; werf=1; end
            OP_OR:    begin alufn=ALUFN_OR;    wdsel=2'b01; werf=1; end
            OP_XOR:   begin alufn=ALUFN_XOR;   wdsel=2'b01; werf=1; end
            OP_XNOR:  begin alufn=ALUFN_XNOR;  wdsel=2'b01; werf=1; end
            OP_SHL:   begin alufn=ALUFN_SHL;   wdsel=2'b01; werf=1; end
            OP_SHR:   begin alufn=ALUFN_SHR;   wdsel=2'b01; werf=1; end
            OP_SRA:   begin alufn=ALUFN_SRA;   wdsel=2'b01; werf=1; end

            // OPC class: Reg[Rc] <- Reg[Ra] op SEXT(literal), bsel picks the literal
            OP_ADDC:   begin alufn=ALUFN_ADD;   bsel=1; wdsel=2'b01; werf=1; end
            OP_SUBC:   begin alufn=ALUFN_SUB;   bsel=1; wdsel=2'b01; werf=1; end
            OP_CMPEQC: begin alufn=ALUFN_CMPEQ; bsel=1; wdsel=2'b01; werf=1; end
            OP_CMPLTC: begin alufn=ALUFN_CMPLT; bsel=1; wdsel=2'b01; werf=1; end
            OP_CMPLEC: begin alufn=ALUFN_CMPLE; bsel=1; wdsel=2'b01; werf=1; end
            OP_ANDC:   begin alufn=ALUFN_AND;   bsel=1; wdsel=2'b01; werf=1; end
            OP_ORC:    begin alufn=ALUFN_OR;    bsel=1; wdsel=2'b01; werf=1; end
            OP_XORC:   begin alufn=ALUFN_XOR;   bsel=1; wdsel=2'b01; werf=1; end
            OP_XNORC:  begin alufn=ALUFN_XNOR;  bsel=1; wdsel=2'b01; werf=1; end
            OP_SHLC:   begin alufn=ALUFN_SHL;   bsel=1; wdsel=2'b01; werf=1; end
            OP_SHRC:   begin alufn=ALUFN_SHR;   bsel=1; wdsel=2'b01; werf=1; end
            OP_SRAC:   begin alufn=ALUFN_SRA;   bsel=1; wdsel=2'b01; werf=1; end

            // mem / control flow
            OP_LD:  begin alufn=ALUFN_ADD; bsel=1;         moe=1; wdsel=2'b10; werf=1; end
            OP_LDR: begin alufn=ALUFN_A;   asel=1;         moe=1; wdsel=2'b10; werf=1; end
            OP_ST:  begin alufn=ALUFN_ADD; bsel=1; mwr=1; ra2sel=1; end
            OP_JMP: begin pcsel=3'd2; wdsel=2'b00; werf=1; end
            OP_BEQ: begin pcsel = z ? 3'd1 : 3'd0; wdsel=2'b00; werf=1; end
            OP_BNE: begin pcsel = z ? 3'd0 : 3'd1; wdsel=2'b00; werf=1; end

            default: illegal = 1'b1;
        endcase

        if (illegal) begin
            pcsel = 3'd3;   // illop vector
            wasel = 1'b1;   // save return pc into xp
            wdsel = 2'b00;
            werf  = 1'b1;
        end

        if (irq) begin      // interrupt beats whatever we just decoded
            mwr   = 1'b0;
            pcsel = 3'd4;
            wasel = 1'b1;
            wdsel = 2'b00;
            werf  = 1'b1;
        end

        if (reset)
            mwr = 1'b0;      // never let reset leave a stray write pending

    end

endmodule
