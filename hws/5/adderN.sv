module adderN(a, b, carry0, sum);

    parameter N = 32;

    input wire [N-1:0]a;
    input wire [N-1:0]b;
    input wire carry0;

    output wire [N:0]sum;

    wire [N-1:0] inter_sum;

    wire [N:0] carry;
    wire [N-1:0] gen;
    wire [N-1:0] prop;

    assign carry[0] = carry0;

    genvar i;
    generate 
        for (i = 0; i < N; i = i + 1) begin
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
        for (j = 0; j < N; j = j + 1) begin
            assign gen[j] = a[j] & b[j];

            assign prop[j] = a[j] | b[j];
            
            assign carry[j + 1] = gen[j] | (prop[j] & carry[j]);
        end
    endgenerate

    assign sum = {carry[N], inter_sum[N-1:0]};

endmodule