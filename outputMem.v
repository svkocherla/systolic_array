module output_memory(
    input wire clk,
    input wire rst,
    input wire en, // for writing
    input wire read, // read enable
    input wire [31:0] c0,
    input wire [31:0] c1,
    input wire [31:0] c2,
    input wire [31:0] c3,
    input wire [31:0] c4,
    input wire [31:0] c5,
    input wire [31:0] c6,
    input wire [31:0] c7,
    input wire [31:0] c8,
    input wire [31:0] c9,
    input wire [31:0] c10,
    input wire [31:0] c11,
    input wire [31:0] c12,
    input wire [31:0] c13,
    input wire [31:0] c14,
    input wire [31:0] c15,
    input wire [3:0] addrO, // for reading (2^4 = 16 memory locations)
    output reg [31:0] dataO // for reading
);

    reg [31:0] memory [0:15];
    reg [6:0] counter = 0; // 2^4 size matrix * 2^3 matrices

    always @(posedge clk) begin
        if (en) begin
            memory[counter] <= c0;
            memory[counter + 1] <= c1;
            memory[counter + 2] <= c2;
            memory[counter + 3] <= c3;
            memory[counter + 4] <= c4;
            memory[counter + 5] <= c5;
            memory[counter + 6] <= c6;
            memory[counter + 7] <= c7;
            memory[counter + 8] <= c8;
            memory[counter + 9] <= c9;
            memory[counter + 10] <= c10;
            memory[counter + 11] <= c11;
            memory[counter + 12] <= c12;
            memory[counter + 13] <= c13;
            memory[counter + 14] <= c14;
            memory[counter + 15] <= c15;
            counter <= counter + 16;
        end
        if (read) begin
            dataO <= memory[addrO];
        end
    end

endmodule