/*
 * demo_mode.v
 *
 * Sends "Tiny Tapeout!\r\n" once per second over USB CDC.
 *
 * Author: Uri Shaked
 */

`default_nettype none

module demo_mode #(
    parameter CLK_HZ = 48_000_000
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire       ready,
    output reg  [7:0] data,
    output reg        valid
);

  localparam MSG_LEN = 15;
  localparam WAIT_CYCLES = CLK_HZ;

  reg [$clog2(WAIT_CYCLES)-1:0] timer;
  reg [3:0] char_idx;
  reg       sending;

  function [7:0] msg_char(input [3:0] idx);
    case (idx)
      4'd0:  msg_char = "T";
      4'd1:  msg_char = "i";
      4'd2:  msg_char = "n";
      4'd3:  msg_char = "y";
      4'd4:  msg_char = " ";
      4'd5:  msg_char = "T";
      4'd6:  msg_char = "a";
      4'd7:  msg_char = "p";
      4'd8:  msg_char = "e";
      4'd9:  msg_char = "o";
      4'd10: msg_char = "u";
      4'd11: msg_char = "t";
      4'd12: msg_char = "!";
      4'd13: msg_char = "\r";
      4'd14: msg_char = "\n";
      default: msg_char = 0;
    endcase
  endfunction

  always @(posedge clk) begin
    if (!rst_n || !enable) begin
      timer    <= 0;
      char_idx <= 0;
      sending  <= 0;
      data     <= 0;
      valid    <= 0;
    end else if (sending) begin
      if (valid && ready) begin
        valid <= 0;
        if (char_idx == MSG_LEN - 1) begin
          sending  <= 0;
          char_idx <= 0;
          timer    <= 0;
        end else begin
          char_idx <= char_idx + 1;
        end
      end else if (!valid) begin
        data  <= msg_char(char_idx);
        valid <= 1;
      end
    end else begin
      valid <= 0;
      if (timer == WAIT_CYCLES - 1) begin
        sending <= 1;
      end else begin
        timer <= timer + 1;
      end
    end
  end

endmodule
