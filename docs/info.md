## How it works

All the magic happens in https://github.com/davidthings/tinyfpga_bx_usbserial.

## How to test

1. Connect `usb_p` and `usb_n` pins to D+ / D- USB pins either through 68 ohm resistors or directly (the resistors are recommended, but not mandatory).
2. Connect a 1.5k ohm resistor between `dp_pu_o` and `usb_p` (D+).
3. Set the clock frequency to 48 MHz.

The device should appear as a serial port on your computer, with vendor_id=1209 and product_id=5454 (https://pid.codes/1209/5454/).
Data received from USB host will appear on the output pins (`rx`) when `rx_ready` goes high.
You can send data to the USB device by waiting for `tx_ready` to go high,
setting the input pins (`tx`) to the byte you'd like to transmit, and setting `tx_valid` high.

## External Hardware

USB breakout board, 1.5k ohm resistor
