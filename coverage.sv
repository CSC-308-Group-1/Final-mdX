`timescale 1ns/1ps

class coverage;

  // Coverage metric
  real ME_Coverage;

  // Virtual interface to memory
  virtual ME_interface mem_intf;

  // Mailbox for receiving transactions from the monitor
  mailbox mon2cov;

  // Transaction object
  Transaction trans;
      
  // Covergroup for measuring coverage
  covergroup ME_covergroup;
    option.per_instance = 1;
    
    // Coverpoint for BestDist
    Best_dist: coverpoint trans.BestDist; // Automatic bins

    // Coverpoint for Expected_motionX with specified bins
    Expect_motionX: coverpoint trans.Expected_motionX {
      bins neg_val[] = {[-8:-1]}; // Negative values
      bins zero_val  = {0};       // Zero value
      bins pos_val[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Expected_motionY with specified bins
    Expect_motionY: coverpoint trans.Expected_motionY {
      bins neg_val[] = {[-8:-1]}; // Negative values
      bins zero_val  = {0};       // Zero value
      bins pos_val[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Actual_motionX with specified bins
    Actual_motionX: coverpoint trans.motionX {
      bins neg_val[] = {[-8:-1]}; // Negative values
      bins zero_val  = {0};       // Zero value
      bins pos_val[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Actual_motionY with specified bins
    Actual_motionY: coverpoint trans.motionY {
      bins neg_val[] = {[-8:-1]}; // Negative values
      bins zero_val  = {0};       // Zero value
      bins pos_val[] = {[1:7]};   // Positive values
    }
    Cross_Exp : cross Expect_motionX,Expect_motionY;
    Cross_Act : cross Actual_motionX,Actual_motionY;
  endgroup
  
  // Constructor to initialize the coverage class
  function new(virtual ME_interface mem_intf, mailbox mon2cov);
    this.mem_intf = mem_intf;
    this.mon2cov = mon2cov;
    ME_covergroup = new();
  endfunction
   
  // Task to continuously sample coverage
  task cove();
    begin
      forever begin
        mon2cov.get(trans);        // Get a transaction from the mailbox
        ME_covergroup.sample();    // Sample the covergroup
        ME_Coverage = ME_covergroup.get_coverage(); // Update coverage metric
      end
    end
  endtask
  
endclass
