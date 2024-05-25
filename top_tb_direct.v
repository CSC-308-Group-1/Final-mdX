`timescale 1ns/10ps

`include "defines.sv"
`include "interface.sv"
`include "test.sv"

module top_tb();
  // Clock Generation
  bit clk;  
  always #10 clk = ~clk;   
  
  initial begin 
    clk = 0;
    $display(" ================================================= TB Start = 0 =================================================\n");
    topif.start = 1'b0;
    repeat(2) @(posedge clk);   
    topif.start = 1'b1;
  end              
  
  // Interface Instantiation
  top_if topif(clk); 

  // Memory instantiation          
  ROM_R memR_u(.clock(clk), .AddressR(topif.AddressR), .R(topif.R));
  ROM_S memS_u(.clock(clk), .AddressS1(topif.AddressS1), .AddressS2(topif.AddressS2), .S1(topif.S1), .S2(topif.S2));
  
  initial begin
    // Initialize memory
    for (int i = 0; i < `RMEM_MAX; i++) begin
      memR_u.Rmem[i] = 0;
    end
    for (int i = 0; i < `SMEM_MAX; i++) begin
      memS_u.Smem[i] = 0;
    end
  end

  // Test Instantiation
  test test_u(.topif(topif));       

  // DUT Instantiation
  top dut(
    .clock(topif.clk), 
    .start(topif.start), 
    .BestDist(topif.BestDist), 
    .motionX(topif.motionX), 
    .motionY(topif.motionY), 
    .AddressR(topif.AddressR), 
    .AddressS1(topif.AddressS1), 
    .AddressS2(topif.AddressS2), 
    .R(topif.R), 
    .S1(topif.S1), 
    .S2(topif.S2), 
    .completed(topif.completed)
  );

endmodule
