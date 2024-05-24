`timescale 1ns/1ps

class CoverageAnalysis;

  // Metric for tracking coverage
  real coverageScore;

  // Virtual interface to memory
  virtual ME_interface mem_intf;

  // Mailbox for receiving transactions from the monitor
  mailbox monitorMailbox;

  // Object for transactions
  Transaction transactionData;
      
  // Covergroup for measuring coverage
  covergroup CoverageMetrics;
    option.per_instance = 1;
    
    // Coverpoint for BestDist
    cpBestDist: coverpoint transactionData.BestDist;

    // Coverpoint for Expected_motionX with specified bins
    cpExpectedMotionX: coverpoint transactionData.Expected_motionX {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Expected_motionY with specified bins
    cpExpectedMotionY: coverpoint transactionData.Expected_motionY {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Actual_motionX with specified bins
    cpActualMotionX: coverpoint transactionData.motionX {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }

    // Coverpoint for Actual_motionY with specified bins
    cpActualMotionY: coverpoint transactionData.motionY {
      bins negativeRange[] = {[-8:-1]}; // Negative values
      bins zeroValue  = {0};             // Zero value
      bins positiveRange[] = {[1:7]};   // Positive values
    }
    
    // Cross coverage for expected motion
    crossExpected: cross cpExpectedMotionX, cpExpectedMotionY;
    
    // Cross coverage for actual motion
    crossActual: cross cpActualMotionX, cpActualMotionY;
  endgroup
  
  // Constructor to initialize the coverage analysis
  function new(virtual ME_interface mem_intf, mailbox monitorMailbox);
    this.mem_intf = mem_intf;
    this.monitorMailbox = monitorMailbox;
    CoverageMetrics = new();
  endfunction
   
  // Task to sample and update coverage metrics
  task trackCoverage();
    begin
      forever begin
        monitorMailbox.get(transactionData);        // Receive a transaction
        CoverageMetrics.sample();                   // Sample the covergroup
        coverageScore = CoverageMetrics.get_coverage(); // Update the coverage metric
      end
    end
  endtask
  
endclass
