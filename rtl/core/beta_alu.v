// top-level ALU - /alu/alu
// ALUFN[5:4] picks which sub-unit's result actually gets used:
//   00 cmp   01 arith   10 bool   11 shift
//
// arith runs every cycle regardless (cheap, and cmp needs its V/N/Z).
//
//   AFN      = ALUFN[0]
//   BFN[3:0] = ALUFN[3:0]
//   SFN[1:0] = ALUFN[1:0]
//   CFN[1:0] = ALUFN[2:1]

module beta_alu (
    input  wire [5:0]  ALUFN,
    input  wire [31:0] A,
    input  wire [31:0] B,

    output reg  [31:0] ALU,
    output wire        Z,
    output wire        V,
    output wire        N
);

    wire       afn = ALUFN[0];
    wire [3:0] bfn = ALUFN[3:0];
    wire [1:0] sfn = ALUFN[1:0];
    wire [1:0] cfn = ALUFN[2:1];

    wire [31:0] arith_s;
    wire        arith_v, arith_n, arith_z;
    beta_alu_arith u_arith (
        .A (A), .B (B), .AFN (afn),
        .S (arith_s), .V (arith_v), .N (arith_n), .Z (arith_z)
    );

    wire [31:0] bool_y;
    beta_alu_bool u_bool (.A (A), .B (B), .BFN (bfn), .Y (bool_y));

    wire [31:0] shift_y;
    beta_alu_shift u_shift (.A (A), .B (B[4:0]), .SFN (sfn), .Y (shift_y));

    wire cmp_bit;
    beta_alu_cmp u_cmp (
        .V (arith_v), .N (arith_n), .Z (arith_z), .CFN (cfn), .Y (cmp_bit)
    );

    always @(*) begin
        case (ALUFN[5:4])
            2'b00: ALU = {31'd0, cmp_bit};
            2'b01: ALU = arith_s;
            2'b10: ALU = bool_y;
            2'b11: ALU = shift_y;
            default: ALU = arith_s;
        endcase
    end

    assign Z = (ALU == 32'd0);
    assign V = arith_v;
    assign N = arith_n;

endmodule
