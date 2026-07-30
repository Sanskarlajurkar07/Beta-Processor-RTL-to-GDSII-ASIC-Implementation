// regfile - /beta/regfile
// 32 x 32, two read ports (combinational), one write port (clocked).
// r31 always reads 0, same as the real thing.
//
//   ra2sel 0 -> port b address is Rb   (normal OP class)
//          1 -> port b address is Rc   (ST needs Reg[Rc] as store data)
//   wasel  0 -> write address is Rc    (normal writeback)
//          1 -> write address is r30/XP (irq or illop)

module beta_regfile (
    input  wire        clk,
    input  wire [4:0]  ra,
    input  wire [4:0]  rb,
    input  wire [4:0]  rc,
    input  wire        ra2sel,
    input  wire        wasel,
    input  wire        werf,
    input  wire [31:0] wdata,

    output wire [31:0] radata,
    output wire [31:0] rbdata
);

    reg [31:0] mem [0:31];

    wire [4:0] rb_addr = ra2sel ? rc : rb;
    wire [4:0] wa_addr = wasel ? 5'd30 : rc;

    assign radata = (ra      == 5'd31) ? 32'd0 : mem[ra];
    assign rbdata = (rb_addr == 5'd31) ? 32'd0 : mem[rb_addr];

    always @(posedge clk) begin
        if (werf)
            mem[wa_addr] <= wdata;
    end

endmodule
