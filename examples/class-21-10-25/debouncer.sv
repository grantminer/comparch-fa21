module debouncer(clk, rst, bouncy_in, debounced_out);
parameter BOUNCE_TICKS = 10;
input wire clk, rst;
input wire bouncy_in;

output logic debounced_out;

always_comb debounced_out = 1'bx; // just for debugging - will show up red!

endmodule