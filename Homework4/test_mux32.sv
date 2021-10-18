module test_mux32;
    logic [31:0] in;
    logic [4:0] ena;
    wire out;

    mux32 UUT(.ena(ena), .in(in), .out(out));

    initial begin
        $dumpfile("mux32.vcd");
        $dumpvars(0, UUT);

        $display("ena | in | out");

        for (int i = 0; i < 4; i = i + 1) begin
            ena = i;
            for (int j = 0; j < 128; j = j + 1) begin
                in = j;
                #2 $display("%2b | %4b | %1b", ena, in, out);
            end
        end
        $finish;
    end
endmodule