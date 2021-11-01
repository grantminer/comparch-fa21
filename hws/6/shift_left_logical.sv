module shift_left_logical(in, shamt, out);

parameter N = 32; // only used as a constant! Don't feel like you need to a shifter for arbitrary N.

input wire [N-1:0] in;            // the input number that will be shifted left. Fill in the remainder with zeros.
input wire [$clog2(N)-1:0] shamt; // the amount to shift by (think of it as a decimal number from 0 to 31). 
output logic [N-1:0] out;

reg [4:0] select;
logic temp_out;

mux32 MUX(in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7], in[8], in[9], in[10], in[11],
          in[12], in[13], in[14], in[15], in[16], in[17], in[18], in[19], in[20], in[21], in[22],
          in[23], in[24], in[25], in[26], in[27], in[28], in[29], in[30], in[31], select, temp_out);

assign select = shamt;

always_comb begin
    if (select < N-1) begin
        select = select + 1;
        out[select] = temp_out;
    end
end

endmodule
