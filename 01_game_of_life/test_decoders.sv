`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_decoders;
  logic ena;
  logic [2:0] in;
  wire [7:0] out;

  decoder_3_to_8 UUT(ena, in, out);
  
  logic input_1_2;
  wire [1:0] output_1_2;
  decoder_1_to_2 UUT_1_2(
    .ena(ena),
    .in(input_1_2),
    .out(output_1_2)
  );
  
  always @(ena,output_1_2) begin
    if ((ena == 0) && (output_1_2 !== 2'b0)) begin
      $error("ena should turn off outputs!!!");
    end
  end
  
  // initial begin : testing_1_2_decoder
  //   $dumpfile("decoders.vcd");
  //   $dumpvars(0, UUT_1_2);
  //   ena = 1;
  //   $display("[d1:2] ena in | out");
  //   for (int i = 0; i < 2; i = i + 1) begin
  //     input_1_2 = i[0];
  //     #1 $display("[d1:2] %1b %1b | %2b", ena, input_1_2, output_1_2);
  //   end

  //   ena = 0;
  //   for (int i = 0; i < 2; i = i + 1) begin
  //     input_1_2 = i[0];
  //     #1 $display("[d1:2] %1b %1b | %2b", ena, input_1_2, output_1_2);
  //   end
        
  //   // $finish;      
    
  // end


  initial begin
    // Collect waveforms
    $dumpfile("decoders.vcd");
    $dumpvars(0, UUT);
    
    ena = 1;
    $display("ena in | out");
    for (int i = 0; i < 8; i = i + 1) begin
      in = i[2:0];
      #2 $display("%1b %2b | %4b", ena, in, out);
    end

    ena = 0;
    for (int i = 0; i < 8; i = i + 1) begin
      in = i[2:0];
      #2 $display("%1b %2b | %4b", ena, in, out);
    end
        
    $finish;      
	end
endmodule
