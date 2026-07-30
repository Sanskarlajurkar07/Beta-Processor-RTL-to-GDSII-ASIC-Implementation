// top-level unpipelined beta - /beta/beta
// port list matches the jade module exactly so it drops into the same
// memory testbench setup.

module beta_core (
    input  wire        clk,
    input  wire        reset,
    input  wire        irq,
    input  wire [31:0] id,      // instruction word (from ia)
    input  wire [31:0] mrd,     // data read word (from ma, when moe asserted)

    output wire [31:0] ia,      // fetch address == pc
    output wire [31:0] ma,      // data address == alu result
    output wire        mwr,
    output wire        moe,
    output wire [31:0] mwd
);

    wire [5:0] op     = id[31:26];
    wire [4:0] ra_fld = id[20:16];
    wire [4:0] rb_fld = id[15:11];
    wire [4:0] rc_fld = id[25:21];

    wire        asel, bsel, moe_ctl, mwr_ctl, ra2sel, wasel, werf;
    wire [5:0]  alufn;
    wire [1:0]  wdsel;
    wire [2:0]  pcsel;
    wire        z;

    // interrupts only get taken in user mode (pc[31]=0)
    wire irq_gated = irq & ~ia[31];

    beta_ctl u_ctl (
        .op     (op),
        .reset  (reset),
        .irq    (irq_gated),
        .z      (z),
        .asel   (asel),
        .bsel   (bsel),
        .alufn  (alufn),
        .moe    (moe_ctl),
        .mwr    (mwr_ctl),
        .ra2sel (ra2sel),
        .wdsel  (wdsel),
        .wasel  (wasel),
        .werf   (werf),
        .pcsel  (pcsel)
    );

    assign moe = moe_ctl;
    assign mwr = mwr_ctl;

    wire [31:0] pc, pc_offset, pc_inc, jt;

    beta_pc u_pc (
        .CLK       (clk),
        .RESET     (reset),
        .ID        (id[15:0]),
        .JT        (jt),
        .PCSEL     (pcsel),
        .PC        (pc),
        .PC_OFFSET (pc_offset),
        .PC_INC    (pc_inc)
    );

    assign ia = pc;

    wire [31:0] radata, rbdata, wdata;

    beta_regfile u_regfile (
        .clk    (clk),
        .ra     (ra_fld),
        .rb     (rb_fld),
        .rc     (rc_fld),
        .ra2sel (ra2sel),
        .wasel  (wasel),
        .werf   (werf),
        .wdata  (wdata),
        .radata (radata),
        .rbdata (rbdata)
    );

    assign z = (radata == 32'd0);   // branch condition, straight off radata

    // jmp target - low 2 bits forced 0 (word aligned), and jmp can only
    // clear the supervisor bit, never set it
    assign jt = { (ia[31] & radata[31]), radata[30:2], 2'b00 };

    wire [31:0] sext_c = {{16{id[15]}}, id[15:0]};

    // asel=1 is only used by ldr, which needs pc_offset instead of ra
    wire [31:0] alu_a = asel ? {1'b0, pc_offset[30:0]} : radata;
    wire [31:0] alu_b = bsel ? sext_c : rbdata;

    wire [31:0] alu_result;

    beta_alu u_alu (
        .ALUFN (alufn),
        .A     (alu_a),
        .B     (alu_b),
        .ALU   (alu_result),
        .Z     (),
        .V     (),
        .N     ()
    );

    assign ma  = alu_result;
    assign mwd = rbdata;   // st: ra2sel already put Reg[Rc] on rbdata

    // writeback mux: 0 pc+4, 1 alu, 2 mem
    reg [31:0] wdata_r;
    always @(*) begin
        case (wdsel)
            2'b00: wdata_r = pc_inc;
            2'b01: wdata_r = alu_result;
            2'b10: wdata_r = mrd;
            default: wdata_r = 32'd0;
        endcase
    end
    assign wdata = wdata_r;

endmodule
