module register (clk, rst, ena, d, q);

parameter N = 32;

input wire clk, rst, ena;
input wire [N-1:0] d;

output logic [N-1:0] q;

always_ff @(posedge clk) begin
    if (rst) q <= 0;
    else if (ena) q <= d;
end

endmodule