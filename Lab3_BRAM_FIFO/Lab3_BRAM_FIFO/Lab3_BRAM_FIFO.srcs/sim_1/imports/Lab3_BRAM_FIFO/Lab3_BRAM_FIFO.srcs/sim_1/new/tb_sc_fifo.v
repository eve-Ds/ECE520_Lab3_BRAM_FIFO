`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2026 07:36:44 PM
// Design Name: 
// Module Name: tb_sc_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_sc_fifo();
    localparam WIDTH = 16;
    localparam DEPTH = 32;
    localparam COUNT_WIDTH = $clog2(DEPTH + 1);
    
    // inputs use reg and outputs use wire
    
    //inputs
    reg CLK;
    reg SRST;
    reg [WIDTH-1:0] DATA_IN;
    reg WRITE_ENABLE;
    reg READ_ENABLE;
    
    // outputs 
    wire [COUNT_WIDTH-1:0] DATA_COUNT;
    wire VALID;
    wire [WIDTH-1:0] DATA_OUT;
    wire ALMOST_FULL;
    wire ALMOST_EMPTY;
    wire FULL;
    wire EMPTY;
    
sc_fifo #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .ALMOST_EMPTY_THRESHOLD(1),
    .ALMOST_FULL_THRESHOLD(31),
    .READ_LATENCY(1)
)
 UUT
(
    .CLK(CLK),
    .SRST(SRST),
    .DATA_IN(DATA_IN),
    .WRITE_ENABLE(WRITE_ENABLE),
    .READ_ENABLE(READ_ENABLE),
    
    .DATA_COUNT(DATA_COUNT),
    .VALID(VALID),
    .DATA_OUT(DATA_OUT),
    .ALMOST_FULL(ALMOST_FULL),
    .ALMOST_EMPTY(ALMOST_EMPTY),
    .FULL(FULL),
    .EMPTY(EMPTY)
);

localparam integer NUM_TEST_DATA = 2*DEPTH + 2 + DEPTH;

reg [WIDTH-1:0] test_data [0:NUM_TEST_DATA-1];

initial begin
    $readmemh("input_data.txt", test_data);
end

integer i;

// 50 MHz clock and an active high reset 
// 1/20ns = 50Mhz 
initial begin
    CLK = 0;
    // toggle clock continuously 
    forever #10 CLK = ~CLK;
end

initial begin
    SRST = 1;
    DATA_IN = 0;
    WRITE_ENABLE = 0; 
    READ_ENABLE = 0;
    
    #40; 
    SRST = 0;
    
    #1;
    
    // Reset
    if (DATA_OUT !== 0) begin
        $display("ERROR: DATA_OUT is not zero after reset");
        $finish;
    end
    
    if (DATA_COUNT !== 0) begin
        $display("ERROR: DATA_COUNT is not zero after reset");
        $finish;
    end
    
    if (!EMPTY) begin
        $display("ERROR: EMPTY should be asserted after reset");
        $finish;
    end
    
    if (FULL) begin
        $display("ERROR: FULL should be deasserted after reset");
        $finish;
    end 
    
    if (!ALMOST_EMPTY) begin
        $display("ERROR: ALMOST_EMPTY should be asserted after reset");
        $finish;
    end
    
    if (VALID) begin
        $display ("ERROR: VALID should be deasserted after reset");
        $finish;
    end
    
    $display("Reset test passed");
    
    // READ_ENABLE while FIFO is empty
    @(negedge CLK);
    READ_ENABLE = 1;
    @(posedge CLK);
    #1;
    
    if (VALID) begin
        $display("ERROR: VALID asserted while FIFO was empty");
        $finish;
     end
    
    if (DATA_COUNT !== 0) begin
        $display("ERROR: DATA_COUNT changed during invalid read");
        $finish;
    end
    
    READ_ENABLE = 0;
    
    // Writing all 1s
    for (i = 0; i < DEPTH; i = i +1) begin
        write_word(test_data[i]);
    end
    
    if (!FULL) begin
        $display("ERROR: FULL did not assert");
        $finish;
    end
    
    if (DATA_COUNT !== DEPTH) begin
        $display("ERROR: DATA_COUNT is incorrect when full");
        $finish;
    end
    
    if (!ALMOST_FULL) begin
        $display("ERROR: ALMOST_FULL did not assert");
        $finish;
    end
    
    $display("All 1's write test passed");
    
    // WRITE_ENABLE Test when FIFO is full
    @(negedge CLK);
    DATA_IN = 16'hDEAD;
    WRITE_ENABLE = 1;
    
    @(posedge CLK);
    #1;
    
    if (DATA_COUNT !== DEPTH) begin
        $display("ERROR: Write was accepted while FIFO was full");
        $finish;
    end
    
    WRITE_ENABLE = 0;
    DATA_IN = 0;
    
    //Read all 1s 
    for (i=0; i < DEPTH; i = i + 1) begin
        read_word(test_data[i]);
    end
    
    if (!EMPTY) begin 
        $display("ERROR: EMPTY did not assert after reading all 1s");
        $finish;
    end
    
    $display("All 1s read test passed");
    
    // Write and read all 0s
    for (i = 0; i < DEPTH; i = i + 1) begin
        write_word(test_data[DEPTH + i]);
    end
    
    for (i = 0; i < DEPTH; i = i + 1) begin
        read_word(test_data[DEPTH + i]);
    end
    $display("All 0s test passed");
    
    write_word(test_data[2*DEPTH]);
    write_word(test_data[2*DEPTH + 1]);
    
    read_word(test_data[2*DEPTH]);
    read_word(test_data[2*DEPTH + 1]);
    
    $display("Alternating pattern test passed");
    
    //Write every memory location
    for (i=0; i < DEPTH; i = i +1) begin
        write_word(test_data[2*DEPTH+ 2 + i]);
    end
    
    //Read every memory location back
    for ( i =0; i < DEPTH; i = i + 1)begin
        read_word(test_data[2*DEPTH + 2 + i]);
    end
    
    $display("Memory location test passed");
    
    //Test ALMOST_EMPTY
    write_word(16'h1234);
    
    if (!ALMOST_EMPTY) begin
        $display("ERROR: ALMOST_EMPTY did not assert");
        $finish;
     end
     
     read_word(16'h1234);
     
     //ALMOST_FULL test at count 31
     
     for (i=0; i < 31; i = i +1)begin
        write_word(i);
     end
     
     if (!ALMOST_FULL) begin
        $display("ERROR: ALMOST_FULL did not assert at count 31");
        $finish;
     end
     
     if (FULL) begin
        $display("ERROR: FULL asserted too early");
        $finish;
     end
     
     // Fill final location
     
     write_word(16'hBEEF);
     
     if (!FULL) begin
        $display("ERROR: FULL did not assert at count 32");
        $finish;
      end 
      
      //Read the FIFO back
      for (i =0; i < 31; i = i + 1) begin
          read_word(i);
      end
          read_word(16'hBEEF);
      
      if(!EMPTY) begin
        $display("ERROR: FIFO is not empty after final reads");
        $finish;
      end
      
      $display("Status-flag tests passed");
      $display("PASS: ALL FIFO test completed successfully");
      
      $finish;
     end
task write_word;
    input [WIDTH-1:0] value;
    begin
        @(negedge CLK);
        if (FULL) begin
            $display("ERROR: Tried to write while FIFO was full");
            $finish;
        end
        DATA_IN = value;
        WRITE_ENABLE = 1;
        READ_ENABLE = 0;
        
        @(posedge CLK);
        #1;
        
        WRITE_ENABLE = 0;
        DATA_IN = 0;
       end
endtask

task read_word;
    input[WIDTH-1:0] expected_value;
    
    begin
        @(negedge CLK);
            if (EMPTY) begin
                $display("ERROR: Tried to read while FIFO was empty");
                $finish;
             end
             
             READ_ENABLE = 1;
             WRITE_ENABLE = 0;
         @(posedge CLK);
         #1;
         
         if(!VALID) begin
            $display("ERROR: VALID was not asserted after read");
            $finish;
         end
         
         if (DATA_OUT !== expected_value) begin
            $display("ERROR: Expected %h, received %h",expected_value, DATA_OUT);
            $finish;
         end
         
         READ_ENABLE = 0;
       end
      endtask  
endmodule
