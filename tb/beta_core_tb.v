// quick smoke test for beta_core. not the full checkoff program from
// jade, just enough to catch anything obviously broken in the port.
//
// memories only decode ia[11:2]/ma[11:2] (4KB window) so the reset
// vector 0x80000000 lands on word 0 - sim-only shortcut, not part of
// the cpu itself.

`timescale 1ns/1ps

module beta_core_tb;

    reg clk   = 0;
    reg reset = 1;
    reg irq   = 0;

    wire [31:0] ia, ma, mwd;
    wire        mwr, moe;
    reg  [31:0] id;
    reg  [31:0] mrd;

    reg [31:0] imem [0:1023];
    reg [31:0] dmem [0:1023];

    beta_core dut (
        .clk   (clk),
        .reset (reset),
        .irq   (irq),
        .id    (id),
        .mrd   (mrd),
        .ia    (ia),
        .ma    (ma),
        .mwr   (mwr),
        .moe   (moe),
        .mwd   (mwd)
    );

    always #50 clk = ~clk;   // 10MHz, same as the jade bench

    always @(*) id  = imem[ia[11:2]];
    always @(*) mrd = dmem[ma[11:2]];
    always @(posedge clk) if (mwr) dmem[ma[11:2]] <= mwd;

    localparam [5:0] ADDC=6'h30, SUBC=6'h31, ADD=6'h20,
                      CMPEQ=6'h24, LD=6'h18, ST=6'h19, BEQ=6'h1C;

    function [31:0] opc;                  // op class: op(rc,ra,rb)
        input [5:0] op; input [4:0] rc, ra, rb;
        opc = {op, rc, ra, rb, 11'd0};
    endfunction

    function [31:0] oplit;                // opc / mem / branch class
        input [5:0] op; input [4:0] rc, ra; input [15:0] lit;
        oplit = {op, rc, ra, lit};
    endfunction

    integer errors = 0;

    initial begin
        // r31 always reads 0, so ADDC(R31,5,R1) just loads 5 into R1
        imem[0] = oplit(ADDC, 5'd1, 5'd31, 16'd5);     // r1 <- 5
        imem[1] = oplit(ADDC, 5'd2, 5'd31, 16'd7);     // r2 <- 7
        imem[2] = opc  (ADD,  5'd3, 5'd1,  5'd2);      // r3 <- r1+r2 = 12
        imem[3] = oplit(SUBC, 5'd4, 5'd3,  16'd2);     // r4 <- r3-2  = 10
        imem[4] = oplit(ST,   5'd4, 5'd31, 16'd64);    // mem[64] <- r4
        imem[5] = oplit(LD,   5'd5, 5'd31, 16'd64);    // r5 <- mem[64]
        imem[6] = opc  (CMPEQ,5'd6, 5'd4,  5'd5);      // r6 <- (r4==r5)
        imem[7] = oplit(BEQ,  5'd31, 5'd31, 16'hFFFF); // spin here

        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;

        repeat (15) @(posedge clk);

        check("R1",      dut.u_regfile.mem[1], 32'd5);
        check("R2",      dut.u_regfile.mem[2], 32'd7);
        check("R3",      dut.u_regfile.mem[3], 32'd12);
        check("R4",      dut.u_regfile.mem[4], 32'd10);
        check("R5",      dut.u_regfile.mem[5], 32'd10);
        check("R6",      dut.u_regfile.mem[6], 32'd1);
        check("Mem[64]", dmem[16],             32'd10);

        if (errors == 0) $display("ALL TESTS PASSED");
        else              $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

    task check(input [63:0] name, input [31:0] got, input [31:0] expected);
        begin
            if (got !== expected) begin
                errors = errors + 1;
                $display("FAIL %s: got %h expected %h", name, got, expected);
            end else begin
                $display("PASS %s: %h", name, got);
            end
        end
    endtask

endmodule
