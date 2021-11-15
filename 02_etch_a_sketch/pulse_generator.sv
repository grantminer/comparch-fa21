/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle ever "ticks" clocks.
*/
module pulse_generator(clk, rst, ena, ticks, out);

parameter N = 8;
input wire clk, rst, ena;
input wire [N-1:0] ticks;
output logic out;

logic [N-1:0] counter;
logic counter_comparator;

always_comb out <= 0;

always_ff @(posedge clk) begin
  out <= 0;
  if (rst)
    counter <= 0;
  else if (ena) begin
    if (counter < ticks)
      counter <= counter + 1;
    else if (counter == ticks) begin
      out <= 1;
      counter <=0;
    end
  end
end

endmodule
