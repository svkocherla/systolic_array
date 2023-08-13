module instruction_memory(
    input wire clk,
    input wire rst,
    input wire en, // for writing
    input wire read, // read enable
    input wire [2:0] addrI, // for writing (2^3 = 8 instructions)
    input wire [3:0] dataI, // for writing max matrix width 2^4 = 16
    output reg [3:0] value // value, max matrix size 2^4 = 16
);

    reg [3:0] instructions [0:7]; // max 8 instructions, max matrix size = 2^4 = 16

    reg [2:0] counter = 0; // instruction counter, goes up to 8
    // maybe put first value in instructions[1] depending on bugs

    always @(posedge clk) begin
        if (en) begin
            instructions[addrI] <= dataI;
        end
        if (read) begin
            value <= instructions[counter];
            counter <= counter + 1;
        end
    end

endmodule
