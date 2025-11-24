/*
 * tt_um_usb_cdc.v
 *
 * USB CDC for Tiny Tapeout
 *
 * Author: Uri Shaked
 */

`default_nettype none

localparam BIT_SAMPLES = 'd4;

module tt_um_urish_usb_cdc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  wire usb_tx_en;
  assign uio_oe = {6'b000001, usb_tx_en, usb_tx_en};

  // Tie off unused outputs:
  assign uo_out[3:0] = 0;
  assign uo_out[6:5] = 0;
  assign uio_out[7:3] = 0;

  wire [7:0] uart_tx_byte;
  wire [7:0] uart_rx_byte;

  wire uart_tx_en;
  wire uart_tx_busy;
  wire uart_rx_valid;
  wire uart_rx_read;

  /* UART */
  uart_tx #(
      .BIT_RATE(115_200),
      .CLK_HZ  (48_000_000)
  ) u_uart_tx (
      .clk         (clk),
      .resetn      (rst_n),
      .uart_tx_en  (uart_tx_en),
      .uart_tx_data(uart_tx_byte),
      .uart_txd    (uo_out[4]),
      .uart_tx_busy(uart_tx_busy)
  );

  uart_rx #(
      .BIT_RATE(115_200),
      .CLK_HZ  (48_000_000)
  ) u_uart_rx (
      .clk          (clk),
      .resetn       (rst_n),
      .uart_rxd     (ui_in[3]),
      .uart_rx_read (uart_rx_read),
      .uart_rx_valid(uart_rx_valid),
      .uart_rx_data (uart_rx_byte)
  );

  /* USB Serial */
  usb_cdc #(
      .VENDORID              (16'h1209),
      .PRODUCTID             (16'h5454),             // https://pid.codes/1209/5454/
      .IN_BULK_MAXPACKETSIZE ('d8),
      .OUT_BULK_MAXPACKETSIZE('d8),
      .BIT_SAMPLES           (BIT_SAMPLES),
      .USE_APP_CLK           (0),
      .APP_CLK_RATIO         (BIT_SAMPLES * 12 / 2)  // BIT_SAMPLES * 12MHz / 2MHz
  ) u_usb_cdc (
      .frame_o(),
      .configured_o(uo_out[7]),

      .app_clk_i(clk),
      .clk_i(clk),
      .rstn_i(rst_n),
      .out_ready_i(~uart_tx_busy),
      .in_data_i(uart_rx_byte),
      .in_valid_i(uart_rx_valid),
      .dp_rx_i(uio_in[0]),
      .dn_rx_i(uio_in[1]),

      .out_data_o(uart_tx_byte),
      .out_valid_o(uart_tx_en),
      .in_ready_o(uart_rx_read),
      .dp_pu_o(uio_out[2]),
      .tx_en_o(usb_tx_en),
      .dp_tx_o(uio_out[0]),
      .dn_tx_o(uio_out[1])
  );

endmodule  // tt_um_urish_usb_cdc
