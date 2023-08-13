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
    input wire [6:0] addrO, // 16 * 8 max matrix possibilities
    output wire [31:0] dataO, // 32 bit result for each processor
    input wire ap_start, // pulse start
    output reg ap_done, // level end 
    output wire [3:0] currInstruction
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

    // wire [3:0] currInstruction = 0; // defined here

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
      	.c9(outO[9]),
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
      	.c9(outO[9]),
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
    reg [4:0] counter = 0;
  
  always @(negedge clk or ap_start) begin // needs to be negedge for some reason
        if (ap_start) begin
            running <= 1;
        end
        else begin
            if (running == 1) begin
          //$display("rst = %b, addrA = %d, dataA = %d, enA = %b, addrB = %d, dataB = %d, enB = %b, addrI = %d, dataI = %d, enI = %d, addrO = %d, renI = %d, currInstruction = %d, counter = %d", rst, addrA, dataA, enA, addrB, dataB, enB, addrI, dataI, enI, addrO, renI, currInstruction, counter);
                if (started == 0) begin // step 2, read instruction
                    wenO <= 0;
                    renI <= 1;
                    started <= 1;
                  $display("pathA");
                end
                else if (renI == 1) begin // if just read instruction, dont read more and set counter
                    renI <= 0;
                    counter <= currInstruction + 7;
                    if (currInstruction == 0) begin
                        ap_done <= 1;
                        running <= 0;
                    end
                  $display("PATHB");
                end
              else if (counter != 0) begin // do N+7 clock cycles
                    renA <= 1;
                    renB <= 1;
                    counter <= counter - 1;
                  $display("pathC");
                //for (int i = 0; i <= 15; i = i + 1) begin
                  //  $display("outO[%0d] = %d", i, outO[i]);
                //end

                end
                else if (counter == 0) begin // write to memory
                    renA <= 0;
                    renB <= 0;
                    wenO <= 1;
                    started <= 0;
                  $display("pathD");
                end
            end
        end
    end

endmodule

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
          //$display("addrI = %d, valI = %d, i0 = %d", addrI, dataI, instructions[addrI - 1]);
        end
        if (read) begin
            value <= instructions[counter];
            counter <= counter + 1;
          //$display("reading instruction, counter = %d, value = %d", counter, instructions[counter]);
        end
    end

endmodule

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
    input wire [6:0] addrO, // for reading (2^4  * 8 matrices= 2^7 memory locations)
    output reg [31:0] dataO // for reading
);

  reg [31:0] memory [0:127]; // needs 16 * 8 because 8 max instructions
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
            $display("en = %b, read = %b, c0 = %d, c1 = %d, c2 = %d, c3 = %d, c4 = %d, c5 = %d, c6 = %d, c7 = %d, c8 = %d, c9 = %d, c10 = %d, c11 = %d, c12 = %d, c13 = %d, c14 = %d, c15 = %d", en, read, c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15);

        end
        if (read) begin
            dataO <= memory[addrO];
        end
    end

endmodule

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
              memory[addr / 256][addr % 256] <= data;
              //$display("input write: addr / 256 = %d, addr mod 256 = %d, data = %d", addr / 256, addr % 256, data);

            end
            if (read) begin
                out0 <= memory[0][counter];
                out1 <= memory[1][counter];
                out2 <= memory[2][counter];
                out3 <= memory[3][counter];
                counter <= counter + 1;
              //$display("input read: out0 = %d, out1 = %d, out2 = %d, out3 = %d, counter = %d", out0, out1, out2, out3, counter);
            end
        end
    end

endmodule

module processor(clk, rst, in_a, in_b, out_a, out_b, out_c);

    input wire clk, rst;
    input wire [15:0] in_a, in_b;
    output reg [15:0] out_a, out_b;
    output reg [31:0] out_c;

    always @(posedge clk) begin
        if (rst) begin
            out_a <= 0;
            out_b <= 0;
            out_c <= 0;
        end
        else begin
			if ((in_a !== 16'bx) && (in_b !== 16'bx)) begin
              out_c <= out_c + in_a*in_b;
              out_a <= in_a;
              out_b <= in_b;
              //$display("outc = %d, in_a %d, in_b %d", out_c, in_a, in_b);
            end
        end
    end
endmodule

module systolic_array(
    input wire clk,
    input wire rst,
    input wire [15:0] in_a0,
    input wire [15:0] in_a1,
    input wire [15:0] in_a2,
    input wire [15:0] in_a3,
    input wire [15:0] in_b0,
    input wire [15:0] in_b1,
    input wire [15:0] in_b2,
    input wire [15:0] in_b3,
    output wire [31:0] c0,
    output wire [31:0] c1,
    output wire [31:0] c2,
    output wire [31:0] c3,
    output wire [31:0] c4,
    output wire [31:0] c5,
    output wire [31:0] c6,
    output wire [31:0] c7,
    output wire [31:0] c8,
    output wire [31:0] c9,
    output wire [31:0] c10,
    output wire [31:0] c11,
    output wire [31:0] c12,
    output wire [31:0] c13,
    output wire [31:0] c14,
    output wire [31:0] c15
);

    wire [15:0] in_a[0:3];
    assign in_a[0] = in_a0;
    assign in_a[1] = in_a1;
    assign in_a[2] = in_a2;
    assign in_a[3] = in_a3;

    wire [15:0] in_b[0:3];
    assign in_b[0] = in_b0;
    assign in_b[1] = in_b1;
    assign in_b[2] = in_b2;
    assign in_b[3] = in_b3;

    wire [15:0] a[0:3][1:4]; //internal input a wires, makes input to pe(1,2) = a[1,2]
    wire [15:0] b[1:4][0:3]; //internal input b wires, makes input to pe(1,2) = b[1,2]

    //define processors pe[i][j] = in_a[i][j], in_b[i][j], out_a[i][j+1], out_b[i+1][j], out_c[i][j]
    processor pe0 (.clk(clk), .rst(rst), .in_a(in_a[0]), .in_b(in_b[0]), .out_a(a[0][1]), .out_b(b[1][0]), .out_c(c0)); // (0,0)
    processor pe1 (.clk(clk), .rst(rst), .in_a(a[0][1]), .in_b(in_b[1]), .out_a(a[0][2]), .out_b(b[1][1]), .out_c(c1)); // (0,1)
    processor pe2 (.clk(clk), .rst(rst), .in_a(a[0][2]), .in_b(in_b[2]), .out_a(a[0][3]), .out_b(b[1][2]), .out_c(c2)); // (0,2)
    processor pe3 (.clk(clk), .rst(rst), .in_a(a[0][3]), .in_b(in_b[3]), .out_a(a[0][4]), .out_b(b[1][3]), .out_c(c3)); // (0,3)

    processor pe4 (.clk(clk), .rst(rst), .in_a(in_a[1]), .in_b(b[1][0]), .out_a(a[1][1]), .out_b(b[2][0]), .out_c(c4)); // (1,0)
    processor pe5 (.clk(clk), .rst(rst), .in_a(a[1][1]), .in_b(b[1][1]), .out_a(a[1][2]), .out_b(b[2][1]), .out_c(c5)); // (1,2)
    processor pe6 (.clk(clk), .rst(rst), .in_a(a[1][2]), .in_b(b[1][2]), .out_a(a[1][3]), .out_b(b[2][2]), .out_c(c6)); // (1,2)
    processor pe7 (.clk(clk), .rst(rst), .in_a(a[1][3]), .in_b(b[1][3]), .out_a(a[1][4]), .out_b(b[2][3]), .out_c(c7)); // (1,3)

    processor pe8  (.clk(clk), .rst(rst), .in_a(in_a[2]), .in_b(b[2][0]), .out_a(a[2][1]), .out_b(b[3][0]), .out_c(c8)); // (2,0)
    processor pe9  (.clk(clk), .rst(rst), .in_a(a[2][1]), .in_b(b[2][1]), .out_a(a[2][2]), .out_b(b[3][1]), .out_c(c9)); // (2,1)
    processor pe10 (.clk(clk), .rst(rst), .in_a(a[2][2]), .in_b(b[2][2]), .out_a(a[2][3]), .out_b(b[3][2]), .out_c(c10)); // (2,2)
    processor pe11 (.clk(clk), .rst(rst), .in_a(a[2][3]), .in_b(b[2][3]), .out_a(a[2][4]), .out_b(b[3][3]), .out_c(c11)); // (2,3)

    processor pe12 (.clk(clk), .rst(rst), .in_a(in_a[3]), .in_b(b[3][0]), .out_a(a[3][1]), .out_b(b[4][0]), .out_c(c12)); // (3,0)
    processor pe13 (.clk(clk), .rst(rst), .in_a(a[3][1]), .in_b(b[3][1]), .out_a(a[3][2]), .out_b(b[4][1]), .out_c(c13)); // (3,1)
    processor pe14 (.clk(clk), .rst(rst), .in_a(a[3][2]), .in_b(b[3][2]), .out_a(a[3][3]), .out_b(b[4][2]), .out_c(c14)); // (3,2)
    processor pe15 (.clk(clk), .rst(rst), .in_a(a[3][3]), .in_b(b[3][3]), .out_a(a[3][4]), .out_b(b[4][3]), .out_c(c15)); // (3,3)



endmodule