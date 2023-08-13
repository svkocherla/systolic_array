
module testbench();

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

  	reg [3:0] instructions[7:0]; // 8 instructions
  reg [15:0] matrix[0:3][0:255]; // 4 by 2 array
    
  wire [3:0] check;
  
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
      .currInstruction(check)
    );


    integer i,j;
  reg [15:0] mval = -1;

    initial begin
        clk = 0;
        rst = 1; #27; rst = 0;  // reset
      
      	// initialize instructions
        for (i = 0; i <= 7; i = i + 1) begin
          instructions[i] = 0;
        end
      instructions[0] = 5;
      instructions[1] = 4;
      instructions[2] = 1;
      instructions[3] = 2;
      instructions[4] = 3;
      
		// init arrays
        for (i = 0; i <= 3; i = i + 1) begin // make array all 
          for (j = 0; j <= 50; j = j + 1) begin
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
      
      
      
      	// write to memA/memB
        enA = 1;
        enB = 1;
        for (i = 0; i <= 3; i = i + 1) begin // make array 1s
          for (j = 0; j <= 50; j = j + 1) begin
                dataA = matrix[i][j];
                dataB = matrix[i][j];
                addrA = 256 * i + j; // length * row + col
                addrB = 256 * i + j;
              //$display("i = %d, j = %d, enA = %b, enB = %b, dataA = %d, dataB = %d, addrA = %d, addrB = %d, %d", i, j, enA, enB, dataA, dataB, addrA, addrB, matrix[i][j]);
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
          //display("addrI = %d, dataI = %d", addrI, dataI);
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
        if (ap_done) begin
          for (i = 0; i < 80; i = i + 1) begin
            addrO = i;
            $display("i = %d, dataO = %d", addrO, dataO);
          end
          $finish;
        end
    end

 

endmodule