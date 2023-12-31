`timescale 1ns/1ps;

module tt_um_yannickreiss_mpu (input wire [7:0] ui_in,    // Dedicated inputs
                                     output wire [7:0] uo_out,  // Dedicated outputs
                                     input wire [7:0] uio_in,   // IOs: Input path
                                     output wire [7:0] uio_out, // IOs: Output path
                                     output wire [7:0] uio_oe,  // IOs: Enable path (active high: 0 = input, 1 = output
                                     input wire ena,
                                     input wire clk,
                                     input wire rst_n);

// internal memory
reg [7:0] register [7:0]; // registers
reg [11:0] program_counter; // Count up to 
reg [2:0] phase_counter; // current phase
reg [2:0] alt_phase; // store phase here, while HALT
reg [7:0] alu_in1; // first alu input
reg [7:0] alu_in2; // second alu input
reg [7:0] alu_result;
reg [7:0] instruction; // store current instruction
reg HALT_s;
reg jump;

// in- and output signals
wire [11:0]branch_result;
wire HALT;
assign HALT = ui_in[7];

// Reset
always @(negedge rst_n) begin
    register[7] = 8'b0;
    register[6] = 8'b0;
    register[5] = 8'b0;
    register[4] = 8'b0;
    register[3] = 8'b0;
    register[2] = 8'b0;
    register[1] = 8'b0;
    register[0] = 8'b0;

    program_counter = 12'b0;

    alt_phase = 3'b0;
    phase_counter = 3'b0;
    HALT_s = 1'b0;
    jump = 1'b0;
end

// Phase counter
always @(posedge clk) begin
    case (phase_counter)
        3'b000: phase_counter = 3'b001; // IF -> Dec
        3'b001: phase_counter = 3'b001 ^ instruction[7:5]; // Dec -> Opcode (010 xor)
        3'b010: phase_counter = 3'b011; // operand 3 -> op2
        3'b011: phase_counter = 3'b100; // operand 2 -> op1
        3'b100: phase_counter = 3'b101; // operand 1 -> exec
        3'b101: phase_counter = 3'b110; // Exec -> Write back
        3'b110: phase_counter = 3'b000; // Write back -> IF
        default: phase_counter = 3'b111;
    endcase
end

// Block the MPU
always @(posedge HALT_s) begin
    alt_phase = phase_counter;
    phase_counter = 3'b111;
end

// Release the MPU
always @(negedge HALT) begin
    HALT_s = 1'b0;
    phase_counter = alt_phase;
end

// program counter
always @(posedge clk) begin
    if (jump == 1'b0) begin
        if (phase_counter == 3'b110) begin
            program_counter = program_counter + 1;
        end
    else
       program_counter = branch_result;
    end
end

// ALU
always @(instruction, alu_in1, alu_in2) begin
    if (instruction[4] == 1'b1) begin
        if (instruction[7:5] == 3'b101) begin
            // Unary operations
            case (instruction[3:1])
                3'b000: alu_result = !alu_in1;
                3'b001: alu_result = alu_in1 + 1;
                3'b010: alu_result = alu_in1 - 1;
                3'b011: alu_result = alu_in1 >>> 1;
                3'b100: alu_result = alu_in1 <<< 1;
                3'b101: alu_result = alu_in1 >> 1;
                3'b110: alu_result = alu_in1 << 1;
                default: alu_result = 8'b0;
            endcase
        end
        else begin
            // Binary operations
            case (instruction[3:1])
                3'b001: alu_result = alu_in1 | alu_in2;
                3'b010: alu_result = alu_in1 ^ alu_in2;
                3'b011: alu_result = alu_in1 + alu_in2;
                3'b100: alu_result = alu_in1 - alu_in2;
                3'b101: alu_result = (alu_in1 == alu_in2);
                3'b110: alu_result = alu_in1 <<< alu_in2;
                3'b111: alu_result = alu_in1 >>> alu_in2;
                default: alu_result = alu_in1 & alu_in2; 
            endcase
        end
    end
end

// One Froggy a day keeps the sadness away!
endmodule
