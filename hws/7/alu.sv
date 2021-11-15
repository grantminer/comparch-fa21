`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"

module alu(a, b, control, result, overflow, zero, equal);
parameter N = 32; // Don't need to support other numbers, just using this as a constant.

input wire [N-1:0] a, b; // Inputs to the ALU.
input alu_control_t control; // Sets the current operation.
output logic [N-1:0] result; // Result of the selected operation.

output logic overflow; // Is high if the result of an ADD or SUB wraps around the 32 bit boundary.
output logic zero;  // Is high if the result is ever all zeros.
output logic equal; // is high if a == b.

// Use *only* structural logic and previously defined modules to implement an 
// ALU that can do all of operations defined in alu_types.sv's alu_op_code_t!

wire [N-1:0] sll_out;
wire [N-1:0] sra_out;
wire [N-1:0] srl_out;
wire [N-1:0] add_out;
wire add_carry;
wire [N-1:0] sub_out;
wire sub_carry;
wire slt_out;
wire sltu_out;
wire slt_over;
wire sltu_over;
// wire b_to_shamt;

// encoder #(.N(N)) shamt_calc(.encode(b), .out(b_to_shamt));
shift_left_logical sll(.in(a), .shamt(b), .out(sll_out));
shift_right_logical srl (.in(a), .shamt(b), .out(srl_out));
shift_right_arithmetic sra (.in(a), .shamt(b), .out(sra_out));
adder_n #(.N(N)) adder (.a(a), .b(b), .c_in(1'b0), .sum(add_out), .c_out(add_carry));
adder_n #(.N(N)) sub (.a(a), .b(~b), .c_in(1'b1), .sum(sub_out), .c_out(sub_carry));
slt #(.N(N)) slt (.a(a), .b(b), .out(slt_out), .over(slt_over));
slt #(.N(N+1)) sltu (.a({1'b0,a}), .b({1'b0,b}), .out(sltu_out), .over(sltu_over));

mux16 operation (.in1(a & b), .in2(a | b), .in3(a ^ b), .in5(sll_out), .in6(srl_out),
                 .in7(sra_out), .in8(add_out), .in12(sub_out), .in13(slt_out), .in15(sltu_out), 
                 .switch(control), .out(result));

always_comb begin
    overflow = (add_carry & control[3] & ~control[2:0]) | (sub_carry & control[3:2] & ~control[1:0])
               | (slt_over & control[3:2] & ~control[1] & control[0]) | (sltu_over & control);
    zero = &(~result);
    equal = &(~sub_out);

end

endmodule