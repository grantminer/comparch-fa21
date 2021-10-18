module adder32(a, b, sum);
    input wire [31:0]a;
    input wire [31:0]b;

    output wire [32:0]sum;

    wire [31:0] inter_sum;

    wire [32:0] carry;
    wire [31:0] gen;
    wire [31:0] prop;

    assign carry[0] = 1'b0;

    genvar i;
    generate 
        for (i = 0; i < 32; i = i + 1) begin
            adder1 adder_(
                .a(a[i]),
                .b(b[i]),
                .c_in(carry[i]),
                .sum(inter_sum[i]),
                .c_out()
            );
        end
    endgenerate
    
    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin
            assign gen[j] = a[j] & b[j];

            assign prop[j] = a[j] | b[j];
            
            assign carry[j + 1] = gen[j] | (prop[j] & carry[j]);
        end
    endgenerate

    assign sum = {carry[32], inter_sum[31:0]};

endmodule