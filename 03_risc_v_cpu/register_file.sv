module register_file (
    clk, wr_ena, wr_addr, wr_data,
    rd_addr0, rd_data0, rd_addr1, rd_data1,
);

input wire clk, wr_ena;
input wire [4:0] wr_addr;
input wire [31:0] wr_data;

input wire [4:0] rd_addr0, rd_addr1;
output logic [31:0] rd_data0, rd_data1;

wire [31:0] x00, x01, x02, x03, x04, x05,
             x06, x07, x08, x09, x10, x11,
             x12, x13, x14, x15, x16, x17,
             x18, x19, x20, x21, x22, x23,
             x24, x25, x26, x27, x28, x29,
             x30, x31;

logic [31:0] wr_enas;

always_comb x00 = 32'd0; // x00 to ground

always_comb begin : read_mux0
    case(rd_addr0)
        5'd00 : rd_data0 = x00;
        5'd01 : rd_data0 = x01;
        5'd02 : rd_data0 = x02;
        5'd03 : rd_data0 = x03;
        5'd04 : rd_data0 = x04;
        5'd05 : rd_data0 = x05;
        5'd06 : rd_data0 = x06;
        5'd07 : rd_data0 = x07;
        5'd08 : rd_data0 = x08;
        5'd09 : rd_data0 = x09;
        5'd10 : rd_data0 = x10;
        5'd11 : rd_data0 = x11;
        5'd12 : rd_data0 = x12;
        5'd13 : rd_data0 = x13;
        5'd14 : rd_data0 = x14;
        5'd15 : rd_data0 = x15;
        5'd16 : rd_data0 = x16;
        5'd17 : rd_data0 = x17;
        5'd18 : rd_data0 = x18;
        5'd19 : rd_data0 = x19;
        5'd20 : rd_data0 = x20;
        5'd21 : rd_data0 = x21;
        5'd22 : rd_data0 = x22;
        5'd23 : rd_data0 = x23;
        5'd24 : rd_data0 = x24;
        5'd25 : rd_data0 = x25;
        5'd26 : rd_data0 = x26;
        5'd27 : rd_data0 = x27;
        5'd28 : rd_data0 = x28;
        5'd29 : rd_data0 = x29;
        5'd30 : rd_data0 = x30;
        5'd31 : rd_data0 = x31;
    endcase
end

always_comb begin : read_mux1
    case(rd_addr1)
        5'd00 : rd_data1 = x00;
        5'd01 : rd_data1 = x01;
        5'd02 : rd_data1 = x02;
        5'd03 : rd_data1 = x03;
        5'd04 : rd_data1 = x04;
        5'd05 : rd_data1 = x05;
        5'd06 : rd_data1 = x06;
        5'd07 : rd_data1 = x07;
        5'd08 : rd_data1 = x08;
        5'd09 : rd_data1 = x09;
        5'd10 : rd_data1 = x10;
        5'd11 : rd_data1 = x11;
        5'd12 : rd_data1 = x12;
        5'd13 : rd_data1 = x13;
        5'd14 : rd_data1 = x14;
        5'd15 : rd_data1 = x15;
        5'd16 : rd_data1 = x16;
        5'd17 : rd_data1 = x17;
        5'd18 : rd_data1 = x18;
        5'd19 : rd_data1 = x19;
        5'd20 : rd_data1 = x20;
        5'd21 : rd_data1 = x21;
        5'd22 : rd_data1 = x22;
        5'd23 : rd_data1 = x23;
        5'd24 : rd_data1 = x24;
        5'd25 : rd_data1 = x25;
        5'd26 : rd_data1 = x26;
        5'd27 : rd_data1 = x27;
        5'd28 : rd_data1 = x28;
        5'd29 : rd_data1 = x29;
        5'd30 : rd_data1 = x30;
        5'd31 : rd_data1 = x31;
    endcase
end

always_comb begin : write_enable_decoder
    if (wr_ena) begin
        case(wr_addr)
            5'd00 : wr_ena = x00;
            5'd01 : wr_ena = x01;
            5'd02 : wr_ena = x02;
            5'd03 : wr_ena = x03;
            5'd04 : wr_ena = x04;
            5'd05 : wr_ena = x05;
            5'd06 : wr_ena = x06;
            5'd07 : wr_ena = x07;
            5'd08 : wr_ena = x08;
            5'd09 : wr_ena = x09;
            5'd10 : wr_ena = x10;
            5'd11 : wr_ena = x11;
            5'd12 : wr_ena = x12;
            5'd13 : wr_ena = x13;
            5'd14 : wr_ena = x14;
            5'd15 : wr_ena = x15;
            5'd16 : wr_ena = x16;
            5'd17 : wr_ena = x17;
            5'd18 : wr_ena = x18;
            5'd19 : wr_ena = x19;
            5'd20 : wr_ena = x20;
            5'd21 : wr_ena = x21;
            5'd22 : wr_ena = x22;
            5'd23 : wr_ena = x23;
            5'd24 : wr_ena = x24;
            5'd25 : wr_ena = x25;
            5'd26 : wr_ena = x26;
            5'd27 : wr_ena = x27;
            5'd28 : wr_ena = x28;
            5'd29 : wr_ena = x29;
            5'd30 : wr_ena = x30;
            5'd31 : wr_ena = x31;
        endcase
    end else begin
        wr_enas = 32'b00;
    end
end

register #(.N(32)) r_x01(.clk(clk), .rst(1'b0), .q(x01), .d(wr_data), .ena(wr_enas[01]));
register #(.N(32)) r_x02(.clk(clk), .rst(1'b0), .q(x02), .d(wr_data), .ena(wr_enas[02]));
register #(.N(32)) r_x03(.clk(clk), .rst(1'b0), .q(x03), .d(wr_data), .ena(wr_enas[03]));
register #(.N(32)) r_x04(.clk(clk), .rst(1'b0), .q(x04), .d(wr_data), .ena(wr_enas[04]));
register #(.N(32)) r_x05(.clk(clk), .rst(1'b0), .q(x05), .d(wr_data), .ena(wr_enas[05]));
register #(.N(32)) r_x06(.clk(clk), .rst(1'b0), .q(x06), .d(wr_data), .ena(wr_enas[06]));
register #(.N(32)) r_x07(.clk(clk), .rst(1'b0), .q(x07), .d(wr_data), .ena(wr_enas[07]));
register #(.N(32)) r_x08(.clk(clk), .rst(1'b0), .q(x08), .d(wr_data), .ena(wr_enas[08]));
register #(.N(32)) r_x09(.clk(clk), .rst(1'b0), .q(x09), .d(wr_data), .ena(wr_enas[09]));
register #(.N(32)) r_x10(.clk(clk), .rst(1'b0), .q(x10), .d(wr_data), .ena(wr_enas[10]));
register #(.N(32)) r_x11(.clk(clk), .rst(1'b0), .q(x11), .d(wr_data), .ena(wr_enas[11]));
register #(.N(32)) r_x12(.clk(clk), .rst(1'b0), .q(x12), .d(wr_data), .ena(wr_enas[12]));
register #(.N(32)) r_x13(.clk(clk), .rst(1'b0), .q(x13), .d(wr_data), .ena(wr_enas[13]));
register #(.N(32)) r_x14(.clk(clk), .rst(1'b0), .q(x14), .d(wr_data), .ena(wr_enas[14]));
register #(.N(32)) r_x15(.clk(clk), .rst(1'b0), .q(x15), .d(wr_data), .ena(wr_enas[15]));
register #(.N(32)) r_x16(.clk(clk), .rst(1'b0), .q(x16), .d(wr_data), .ena(wr_enas[16]));
register #(.N(32)) r_x17(.clk(clk), .rst(1'b0), .q(x17), .d(wr_data), .ena(wr_enas[17]));
register #(.N(32)) r_x18(.clk(clk), .rst(1'b0), .q(x18), .d(wr_data), .ena(wr_enas[18]));
register #(.N(32)) r_x19(.clk(clk), .rst(1'b0), .q(x19), .d(wr_data), .ena(wr_enas[19]));
register #(.N(32)) r_x20(.clk(clk), .rst(1'b0), .q(x20), .d(wr_data), .ena(wr_enas[20]));
register #(.N(32)) r_x21(.clk(clk), .rst(1'b0), .q(x21), .d(wr_data), .ena(wr_enas[21]));
register #(.N(32)) r_x22(.clk(clk), .rst(1'b0), .q(x22), .d(wr_data), .ena(wr_enas[22]));
register #(.N(32)) r_x23(.clk(clk), .rst(1'b0), .q(x23), .d(wr_data), .ena(wr_enas[23]));
register #(.N(32)) r_x24(.clk(clk), .rst(1'b0), .q(x24), .d(wr_data), .ena(wr_enas[24]));
register #(.N(32)) r_x25(.clk(clk), .rst(1'b0), .q(x25), .d(wr_data), .ena(wr_enas[25]));
register #(.N(32)) r_x26(.clk(clk), .rst(1'b0), .q(x26), .d(wr_data), .ena(wr_enas[26]));
register #(.N(32)) r_x27(.clk(clk), .rst(1'b0), .q(x27), .d(wr_data), .ena(wr_enas[27]));
register #(.N(32)) r_x28(.clk(clk), .rst(1'b0), .q(x28), .d(wr_data), .ena(wr_enas[28]));
register #(.N(32)) r_x29(.clk(clk), .rst(1'b0), .q(x29), .d(wr_data), .ena(wr_enas[29]));
register #(.N(32)) r_x30(.clk(clk), .rst(1'b0), .q(x30), .d(wr_data), .ena(wr_enas[30]));
register #(.N(32)) r_x31(.clk(clk), .rst(1'b0), .q(x31), .d(wr_data), .ena(wr_enas[31]));


endmodule