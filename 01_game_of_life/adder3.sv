module adder3(a, b, c_in, sum, c_out);
  input wire [2:0] a;
  input wire [2:0] b;
  input wire c_in;
  
  output wire [2:0] sum;
  output wire c_out;
  wire [1:0] c;

  adder1 ADD0 (
    a[0], b[0], c_in, sum[0], c[0]
  );
  adder1 ADD1 (
    a[1], b[1], c[0], sum[1], c[1]
  );
  adder1 ADD2 (
    a[2], b[2], c[1], sum[2], c_out
  );
endmodule