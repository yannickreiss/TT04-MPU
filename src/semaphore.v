`timescale 1ns/1ps;

module semaphore (input clk,
                  input rst,
                  input [7:0] bus_in,
                  output [7:0] bus_out);
    // Signals
    wire mutex;
    reg [7:0] bus_reg;

    assign mutex = bus_out[0] || bus_out[1] || bus_out[2] || bus_out[3] || bus_out[4] || bus_out[5] || bus_out[6] || bus_out[7];
    
    assign bus_out = bus_reg & mutex;

    // reset
    always @(negedge rst) begin
        bus_reg = 8'b0;
    end

endmodule
