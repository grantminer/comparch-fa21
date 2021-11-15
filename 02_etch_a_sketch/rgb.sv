module rgb(clk, rst, button, rgb);

    input wire clk;
    input wire rst;
    input wire button;
    output [2:0] rgb;
    
    wire step;
    wire [1:0] state;

    edgedetect BUTTON(.clk(clk), .button(button), .pressed(step));

    always_ff @(posedge clk) begin
        if (rst) begin
            state[0] <= 0;
            state[1] <= 0;
        end else if (step) begin
            state[0] <= ~state[1] & ~state[0];
            state[1] <= ~state[1] & state[0];
        end
    end

    always_comb begin
        rgb[0] = 
    end
    

endmodule