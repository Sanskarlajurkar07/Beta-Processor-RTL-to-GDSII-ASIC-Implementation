// arith unit - /alu/arith
// AFN=0 add, AFN=1 sub (A + ~B + 1). also spits out V/N/Z so the
// cmp unit can reuse them instead of doing its own subtract.

module beta_alu_arith (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        AFN,
    output wire [31:0] S,
    output wire        V,
    output wire        N,
    output wire        Z
);

    wire [31:0] B_op = AFN ? ~B : B;
    wire [32:0] sum  = {1'b0, A} + {1'b0, B_op} + {32'd0, AFN};

    assign S = sum[31:0];
    assign Z = (S == 32'd0);
    assign N = S[31];

    // same-sign operands, different-sign result -> overflow
    assign V = (A[31] == B_op[31]) && (S[31] != A[31]);

endmodule
