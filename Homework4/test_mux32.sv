`timescale 1ns/1ps
`default_nettype none
module test_mux32;

int errors = 0;

logic [31:0] in;
logic [4:0] ena;
wire out;

mux32 UUT(.ena(ena), .in(in), .out(out));

logic correct_val;

always_comb begin : behavioural_solution_logic
  correct_val = in[ena];
end

// You can make "tasks" in testbenches. Think of them like methods of a class, 
// they have access to the member variables.
task print_io;
  $display("%b[%d] = %b", in, ena, out);
endtask


// 2) the test cases
initial begin
  //$dumpfile("adder_n.vcd");
  //$dumpvars(0, UUT);
  
  $display("Random testing.");
  for (int i = 0; i < 10; i = i + 1) begin : random_testing
    ena = $random();
    in = $random();
    #1 print_io();
  end
  if (errors !== 0) begin
    $display("---------------------------------------------------------------");
    $display("-- FAILURE                                                   --");
    $display("---------------------------------------------------------------");
    $display(" %d failures found, try again!", errors);
  end else begin
    $display("---------------------------------------------------------------");
    $display("-- SUCCESS                                                   --");
    $display("---------------------------------------------------------------");
  end
  $finish;
end

// Note: the triple === (corresponding !==) check 4-state (e.g. 0,1,x,z) values.
//       It's best practice to use these for checkers!
always @(ena, in) begin
  assert(out === correct_val) else begin
    $display("  ERROR: sum should be %d, is %d", correct_val, out);
    errors = errors + 1;
  end
end

endmodule