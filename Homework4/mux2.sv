module mux2(ena, in, out);
    input wire ena;
    input wire [1:0]in;

    output wire out;

    assign out = ena ? in[1]:in[0];
endmodule