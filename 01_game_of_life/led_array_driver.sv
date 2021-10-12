`default_nettype none // Overrides default behaviour (in a good way)

module led_array_driver(ena, x, cells, rows, cols);
  // Module I/O and parameters
  parameter N=5; // Size of Conway Cell Grid.
  parameter ROWS=N;
  parameter COLS=N;

  // I/O declarations
  input wire ena;
  input wire [$clog2(N):0] x;
  input wire [N*N-1:0] cells;
  output logic [N-1:0] rows;
  output logic [N-1:0] cols;

  // You can check parameters with the $error macro within initial blocks.
  initial begin
    if ((N <= 0) || (N > 8)) begin
      $error("N must be within 0 and 8.");
    end
    if (ROWS != COLS) begin
      $error("Non square led arrays are not supported. (%dx%d)", ROWS, COLS);
    end
    if (ROWS < N) begin
      $error("ROWS/COLS must be >= than the size of the Conway Grid.");
    end
  end

  wire [N-1:0] x_decoded;
  decoder_3_to_8 COL_DECODER(ena, x, x_decoded);

  always_comb begin
    rows[0] = (ena & x_decoded[0] & cells[0] & ~rows[0]);
    rows[1] = (ena & x_decoded[0] & cells[5] & ~rows[1]);
    rows[2] = (ena & x_decoded[0] & cells[10] & ~rows[2]);
    rows[3] = (ena & x_decoded[0] & cells[15] & ~rows[3]);
    rows[4] = (ena & x_decoded[0] & cells[20] & ~rows[4]);

    rows[0] = (ena & x_decoded[1] & cells[1] & ~rows[0]);
    rows[1] = (ena & x_decoded[1] & cells[6] & ~rows[1]);
    rows[2] = (ena & x_decoded[1] & cells[11] & ~rows[2]);
    rows[3] = (ena & x_decoded[1] & cells[16] & ~rows[3]);
    rows[4] = (ena & x_decoded[1] & cells[21] & ~rows[4]);

    rows[0] = (ena & x_decoded[2] & cells[2] & ~rows[0]);
    rows[1] = (ena & x_decoded[2] & cells[7] & ~rows[1]);
    rows[2] = (ena & x_decoded[2] & cells[12] & ~rows[2]);
    rows[3] = (ena & x_decoded[2] & cells[17] & ~rows[3]);
    rows[4] = (ena & x_decoded[2] & cells[22] & ~rows[4]);

    rows[0] = (ena & x_decoded[3] & cells[3] & ~rows[0]);
    rows[1] = (ena & x_decoded[3] & cells[8] & ~rows[1]);
    rows[2] = (ena & x_decoded[3] & cells[13] & ~rows[2]);
    rows[3] = (ena & x_decoded[3] & cells[18] & ~rows[3]);
    rows[4] = (ena & x_decoded[3] & cells[23] & ~rows[4]);

    rows[0] = (ena & x_decoded[4] & cells[4] & ~rows[0]);
    rows[1] = (ena & x_decoded[4] & cells[9] & ~rows[1]);
    rows[2] = (ena & x_decoded[4] & cells[14] & ~rows[2]);
    rows[3] = (ena & x_decoded[4] & cells[19] & ~rows[3]);
    rows[4] = (ena & x_decoded[4] & cells[24] & ~rows[4]);

    cols[0] = ena & x_decoded[0];
    cols[1] = ena & x_decoded[1];
    cols[2] = ena & x_decoded[2];
    cols[3] = ena & x_decoded[3];
    cols[4] = ena & x_decoded[4];

  end
  
endmodule

`default_nettype wire // reengages default behaviour, needed when using 
                      // other designs that expect it.