
module testbench();
  // read tests from file
  // testcase has n * 2 matrices of sizes x_1...x_n, and a result of size n*16
  // for each test, generate a matrix and instructions
	  // pass into test module, along with result matrix
  
  integer i,j, file_id;
  integer col = 0;  
  integer iter;
  integer k;
  
  reg [3:0] n [0:0]; // number of instructions
  reg [4:0] instructions[0:7]; // 7 instructions max, last is 0
  reg [15:0] matrixa[0:3][0:255]; // total memory size, 4 by x_1 + x_2...x_n + padding
  reg [15:0] matrixb[0:3][0:255]; // total memory size, 4 by x_1 + x_2...x_n + padding
  reg [31:0] result[0:127]; // stores 8 matrices of data
  
    test t0 ( 
       .n(n[0]), 
       .instructions(instructions),
      .a(matrixa), 
      .b(matrixb), 
       .result(result)
       ); 
  
  
  initial begin
    
    for (i = 0; i <= 3; i = i + 1) begin // make array all 
      for (j = 0; j <= 240; j = j + 1) begin
        matrixa[i][j] = 0;
        matrixb[i][j] = 0;
      end
    end
    
    // initialize instructions
    file_id = $fopen("test_1.txt", "r");

    $fscanf(file_id, "%d", n[0]);

    for ( i = 0; i < 8; i = i + 1) begin
      $fscanf(file_id, "%d", instructions[i]);
    end

    for ( i = 0; i < n[0] * 16; i = i + 1) begin
      $fscanf(file_id, "%d", result[i]);
    end
    
    //read a
    for (i = 0; i < n[0]; i = i + 1) begin
      k = instructions[i] + 6 + col;
      if (i != 0) begin
        k = k + 1;
      end
      for (j = 0; j < 4; j = j + 1) begin
        for (iter = col; iter < k; iter = iter + 1) begin
          $fscanf(file_id, "%d", matrixa[j][iter]);
        end
      end
      col = iter;
    end
    
    col = 0;  
    iter = 0;
    k = 0;
    
    //read b
    for (i = 0; i < n[0]; i = i + 1) begin
      k = instructions[i] + 6 + col;
      if (i != 0) begin
        k = k + 1;
      end
      for (j = 0; j < 4; j = j + 1) begin
        for (iter = col; iter < k; iter = iter + 1) begin
          $fscanf(file_id, "%d", matrixb[j][iter]);
        end
      end
      col = iter;
    end
    
  end
endmodule

module test(
  input wire [3:0] n, // number of instructions
  input wire [4:0] instructions[0:7], // 7 instructions max, last is 0
  input wire [15:0] a[0:3][0:255], // total memory size, 4 by x_1 + x_2...x_n + padding
  input wire [15:0] b[0:3][0:255], // total memory size, 4 by x_1 + x_2...x_n + padding
  input wire [31:0] result[0:127] // stores 8 matrices of data
);

    reg clk, rst;
    reg [9:0] addrA, addrB;
    reg [2:0] addrI;
  	reg [4:0] dataI;
    reg [15:0] dataA, dataB;
    wire [31:0] dataO;
    reg [6:0] addrO;
    reg enA, enB, enI;
    reg ap_start;
    wire ap_done;
  	wire [4:0] inst;
  
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
                dataA = a[i][j];
                dataB = b[i][j];
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
          $display("%0d out of %0d entries correct", count, n * 16);
            $finish;
        end
    end

 

endmodule