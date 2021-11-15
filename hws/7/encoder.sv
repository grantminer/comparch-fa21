module encoderN(encode, out);

parameter N = 32;

input wire [N-1:0] encode;
output logic [$clog2(N)-1:0] out;



endmodule