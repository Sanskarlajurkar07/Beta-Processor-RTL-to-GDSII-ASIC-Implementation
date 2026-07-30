// bool unit - /alu/bool
// BFN is just a 4-entry truth table indexed by {A[i],B[i]} per bit,
// same trick as in lecture: AND=1000 OR=1110 XOR=0110 XNOR=1001,
// and 1010 just passes A through (used for LDR/JMP's alufn).

module beta_alu_bool (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  BFN,
    output wire [31:0] Y
);

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_loop
            assign Y[i] = BFN[{A[i], B[i]}];
        end
    endgenerate

endmodule

