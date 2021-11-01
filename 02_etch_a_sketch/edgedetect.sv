module edgedetect(clk, button, pressed);

    input wire clk;
    input wire button;
    output logic pressed;

    always_ff @(posedge clk) begin
        pressed <= ~pressed & button;
    end
endmodule