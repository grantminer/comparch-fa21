module shift_right_logical(in,shamt,out);
parameter N = 32; // only used as a constant! Don't feel like you need to a shifter for arbitrary N.

//port definitions
input  wire [N-1:0] in;    // A 32 bit input
input  wire [$clog2(N)-1:0] shamt; // Amount we shift by.
output logic [N-1:0] out;  // Output.

always_comb begin
    for (int i = 0; i < N - shamt; i= i + 1) begin
        out[i] = in[i + shamt];
    end
end

endmodule
