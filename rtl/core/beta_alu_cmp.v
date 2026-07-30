// cmp unit - /alu/cmp
// doesn't do its own subtract, just reads the flags off arith (every
// CMPxx opcode has ALUFN[0]=1 so arith is already computing A-B for us)
//
//   CMPLT = N xor V
//   CMPLE = CMPLT or Z
//   CMPEQ = Z
//
// CFN: 01 eq, 10 lt, 11 le

module beta_alu_cmp (
    input  wire       V,
    input  wire       N,
    input  wire       Z,
    input  wire [1:0] CFN,
    output reg        Y
);

    wire lt = N ^ V;
    wire le = lt | Z;

    always @(*) begin
        case (CFN)
            2'b01: Y = Z;
            2'b10: Y = lt;
            2'b11: Y = le;
            default: Y = 1'b0;
        endcase
    end

endmodule
