module adder2(a, b, c_in, sum, c_out);
  input wire [1:0] a;
  input wire [1:0] b;
  input wire c_in;

  output wire [1:0] sum;
  output wire c_out;
  wire c;

  // Adds the least significant bits of the two two-bit numbers
  adder1 ADD0 (
    .a(a[0]), .b(b[0]), .c_in(c_in), .sum(sum[0]), .c_out(c)
  );

  // Adds the most significant bits and determines whether there is carry out
  adder1 ADD1 (
    .a(a[1]), .b(b[1]), .c_in(c), .sum(sum[1]), .c_out(c_out)
  );
endmodule