// module: MAX
// function of this module:
// return the biggest one in {A, B, 0(zero)}, view A, B as signed integer.

module MAX(OUTPUT, A, B);
    input signed [11:0] A, B;
    output [11:0] OUTPUT;
    assign OUTPUT = (A > B) ? A : B;
endmodule
