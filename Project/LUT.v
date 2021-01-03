// module: LUT
// function of this module:
// compare Si and Tj, if equal return 8, else return -5

module LUT(OUTPUT, Si, Tj);
    input  [1:0] Si, Tj;
    output signed [11:0] OUTPUT;
    assign OUTPUT = (Si == Tj) ? 12'sd8 : -12'sd5;
endmodule