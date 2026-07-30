// shift unit - /alu/shift
// SFN: 00 SHL, 01 SHR, 11 SRA (10 not used by any opcode)

module beta_alu_shift (
    input  wire [31:0] A,
    input  wire [4:0]  B,
    input  wire [1:0]  SFN,
    output reg  [31:0] Y
);

    always @(*) begin
        case (SFN)
            2'b00: Y = A << B;
            2'b01: Y = A >> B;
            2'b11: Y = $signed(A) >>> B;
            default: Y = A << B;
        endcase
    end

endmodule
