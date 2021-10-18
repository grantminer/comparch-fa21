module mux4(ena, in, out);

    input wire [1:0]ena;
    input wire [3:0]in;

    output wire out;

    // Select from a set of four inputs based on a two-bit input

    assign out = (~ena[1]& ~ena[0] & in[0]) | ((~ena[1]& ena[0] & in[1])) | (ena[1]& ~ena[0] & in[2]) | (ena[1]& ena[0] & in[3]);

endmodule