module test_adder32;
    logic [31:0] a;
    logic [31:0] b;
    wire [32:0] out;

    adder32 UUT(.a(a), .b(b), .sum(out));

    initial begin
        $dumpfile("adder32.vcd");
        $dumpvars(0, UUT);

        $display("a | b | sum");

        for (int i = 2147483640; i < 2147483648; i = i + 1) begin
            a = i;
            for (int j = 0; j < 2; j = j + 1) begin
                b = j;
                #2 $display("%32b | %32b | %33b", a, b, out);
            end
        end
        $finish;
    end
endmodule