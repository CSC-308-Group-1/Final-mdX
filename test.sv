`timescale 1ns/1ps

`include "environment.sv"

program test(MotionEstimationInterface mem_intf); 

  // Instance of the environment class
  environment env;
  
  // Initial block to set up and run the environment
  initial begin
    env = new(mem_intf);  // Create a new environment instance with the given interface
    env.gen.trans_count = `TRANSACTION_COUNT;  // Set the total number of transactions to be generated
    env.run();  // Start the run task of the environment
  end
endprogram
