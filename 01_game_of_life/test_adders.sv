`timescale 1ns / 1ps

`define SIMULATION

module test_adders;
    logic [2:0] a;
    logic [2:0] b;
    logic c;
    wire [3:0] out;

    adder3 ADDFUN(.a(a), .b(b), .c_in(c), .sum(out[2:0]), .c_out(out[3]));

    initial begin
        // Collect waveforms
        $dumpfile("adders.vcd");
        $dumpvars(0, ADDFUN);

        $display("a | b | c | out");
        for (int i = 0; i < 8; i = i + 1) begin
          a = i;
          for (int j = 0; j < 8; j = j + 1) begin
              b = j;
              for (int k = 0; k < 2; k = k + 1) begin
                  c = k;
                  #2 $display("%3b | %3b | %1b | %4b", a, b, c, out);
              end
          end
        end
        $finish;      
	end
endmodule