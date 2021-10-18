module mux8(ena, in, out);

    input wire [2:0]ena;
    input wire [7:0]in;

    wire out1;
    wire out2;

    output wire out;

    // Select from a set of 8 inputs based on a three-bit input

    mux4 muxlow(.ena(ena[1:0]), .in(in[3:0]), .out(out1));
    mux4 muxhigh(.ena(ena[1:0]), .in(in[7:4]), .out(out2));

    assign out = ((ena[2] & out2) | (~ena[2] & out1));

endmodule