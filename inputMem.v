module input_memory(
    input wire clk,
    input wire rst,
    input wire [9:0] addr, // 2^10 possible addresses (4 x 256)
    input wire write,
    input wire [15:0] data, // 16 bit data
    input wire read,
    output reg [15:0] out0,
    output reg [15:0] out1,
    output reg [15:0] out2,
    output reg [15:0] out3
);

    reg [15:0] memory[3:0][255:0]; // 4 by 256 memory of 16 bits each
    reg [7:0] counter = 0; // for reading (256 columns of memory)

    always @(posedge clk) begin
        if (rst) begin
            counter <= 0; 
            //maybe put first value in column 1 depending on bugs
        end
        else begin
            if (write) begin
                memory[addr % 4][addr / 4] <= data;
            end
            if (read) begin
                out0 <= memory[0][counter];
                out1 <= memory[1][counter];
                out2 <= memory[2][counter];
                out3 <= memory[3][counter];
                counter <= counter + 1;
            end
        end
    end

endmodule