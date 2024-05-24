`timescale 1ns/10ps

`include "defines.sv"
`include "interface.sv"
`include "test.sv"
`include "assertion.sv"

module top_tb();
  bit clk;
  always #10 clk = ~clk;  // Clock Generation
  
  initial begin 
    $display(" ================================================= TB Start = 0 =================================================\n");
    mem_intf.start = 1'b0;
    repeat(2) @(posedge clk);
    mem_intf.start = 1'b1;
  end
  
  ME_interface mem_intf(clk);  // Interface Instantiation
  ROM_R memR_u(.clock(clk), .AddressR(mem_intf.AddressR), .R(mem_intf.R));
  ROM_S memS_u(.clock(clk), .AddressS1(mem_intf.AddressS1), .AddressS2(mem_intf.AddressS2), .S1(mem_intf.S1), .S2(mem_intf.S2));
  
  assign memR_u.Rmem = mem_intf.R_mem;
  assign memS_u.Smem = mem_intf.S_mem;

  test Motion_Estimator(mem_intf);  // Test instantiation

  initial begin
    $vcdpluson();
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end

  top dut(  // DUT Instantiation
    .clock(mem_intf.clk), 
    .start(mem_intf.start), 
    .BestDist(mem_intf.BestDist), 
    .motionX(mem_intf.motionX), 
    .motionY(mem_intf.motionY), 
    .AddressR(mem_intf.AddressR), 
    .AddressS1(mem_intf.AddressS1), 
    .AddressS2(mem_intf.AddressS2), 
    .R(mem_intf.R), 
    .S1(mem_intf.S1), 
    .S2(mem_intf.S2), 
    .completed(mem_intf.completed)
  );

  bind dut MotionEstimationAssertions(  // Binding Assertion to Top module
    .clk(mem_intf.clk), 
    .trigger(mem_intf.start), 
    .distance(mem_intf.BestDist), 
    .vectorX(mem_intf.motionX), 
    .vectorY(mem_intf.motionY),  
    .done(mem_intf.completed)
  );

endmodule
