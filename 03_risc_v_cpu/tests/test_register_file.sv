`default_nettype 
`timescale 1ns/1ps

module test_register_file;

logic clk, wr_ena;
logic [4:0] wr_addr;
logic [31:0] wr_data;

logic [4:0] rd_addr0, rd_addr1;
wire [31:0] rd_data0, rd_data1;

register_file UUT(
    .clk(clk), .wr_ena(wr_ena), .wr_addr(wr_addr), .wr_data(wr_data),
    .rd_addr0(rd_addr0), .rd_addr1(rd_addr1), .rd_data0(rd_data0), .rd_data1(rd_data1)
);

initial begin
    clk = 0;
    wr_ena = 0;
    wr_addr = 0;
    wr_data = 0;
    rd_addr0 = 0;
    rd_addr1 = 1;

    $dumpfile("test_results/register_file.vcd");
    $dumpvars(0, UUT);

    @(negedge clk);
    rd_addr0 = 0; rd_addr1 = 1;

    @(posedge clk);
    $display("@%t: read[%02d] = %x, read[%02d] = %x", $time, rd_addr0, rd_data0, rd_addr1, rd_data1);

    $finish;

end

always begin
    #5
    clk = ~clk;
end

endmodule