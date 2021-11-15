`timescale 1ns / 1ps
`default_nettype none

`include "i2c_types.sv"

// TI has a good reference on how i2c works: https://training.ti.com/sites/default/files/docs/slides-i2c-protocol.pdf
// In this guide the "main" device is called the "controller" and the "secondary" device is called the "target".
module i2c_controller(
  clk, rst,
  scl, sda, mode,
  i_ready, i_valid, i_addr, i_data,
  o_ready, o_valid, o_data
);

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2C_CLK_HZ = 400_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
`ifdef SIMULATION
parameter COOLDOWN_CYCLES = 12; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`else
parameter COOLDOWN_CYCLES = 120; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`endif // SIMULATION

//Module I/O and parameters
input wire clk, rst; // standard signals
output logic scl; // i2c signals
inout wire sda;

// Create a tristate for the sda input/output pin.
// Tristates let you go into "high impedance" mode which allows the secondary device to use the same wire to send data back!
// It's your job to drive sda_oe (output enable) low (combinationally) when it's the secondary's turn to talk.
logic sda_oe; // output enable for the sda tristate
logic sda_out; // input to the tristate
assign sda = sda_oe ? sda_out : 1'bz; // Needs to be an assign for icarus verilog.

input wire i2c_transaction_t mode; // See i2c_types.sv, 0 is WRITE and 1 is READ
output logic i_ready; // ready/valid handshake signals
input wire i_valid;
input wire [6:0] i_addr; // the address of the secondary device.
input wire [7:0] i_data; // data to be sent on a WRITE opearation
input wire o_ready; // unused (for now)
output logic o_valid; // high when data is valid. Should stay high until a new i_valid starts a new transaction.
output logic [7:0] o_data; // the result of a read transaction (can be x's on a write).

// Main FSM logic
i2c_state_t state; // see i2c_types for the canonical states.

logic [$clog2(DIVIDER_COUNT):0] clk_divider_counter;
logic [$clog2(COOLDOWN_CYCLES):0] cooldown_counter; // optional, but recommended - have the system wait a few clk cycles before i_ready goes high again - this can make debugging STOP/ACK/START issues way easier!!!
logic [3:0] bit_counter;
logic [7:0] addr_buffer;
logic [7:0] data_buffer;

always_ff @(posedge clk) begin : i2c_fsm  
  if(rst) begin
    clk_divider_counter <= DIVIDER_COUNT-1; // maximizes clock value for counter
    scl <= 1; // sets scl high in preparation for start sequence
    bit_counter <= 0;
    o_data <= 0;
    o_valid <= 0;
    i_ready <= 1; //communicates that unit is ready data
    state <= S_IDLE; // initializes state to wait for data
  end else begin // out of reset
// SOlUTION START
    if(state == S_IDLE) begin
      if(i_valid & i_ready) begin // if data is sent
        i_ready <= 0; // prevent another sequence from being sent
        cooldown_counter <= COOLDOWN_CYCLES;
        o_valid <= 0;
        state <= S_START; // moves to start behavior of controller
        addr_buffer <= {i_addr, mode}; // Creates the add and wr/rd section of the bitstring
        data_buffer <= i_data; // Creates the data section
        bit_counter <= 7;
        clk_divider_counter <= DIVIDER_COUNT-1; // Resets the clock to max value
      end
      else begin
        scl <= 1; // hold scl high in waiting to start
        if(cooldown_counter > 0) begin
          i_ready <= 0; // wait for delay to allow space between signals
          cooldown_counter <= cooldown_counter - 1;
        end else begin
          i_ready <= 1; // ready for next signal
        end
      end
    end else begin // handle all non-idle state here
    if (clk_divider_counter == 0) begin
      clk_divider_counter <= DIVIDER_COUNT-1; // re-maximizes clock counter
      scl <= ~scl; // changes the serial clock (creates oscillation)
      case(state)
        S_START: begin
          state <= S_ADDR; // if in start case, move on to address
        end
        S_ADDR: begin
          if(scl) begin // negative edge logic
            if(bit_counter > 0) bit_counter <= bit_counter - 1; // increment bit counter
          // end else begin // positive edge logic // positive edge logic not needed for this section
            if(bit_counter == 0) state <= S_ACK_ADDR; // if all bits have been communicated, await acknowledge
          end
        end
        S_ACK_ADDR: begin
          // $display("[i2c controller] waiting for ack on address 0x%h, addr[0] = %b", addr_buffer[7:1], addr_buffer[0]);
          //if(~sda) begin
            bit_counter <= 7; // reset bit counter
            case(addr_buffer[0]) // based on wr/rd bit at end of address buffer
              WRITE_8BIT_REGISTER : begin
                if(scl) state <= S_WR_DATA; // if in writing mode
              end
              READ_8BIT : begin
                if(~scl) state <= S_RD_DATA; // if in reading mode
              end
            endcase
          //end
          /*
          else begin
            if(~scl) begin
              state <= S_STOP; // Go to STOP if there is no acknowledge. Technically you could go to START again (look up repeated START) if you are worried about efficiency.
            end
          end
          */
        end

        S_RD_DATA : begin
          if(~scl) begin // posedge logic
            data_buffer[0] <= sda; // sets sda to MSB of data buffer
            data_buffer[7:1] <= data_buffer[6:0]; // shifts the lesser bits to the left to change the MSB
            if(bit_counter > 0) begin
              bit_counter <= bit_counter - 1; // increment bit counter
            end
            else begin
              state <= S_ACK_RD; // after all bits are sent, move to acknowledgement
            end
          end
        end
        S_ACK_RD : begin
          if(~scl) begin // positive edge
            state <= S_STOP; // end logic
            o_data <= data_buffer; // data 
            o_valid <= 1; // data is valid
          end
        end
        S_WR_DATA: begin
          if(scl) begin // negative edge logic
            bit_counter <= bit_counter - 1; // increment bit counter
            if(bit_counter > 0) begin  // driving sda happens in always comb block later in file
              // data_buffer[0] <= 1'b1; // Shift in ones to leave SDA as default high. More for the prettiness of the waveform, it shouldn't matter.
              data_buffer[7:1] <= data_buffer[6:0]; // shift data to left
            end
          end
          else if(&bit_counter) begin // if bit_counter == -1, or 1111 in two's complement
              state <= S_ACK_WR; // wait for acknowledge
          end
        end
        S_ACK_WR: begin
          if(scl) begin // negative edge logic? //TODO(avinash)
            state <= S_STOP;
            if(~sda) begin // Does this need to drive scl high after sda for stop sequence
            end
          end
        end

        S_STOP: begin
          state <= S_IDLE;
        end
        S_ERROR: begin
`ifndef SIMULATION // In simulation stop, in synthesis, keep running!
          state <= S_IDLE;
`endif
        end
      endcase
      end else begin // still waiting on clock divider counter
        clk_divider_counter <= clk_divider_counter - 1; // Case statement architecture is wisely only called on the clk divider edge, instead of the clock being divided in the cases
      end
    end
  end
// SOLUTION END
end

// SOLUTION START
always_comb case(state)
  S_START, S_ADDR, S_WR_DATA, S_ACK_RD: sda_oe = 1; // Allows the controller to send to the target
  default : sda_oe = 0; // Holds line low to let target control the line.
endcase

always_comb case(state)
  S_START: sda_out = 0; // Start signal.
  S_ADDR: sda_out = addr_buffer[bit_counter[2:0]]; // Outputs address values as bit counter increments
  S_WR_DATA : sda_out = data_buffer[7]; //data_buffer[bit_counter];
  S_ACK_RD : sda_out = 0; // Tells target that read data has been received
  default : sda_out = 0; //TODO // Should have stop condition details
endcase
// SOLUTION END

endmodule
