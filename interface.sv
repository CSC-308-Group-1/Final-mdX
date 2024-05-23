//////////////////////////////////////////////////////////////////////////////////////////
//		ENGR_850	Project
//		File		: interface.sv
//		Authors		: Arok Lijo J , Chandan Gireesha , Saifulla 
//		Description	: Interface module 
//////////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

interface ME_interface(input bit clk);

  bit start; 
  logic[3:0]      motionX;
  logic[3:0]      motionY;
  integer Expected_motionX;
  integer Expected_motionY;
  logic[7:0]      AddressR;
  logic[9:0]      AddressS1;
  logic[9:0]      AddressS2;
  logic[7:0]      R;
  logic[7:0]      S1;
  logic[7:0]      S2;
  logic [7:0]		BestDist;
  logic 			completed;
  logic[7:0]      R_mem[`RMEM_MAX-1:0];
  logic[7:0]      S_mem[`SMEM_MAX-1:0];


   clocking ME_driver_cb @(posedge clk);
    default input #1 output #1;
     output R_mem;
     output S_mem;
     output R;
     output S1;
     output S2;
     output Expected_motionX;
     output Expected_motionY;
     input BestDist;
     input motionX, motionY;
     input AddressR;
     input AddressS1;
     input AddressS2;
     input completed;
  endclocking
  
  clocking ME_monitor_cb @(posedge clk);
    default input #1 output #1;
     input R_mem;
     input S_mem;
     input R;
     input S1;
     input S2;
     input Expected_motionX;
     input Expected_motionY;
     input motionX, motionY;
     input AddressR;
     input AddressS1;
     input AddressS2;
     input completed;
     input BestDist;
  endclocking
  
  modport ME_DRIVER  (clocking ME_driver_cb, input clk, start);
  

  modport ME_MONITOR (clocking ME_monitor_cb, input clk, start);

  /*always@(*) begin
    R=   R_mem[AddressR];
    S1=   S_mem[AddressS1];
    S2=   S_mem[AddressS2];
  end*/	


endinterface

