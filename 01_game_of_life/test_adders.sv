`timescale 1ns / 1ps
`default_nettype NONE

`define SIMULATION

module test_adders;
    logic a;
    logic b;
    logic c;
    wire [1:0] out;

    adder1 ADDFUN(.a(a), .b(b), .c_in(c), .sum(out[0]), .c_out(out[1]));

    initial begin
    // Collect waveforms
    $dumpfile("adders.vcd");
    $dumpvars(0, ADDFUN);

    $display("a | b | c | sum | out");
    for (int i = 0; i < 1; i = i + 1) begin
      a = i;
      for (int j = 0; j < 1; j = j + 1) begin
          b = j;
          for (int k = 0; k < 1; k = k + 1) begin
              c = k;
              #2 $display("%1b | %1b | %1b | %2b", a, b, c, out);
          end
      end
    end
    $finish;      
	end
endmodule