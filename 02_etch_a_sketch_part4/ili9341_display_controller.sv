`include "ili9341_defines.sv"
`include "spi_types.sv"
`include "ft6206_defines.sv"

/*
Display controller for the ili9341 chip on Adafruit's breakout baord.
Based on logic from: https://github.com/adafruit/Adafruit_ILI9341

*/

module ili9341_display_controller(
  clk, rst, ena, display_rstb,
  interface_mode,
  spi_csb, spi_clk, spi_mosi, spi_miso, data_commandb,
  vsync, hsync,
  touch,
  vram_rd_addr, vram_rd_data
);

parameter CLK_HZ = 12_000_000; // aka ticks per second
parameter DISPLAY_WIDTH = 240;
parameter DISPLAY_HEIGHT = 320;
parameter VRAM_L = DISPLAY_HEIGHT*DISPLAY_WIDTH;
parameter CFG_CMD_DELAY = CLK_HZ*150/1000; // wait 150ms after certain configuration commands
parameter ROM_LENGTH=125; // Set this based on the output of generate_memories.py

input wire clk, rst, ena;
output logic display_rstb; // Need a separate value because the display has an opposite reset polarity.
always_comb display_rstb = ~rst; // Fix the active low reset

// SPI Interface
output logic spi_csb, spi_clk, spi_mosi;// chip select bar, clock, // Main Out Secondary In (sends serial data to secondary device)
input wire spi_miso; // Main In Secondary Out (receives serial data from secondary device)

// Sets the mode (many parallel and serial options, see page 10 of the datasheet).
output logic [3:0] interface_mode; // 
always_comb interface_mode = 4'b1110; // Standard SPI 8-bit mode is 4'b1110.

output logic data_commandb; // Set to 1 to send data, 0 to send commands. Read as Data/Command_Bar

output logic vsync; // Should combinationally be high for one clock cycle when drawing the last pixel (239,319)
output logic hsync; // Should combinationally be high for one clock cycle when drawing the last pixel of any row (x = 239).

input touch_t touch; // Current touch event. 

input ILI9341_color_t vram_rd_data; // VRAM rd data
output logic [$clog2(VRAM_L)-1:0] vram_rd_addr; // VRAM rd addr.

// SPI Controller that talks to the ILI9341 chip
spi_transaction_t spi_mode; // Whether reading and/or writing and how much
wire i_ready; // controller ready to accept data
logic i_valid; // data is available
logic [15:0] i_data; // input data
logic o_ready; // unused
wire o_valid; // goes low when new transaction begins
wire [23:0] o_data; // result of read
wire [4:0] spi_bit_counter; // incrementer for "loop"
spi_controller SPI0(
    .clk(clk), .rst(rst), 
    .sclk(spi_clk), .csb(spi_csb), .mosi(spi_mosi), .miso(spi_miso),
    .spi_mode(spi_mode), .i_ready(i_ready), .i_valid(i_valid), .i_data(i_data),
    .o_ready(o_ready), .o_valid(o_valid), .o_data(o_data),
    .bit_counter(spi_bit_counter)
);

// ROM that stores the configuration sequence the display needs
wire [7:0] rom_data; // data read from rom
logic [$clog2(ROM_LENGTH)-1:0] rom_addr; // address or read data
block_rom #(.INIT("memories/ili9341_init.memh"), .W(8), .L(ROM_LENGTH)) ILI9341_INIT_ROM (
  .clk(clk), .addr(rom_addr), .data(rom_data)
);


// Main FSM
enum logic [2:0] {
  S_INIT = 0, 
  S_INCREMENT_PIXEL = 1, 
  S_START_FRAME = 2,
  S_TX_PIXEL_DATA_START = 3, 
  S_TX_PIXEL_DATA_BUSY = 4, // Unused
  S_WAIT_FOR_SPI = 5,
  S_ERROR //very useful for debugging
} state, state_after_wait;

// Configuration FSM
enum logic [2:0] {
  S_CFG_GET_DATA_SIZE = 0,
  S_CFG_GET_CMD = 1,
  S_CFG_SEND_CMD = 2,
  S_CFG_GET_DATA = 3, 
  S_CFG_SEND_DATA = 4,
  S_CFG_SPI_WAIT = 5,
  S_CFG_MEM_WAIT = 6,
  S_CFG_DONE
} cfg_state, cfg_state_after_wait;

ILI9341_color_t pixel_color; // basic color options
// bit size based on width and height of screen
logic [$clog2(DISPLAY_WIDTH):0] pixel_x; 
logic [$clog2(DISPLAY_HEIGHT):0] pixel_y;

ILI9341_register_t current_command; // commands to be sent

// Comb. outputs
/* Note - it's pretty critical that you keep always_comb blocks small and separate.
   there's a weird order of operations that can mess up your synthesis or simulation.  
*/

always_comb case(state)
// setting data to available in  certain states like the start state and the pixel data start state
// default state is that data is not available
  S_START_FRAME, S_TX_PIXEL_DATA_START : i_valid = 1; 
  S_INIT : begin
    case(cfg_state)
      S_CFG_SEND_CMD, S_CFG_SEND_DATA: i_valid = 1; 
      default: i_valid = 0;
    endcase
  end
  default: i_valid = 0;
endcase
  
always_comb case (state) 
  S_START_FRAME : current_command = RAMWR; // write memory in start frame state
  default : current_command = NOP; // do nothing as the default
endcase

always_comb case(state)
  S_INIT: i_data = {8'd0, rom_data}; // makes pixel color LSBs of data string
  S_START_FRAME: i_data = {8'd0, current_command}; // makes command LSBs of data string
  default: i_data = pixel_color; // sets data to the raw color
endcase

always_comb case (state)
  S_INIT, S_START_FRAME: spi_mode = WRITE_8; // setting the spi mode which leads to a 8 bit counter
  default : spi_mode = WRITE_16; // setting the spi mode which leads to a 16 bit counter as the default
endcase

always_comb begin
  hsync = pixel_x == (DISPLAY_WIDTH-1); // if any pixel in last column
  vsync = hsync & (pixel_y == (DISPLAY_HEIGHT-1)); // if bottom corner (max index in row and col)
end

always_comb begin  : draw_cursor_logic
  vram_rd_addr = pixel_y*DISPLAY_WIDTH + pixel_x; // From solutions
  // if the current touch event matches the pixel, then color that pixel red
  if(touch.valid & (touch.x[8:2] == pixel_x[8:2]) 
    & (touch.y[8:2] == pixel_y[8:2])) begin
    pixel_color = RED; // make touched pixel white // RED after our modifications
  end else begin
    // Have this draw from memory using rd_addr and rd_data
    pixel_color = vram_rd_data; // From solutions
  end
end

logic [$clog2(CFG_CMD_DELAY):0] cfg_delay_counter; // clock divider
logic [7:0] cfg_bytes_remaining;

always_ff @(posedge clk) begin : main_fsm
  // set everything to the initial state when reset
  if(rst) begin
    state <= S_INIT;
    cfg_state <= S_CFG_GET_DATA_SIZE;
    cfg_state_after_wait <= S_CFG_GET_DATA_SIZE;
    cfg_delay_counter <= 0;
    state_after_wait <= S_INIT;
    pixel_x <= 0;
    pixel_y <= 0;
    rom_addr <= 0;
    data_commandb <= 1; // sending data
  end
  // end else if (button) begin // command should invert display, focusing on annotation over implementing this functionality
  //   data_commandb <= 8'h21;
  // end
  else if(ena) begin
    case (state)
      S_INIT: begin
        case (cfg_state)
          S_CFG_GET_DATA_SIZE : begin
            cfg_state_after_wait <= S_CFG_GET_CMD; // moving to getting command after the wait
            cfg_state <= S_CFG_MEM_WAIT; //setting to this state allows for checks to wait until data is ready
            rom_addr <= rom_addr + 1; // move to next pixel value
            case(rom_data) 
              8'hFF: begin // if data at address = 11111111
                cfg_bytes_remaining <= 0; // no more configuration to read
                cfg_delay_counter <= CFG_CMD_DELAY; // sets delay to 150 ms
              end
              8'h00: begin 
                cfg_bytes_remaining <= 0; // no more configuration to read
                cfg_delay_counter <= 0; // sets delay to 0 ms
                cfg_state <= S_CFG_DONE; // finished configuring rom (?)
              end
              default: begin
                cfg_bytes_remaining <= rom_data; //the default configuration to read is the rom data
                cfg_delay_counter <= 0; // sets delay to 0 ms
              end
            endcase
          end
          S_CFG_GET_CMD: begin
            cfg_state_after_wait <= S_CFG_SEND_CMD; // need to send command after getting command
            cfg_state <= S_CFG_MEM_WAIT; // setting to this state allows for checks to wait until data is ready
          end
          S_CFG_SEND_CMD : begin
            data_commandb <= 0; // Sending commands to display
            if(rom_data == 0) begin
              cfg_state <= S_CFG_DONE; // if there is no rom data, set the configuration state to done
            end else begin
              cfg_state <= S_CFG_SPI_WAIT; 
              cfg_state_after_wait <= S_CFG_GET_DATA; // if there is rom data, set the configuration state to get data
            end
          end
          S_CFG_GET_DATA: begin
            data_commandb <= 1; // Sending data to display
            rom_addr <= rom_addr + 1; // moving to the next pixel value
            // continue to send data to display and stay in the same state until 
            // there are no configuration bytes left to send
            if(cfg_bytes_remaining > 0) begin 
              cfg_state_after_wait <= S_CFG_SEND_DATA; 
              cfg_state <= S_CFG_MEM_WAIT;
              cfg_bytes_remaining <= cfg_bytes_remaining - 1; 
            // go back to the getting configuration data size state once all the 
            // data is sent to the display
            end else begin
              cfg_state_after_wait <= S_CFG_GET_DATA_SIZE;
              cfg_state <= S_CFG_MEM_WAIT;
            end
          end
          S_CFG_SEND_DATA: begin  
            // keep going between getting data and sending data states until there 
            // are no configuration bytes remaining          
            cfg_state_after_wait <= S_CFG_GET_DATA; 
            cfg_state <= S_CFG_SPI_WAIT;
          end
          S_CFG_DONE : begin
            state <= S_START_FRAME; // Switch out of configuration
          end
          S_CFG_SPI_WAIT : begin
            // the state becomes the state after wait once the delay 
            // counter is finished
            if(cfg_delay_counter > 0) cfg_delay_counter <= cfg_delay_counter-1;
            else if (i_ready) begin
               cfg_state <= cfg_state_after_wait;
               cfg_delay_counter <= 0;
               data_commandb <= 1; // Sending data to display
            end
          end
          S_CFG_MEM_WAIT : begin
            // If you had a memory with larger or unknown latency you would put checks in this state to wait till the data was ready.
            cfg_state <= cfg_state_after_wait;
          end
          default: cfg_state <= S_CFG_DONE; // default state is finished configuration
        endcase
      end
      S_WAIT_FOR_SPI: begin
        if(i_ready) begin
          state <= state_after_wait; // if ready to accept data, continue
        end
      end
      S_START_FRAME: begin
        data_commandb <= 0; // Sending commands to display
        state <= S_WAIT_FOR_SPI; // check if ready for data before moving on to tx
        state_after_wait <= S_TX_PIXEL_DATA_START;
      end
      S_TX_PIXEL_DATA_START: begin
        data_commandb <= 1; // Sending data to display
        state_after_wait <= S_INCREMENT_PIXEL;
        state <= S_WAIT_FOR_SPI; // check if ready for data before incrementing
      end
      S_TX_PIXEL_DATA_BUSY: begin // Never used state
        if(i_ready) state <= S_INCREMENT_PIXEL; // if ready for data, continue to increment
      end
      S_INCREMENT_PIXEL: begin // loops through pixels to look for touch      
        state <= S_TX_PIXEL_DATA_START;// alternate between sending data to display and incrementing pixels states
        if(pixel_x < (DISPLAY_WIDTH-1)) begin // moves from left to right
          pixel_x <= pixel_x + 1;
        end else begin
          pixel_x <= 0; // resets to left edge of display
          if (pixel_y < (DISPLAY_HEIGHT-1)) begin // moves down one column
            pixel_y <= pixel_y + 1;
          end else begin
            pixel_y <= 0; // resets to top left corner
            state <= S_START_FRAME;
          end
        end
      end
      default: begin
        state <= S_ERROR; // Nothing happens as a result of this change. Everything stops
        pixel_y <= -1; // invalid pixel values
        pixel_x <= -1;
      end
    endcase
  end
end

endmodule