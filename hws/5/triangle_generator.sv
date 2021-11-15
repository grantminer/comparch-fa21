// Generates "triangle" waves (counts from 0 to 2^N-1, then back down again)
// The triangle should increment/decrement only if the ena signal is high, and hold its value otherwise.
module triangle_generator(clk, rst, ena, out);

parameter N = 8;
input wire clk, rst, ena;
output logic [N-1:0] out;

typedef enum logic {COUNTING_UP, COUNTING_DOWN} state_t;
state_t state;

always_comb begin
    out = 0;
    state = COUNTING_UP;
end

always_ff @(posedge clk) begin
    if (rst) begin
        out <= 0;
    end


    if (ena & ~state) begin
        out <= out + 1;
    end else if (ena & state) begin
        out <= out - 1;
    end else begin
        out <= out;
    end

    if (~state & out == 2**(N-1))
        state <= 1;
    else if (state & (out == 0)) begin
        state <= 0;
        out <= 1;
    end
end

endmodule