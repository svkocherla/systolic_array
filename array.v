module processor(clk, rst, in_a, in_b, out_a, out_b, out_c);

    input wire clk, rst;
    input wire [15:0] in_a, in_b;
    output reg [15:0] out_a, out_b;
    output reg [31:0] out_c;

    always @(posedge clk) begin
        if (rst) begin
            out_a = 0;
            out_b = 0;
            out_c = 0;
        end
        else begin
            out_c = out_c + in_a*in_b;
            out_a = in_a;
            out_b = in_b;
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