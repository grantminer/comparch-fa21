module mux16(ena, in, out);

    input wire [3:0]ena;
    input wire [15:0]in;

    wire out1;
    wire out2;

    output wire out;

    // Select from a set of 8 inputs based on a three-bit input

    mux8 muxlow(.ena(ena[2:0]), .in(in[7:0]), .out(out1));
    mux8 muxhigh(.ena(ena[2:0]), .in(in[15:8]), .out(out2));

    assign out = ((ena[3] & out2) | (~ena[3] & out1));

endmodule