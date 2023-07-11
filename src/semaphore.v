`timescale 1ns/1ps;

module tt_um_yannickreiss_semaphore (input wire [7:0] ui_in,    // Dedicated inputs
                                     output wire [7:0] uo_out,  // Dedicated outputs
                                     input wire [7:0] uio_in,   // IOs: Input path
                                     output wire [7:0] uio_out, // IOs: Output path
                                     output wire [7:0] uio_oe,  // IOs: Enable path (active high: 0 = input, 1 = output
                                     input wire ena,
                                     input wire clk,
                                     input wire rst_n);
// Signals
wire mutex;
reg [7:0] bus_reg;

assign mutex = uo_out[0] || uo_out[1] || uo_out[2] || uo_out[3] || uo_out[4] || uo_out[5] || uo_out[6] || uo_out[7];

assign uo_out = bus_reg & mutex;

// reset
always @(negedge rst_n) begin
    bus_reg = 8'b0;
end

endmodule
