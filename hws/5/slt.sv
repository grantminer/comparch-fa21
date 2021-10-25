module slt(a, b, out);
parameter N = 32;
input wire signed [N-1:0] a, b;
output logic out;

// Using only *structural* combinational logic, make a module that computes if a is less than b!
// Note: this assumes that the two inputs are signed: aka should be interpreted as two's complement.

// Copy any other modules you use into this folder and update the Makefile accordingly.

wire [N:0] sum;

adderN #(.N(N)) subtractor(.a(a), .b(~b), .carry0(1'b1), .sum(sum));

assign out = ((a[N-1]^b[N-1]) & a[N-1]) | ((a[N-1] ~^ b[N-1])&sum[N-1]);

endmodule