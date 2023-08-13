`include "inputMem.v"
`include "outputMem.v"
`include "instMem.v"
`include "array.v"

module top(
    input wire clk,
    input wire rst,
    input wire [9:0] addrA, // 2^10 possible addresses = 4 x 256
    input wire [15:0] dataA, //16 bit
    input wire enA,
    input wire [9:0] addrB,
    input wire [15:0] dataB,
    input wire enB,
    input wire [2:0] addrI, // 8 instructions max
    input wire [3:0] dataI, // max matrix size = 4 x 16
    input wire enI,
    input wire [3:0] addrO, // 2^4 = 4 x 4 = 16 possibilities
    output wire [31:0] dataO, // 32 bit result for each processor
    input wire ap_start, // pulse start
    output wire ap_end // level end 
);

    wire [15:0] outA [0:3];
    wire [15:0] outB [0:3];
    wire [31:0] outO [0:15];

    //signal stuff
    reg renA = 0; // read enable A
    reg renB = 0;
    reg renI = 0;
    reg renO = 0;
    reg wenO = 0; // write enable O

    wire [3:0] currInstruction = 0; // defined here

    input_memory memA (
        .clk(clk),
        .rst(rst),
        .addr(addrA),
        .write(enA),
        .data(dataA),
        .read(renA), // figure it out
        .out0(outA[0]),
        .out1(outA[1]),
        .out2(outA[2]),
        .out3(outA[3])
    );
    input_memory memB (
        .clk(clk),
        .rst(rst),
        .addr(addrB),
        .write(enB),
        .data(dataB),
        .read(renB), // figure it out
        .out0(outB[0]),
        .out1(outB[1]),
        .out2(outB[2]),
        .out3(outB[3])
    );

    instruction_memory IM (
        .clk(clk),
        .rst(rst),
        .en(enI),
        .read(renI), // change it
        .addrI(addrI),
        .dataI(dataI),
        .value(currInstruction)
    );

    output_memory memO (
        .clk(clk),
        .rst(rst),
        .en(wenO),
        .read(renO),
        .c0(outO[0]),
        .c1(outO[1]),
        .c2(outO[2]),
        .c3(outO[3]),
        .c4(outO[4]),
        .c5(outO[5]),
        .c6(outO[6]),
        .c7(outO[7]),
        .c8(outO[8]),
        .c9(outO[0]),
        .c10(outO[10]),
        .c11(outO[11]),
        .c12(outO[12]),
        .c13(outO[13]),
        .c14(outO[14]),
        .c15(outO[15]),
        .addrO(addrO),
        .dataO(dataO)
    );

    systolic_array sa (
        .clk(clk),
        .rst(rst),
        .in_a0(outA[0]),
        .in_a1(outA[1]),
        .in_a2(outA[2]),
        .in_a3(outA[3]),
        .in_b0(outB[0]),
        .in_b1(outB[1]),
        .in_b2(outB[2]),
        .in_b3(outB[3]),
        .c0(outO[0]),
        .c1(outO[1]),
        .c2(outO[2]),
        .c3(outO[3]),
        .c4(outO[4]),
        .c5(outO[5]),
        .c6(outO[6]),
        .c7(outO[7]),
        .c8(outO[8]),
        .c9(outO[0]),
        .c10(outO[10]),
        .c11(outO[11]),
        .c12(outO[12]),
        .c13(outO[13]),
        .c14(outO[14]),
        .c15(outO[15])
    );


    // steps: including testbench
    // 1. read into memA, memB, and memI, should happen in testbench

    // repeat 2-4
    // 2. if ap start, process one instruction, (renI), 1 clock cycle
    // 3. instruction reads from a/b until n+3 column (renA, renB), n + 3 clock cycles, maybe 1 more
    // 4. write to output using wenO, 1 clock cycle

    // 5. if instruction is 0, send ap_done and stop running 1 CC
    // 6. print everything from output memory (figure out how to turn on renO), happens in testbench

    reg running = 0;
    reg started = 0;
    reg [5:0] counter = 0;

    always @(posedge clk or ap_start) begin
        if (ap_start) begin
            running <= 1;
        end
        else begin
            if (running == 1) begin
                if (started == 0) begin // step 2, read instruction
                    renI <= 1;
                    started <= 1;
                end
                else if (renI == 1) begin // if just read instruction, dont read more and set counter
                    renI <= 0;
                    counter <= currInstruction + 3;
                end
                else if (counter != 0) begin // do N+3 clock cycles
                    renA <= 1;
                    renB <= 1;
                    counter <= counter - 1;
                end
                else if (counter == 0) begin // write to memory
                    renA <= 0;
                    renB <= 0;
                    wenO <= 1;
                    started <= 0;
                end
            end
        end
    end

endmodule