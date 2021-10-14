module decoder_1_to_2(ena, in, out);

input wire ena;
input wire in;
output logic [1:0] out;

// Separates the one bit number into two bits representing its states
always_comb begin
  out[1] = ena & in;
  out[0] = ena & ~in;
end

endmodule