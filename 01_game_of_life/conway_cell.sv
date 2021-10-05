`default_nettype none

module conway_cell(clk, rst, ena, state_0, state_d, state_q, neighbors);
  input wire clk;
  input wire rst;
  input wire ena;

  input wire state_0;
  output logic state_d;
  output logic state_q;

  input wire [7:0] neighbors;
  wire [3:0] living_neighbors;
  wire [1:0] AB;
  wire [1:0] CD;
  wire [1:0] EF;
  wire [1:0] GH;
  wire [2:0] ABCD;
  wire [2:0] EFGH;

  adder1 AB1(.a(neighbors[0]), .b(neighbors[1]), .c_in(1'b0), .sum(AB[0]), .c_out(AB[1]));
  adder1 CD1(.a(neighbors[2]), .b(neighbors[3]), .c_in(1'b0), .sum(CD[0]), .c_out(CD[1]));
  adder1 EF1(.a(neighbors[4]), .b(neighbors[5]), .c_in(1'b0), .sum(EF[0]), .c_out(EF[1]));
  adder1 GH1(.a(neighbors[6]), .b(neighbors[7]), .c_in(1'b0), .sum(GH[0]), .c_out(GH[1]));

  adder2 ABCD2(.a(AB), .b(CD), .c_in(1'b0), .sum(ABCD[1:0]), .c_out(ABCD[2]));
  adder2 EFGH2(.a(EF), .b(GH), .c_in(1'b0), .sum(EFGH[1:0]), .c_out(EFGH[2]));

  adder3 allneighbors(.a(ABCD), .b(EFGH), .c_in(1'b0), .sum(living_neighbors[2:0]), .c_out(living_neighbors[3]));

  assign state_d = (~living_neighbors[3] & ~living_neighbors[2] & living_neighbors[1] & state_0) +
                  (~living_neighbors[3] & ~living_neighbors[2] & living_neighbors[1] & living_neighbors[0] &  ~state_0);

  always @(posedge clk) begin
    if(~rst & ena) begin
      state_q <= state_d;  
    end else if (~rst & ~ena) begin
      state_q <= state_q;
    end else begin
      state_q <= 1'b0;
    end
  end

endmodule