
module testbench();
  // read tests from file
  // testcase has n * 2 matrices of sizes x_1...x_n, and a result of size n*16
  // for each test, generate a matrix and instructions
	  // pass into test module, along with result matrix
  
  integer i,j;
  integer mval = -1;
  
  reg [3:0] n = 5; // number of instructions
  reg [3:0] instructions[0:7]; // 7 instructions max, last is 0
  reg [15:0] matrix[0:3][0:255]; // total memory size, 4 by x_1 + x_2...x_n + padding
  reg [31:0] result[0:127]; // stores 8 matrices of data
  
  
  test t1 (
      .n(n),
      .instructions(instructions),
      .matrix(matrix),
      .result(result)
    );
  
  initial begin
  
    // initialize instructions
    for (i = 0; i <= 7; i = i + 1) begin
      instructions[i] = 0;
    end
    instructions[0] = 5;
    instructions[1] = 4;
    instructions[2] = 1;
    instructions[3] = 2;
    instructions[4] = 3;


    for (i = 0; i <= 3; i = i + 1) begin // make array all 
      for (j = 0; j <= 240; j = j + 1) begin
        matrix[i][j] = 0;
      end
    end

    for (i = 0; i <= 3; i = i + 1) begin // make array 1s
      for (j = 0; j <= 4; j = j + 1) begin
        matrix[i][i+j] = mval;
        mval = mval + 1;
      end
    end

    mval = -1;
    for (i = 0; i <= 3; i = i + 1) begin // make array 1s
      for (j = 11; j <= 14; j = j + 1) begin
        matrix[i][i+j] = mval;
        mval = mval + 1;
      end
    end

    mval = -1;
    for (i = 0; i <= 3; i = i + 1) begin // make array 1s
      for (j = 22; j <= 22; j = j + 1) begin
        matrix[i][i+j] = mval;
        mval = mval + 1;
      end
    end

    mval = -1;
    for (i = 0; i <= 3; i = i + 1) begin // make array 1s
      for (j = 30; j <= 31; j = j + 1) begin
        matrix[i][i+j] = mval;
        mval = mval + 1;
      end
    end

    mval = -1;
    for (i = 0; i <= 3; i = i + 1) begin // make array 1s
      for (j = 39; j <= 41; j = j + 1) begin
        matrix[i][i+j] = mval;
        mval = mval + 1;
      end
    end

    for (i = 0; i <= 127; i = i + 1) begin
      result[i] = 32'd2;
    end
    
  end
endmodule

module test(
  input wire [3:0] n, // number of instructions
  input wire [3:0] instructions[0:7], // 7 instructions max, last is 0
  input wire [15:0] matrix[0:3][0:255], // total memory size, 4 by x_1 + x_2...x_n + padding
  input wire [31:0] result[0:127] // stores 8 matrices of data
);

    reg clk, rst;
    reg [9:0] addrA, addrB;
    reg [2:0] addrI;
    reg [3:0] dataI;
    reg [15:0] dataA, dataB;
    wire [31:0] dataO;
    reg [6:0] addrO;
    reg enA, enB, enI;
    reg ap_start;
    wire ap_done;
  	wire [3:0] inst;
  
    top circuit(
        .clk(clk),
        .rst(rst),
        .addrA(addrA),
        .dataA(dataA),
        .enA(enA),
        .addrB(addrB),
        .dataB(dataB),
        .enB(enB),
        .addrI(addrI),
        .dataI(dataI),
        .enI(enI),
        .addrO(addrO),
        .dataO(dataO),
        .ap_start(ap_start),
      .ap_done(ap_done),
      .currInstruction(inst)
    );

    integer i,j, count;
 
    initial begin
        clk = 0;
        rst = 1; #27; rst = 0;  // reset
      
      
      	// write to memA/memB
        enA = 1;
        enB = 1;
        for (i = 0; i <= 3; i = i + 1) begin // make array 1s
          for (j = 0; j <= 255; j = j + 1) begin
                dataA = matrix[i][j];
                dataB = matrix[i][j];
                addrA = 256 * i + j; // length * row + col
                addrB = 256 * i + j;
              #10;
            end
        end
        enA = 0;
        enB = 0;

      	// write instructions
        addrI = 0;
        enI = 1;
      	for (i = 0; i <= 7; i = i + 1) begin
          dataI = instructions[i];  
          #10;
          addrI = addrI + 1;
        end
      	enI = 0;
        #10;
      
      
      	// start program
      	ap_start <= 1;
      	#10
      	ap_start <= 0;
    end
  
  
    always begin
        clk = 1; #5; clk = 0; #5; // generate clock
    end
  
    always @(posedge clk) begin
        if (ap_done) begin
            count = 0;
          	#10
          	for (i = 0; i < 16 * n; i = i + 1) begin
                addrO = i;
                #10;
             	$display($signed(dataO));
              	if (dataO == result[i]) begin
                  count = count + 1;
                end
            end
          	$display("%d out of %d entries correct", count, n * 16);
            $finish;
        end
    end

 

endmodule