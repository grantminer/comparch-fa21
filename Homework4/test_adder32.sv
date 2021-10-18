`timescale 1ns/1ps
`default_nettype none
module test_adder32;

int errors = 0;

logic [31:0] a, b;
wire [32:0] sum;

adder32 UUT(.a(a), .b(b), .sum(sum));

logic [32:0] correct_sum;

always_comb begin : behavioural_solution_logic
  correct_sum = a + b;
end

// You can make "tasks" in testbenches. Think of them like methods of a class, 
// they have access to the member variables.
task print_io;
  $display("%d + %d = %d", a, b, sum);
endtask


// 2) the test cases
initial begin
  //$dumpfile("adder_n.vcd");
  //$dumpvars(0, UUT);
  
  $display("Specific interesting tests.");
  
  // Zero + zero 
  a = 0;
  b = 0;
  #1 print_io();

  // Overflow case
  a = (1 << (31));
  b = (1 << (31));
  #1 print_io();
  
  $display("Random testing.");
  for (int i = 0; i < 10; i = i + 1) begin : random_testing
    a = $random();
    b = $random();
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
always @(a,b) begin
  assert(sum === correct_sum) else begin
    $display("  ERROR: sum should be %d, is %d", correct_sum, sum);
    errors = errors + 1;
  end
end

endmodule