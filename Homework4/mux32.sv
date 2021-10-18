module mux32(ena, in, out);

    input wire [4:0]ena;
    input wire [31:0]in;

    wire out1;
    wire out2;

    output wire out;

    // Select from a set of 8 inputs based on a three-bit input

    mux16 muxlow(.ena(ena[3:0]), .in(in[15:0]), .out(out1));
    mux16 muxhigh(.ena(ena[3:0]), .in(in[31:16]), .out(out2));

    assign out = ((ena[4] & out2) | (~ena[4] & out1));

endmodule