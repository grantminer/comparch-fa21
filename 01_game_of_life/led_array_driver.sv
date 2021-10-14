`default_nettype none // Overrides default behaviour (in a good way)

module led_array_driver(ena, x, cells, rows, cols);
  // Module I/O and parameters
  parameter N=8; // Size of Conway Cell Grid.
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
    cols = x_decoded; // Defines the "on" columns as the decoded input

    // Determines which rows in the specific activated column should be turned on 
    if (N == 3) begin // For 3x3 grid
      for (int i = 0; i < 3; i = i + 1) begin
        rows[i] = ~((cols[0] & cells[3*i]) | (cols[1] & cells[3*i+1]) | (cols[2] & cells[3*i+2]));
      end
    end else if (N == 5) begin // For 5x5 grid
      for (int i = 0; i < 5; i = i + 1) begin
        rows[i] = ~((cols[0] & cells[5*i]) | (cols[1] & cells[5*i+1]) | (cols[2] & cells[5*i+2]) | (cols[3] & cells[5*i+3]) | (cols[4] & cells[5*i+4]));
      end
    end else if (N == 8) begin // For 8x8 grid
      for (int i = 0; i < 8; i = i + 1) begin
        rows[i] = ~((cols[0] & cells[8*i]) | (cols[1] & cells[8*i+1]) | (cols[2] & cells[8*i+2]) | (cols[3] & cells[8*i+3]) | (cols[4] & cells[8*i+4]) | (cols[5] & cells[8*i+5]) | (cols[6] & cells[8*i+6]) | (cols[7] & cells[8*i+7]));
      end
    end else begin // Fills column with ones if N does not match prepared statements
      for (int i = 0; i < N; i = i + 1) begin
        rows[i] = 1'b1;
      end
    end

  end
  
endmodule

`default_nettype wire // reengages default behaviour, needed when using 
                      // other designs that expect it.