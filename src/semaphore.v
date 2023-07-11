`timescale 1ns/1ps;

module tt_um_yannickreiss_semaphore (input wire [7:0] ui_in,   // Dedicated inputs
                                     output wire [7:0] uo_out, // Dedicated outputs
                                     input wire ena,
                                     input wire clk,
                                     input wire rst_n);
// Signals
wire mutex;
reg [7:0] bus_reg;
reg [7:0] fcfs[7:0];

assign mutex = uo_out[0] || uo_out[1] || uo_out[2] || uo_out[3] || uo_out[4] || uo_out[5] || uo_out[6] || uo_out[7];

assign uo_out = bus_reg & mutex;

// reset
always @(negedge rst_n) begin
    bus_reg = 8'b0;
    fcfs[7] = 8'b0;
    fcfs[6] = 8'b0;
    fcfs[5] = 8'b0;
    fcfs[4] = 8'b0;
    fcfs[3] = 8'b0;
    fcfs[2] = 8'b0;
    fcfs[1] = 8'b0;
    fcfs[0] = 8'b0;
end

// clk
always @(posedge clk) begin
    if (mutex == 1'b0) begin
        // LOCK
        bus_reg = fcfs[7];
        fcfs[7] = fcfs[6];
        fcfs[6] = fcfs[5];
        fcfs[5] = fcfs[4];
        fcfs[4] = fcfs[3];
        fcfs[3] = fcfs[2];
        fcfs[2] = fcfs[1];
        fcfs[1] = fcfs[0];
    end
end

endmodule
