`timescale 1ns/1ps

class CoverageAnalysis;

  // Metric for tracking coverage
  real coverageScore;

  // Virtual interface for memory operations
  virtual MemoryInterface memInterface;

  // Mailbox for receiving data from the monitor
  mailbox monitorMailbox;

  // Object for transactions
  Transaction transactionData;
      
  // Covergroup for tracking different coverage metrics
  covergroup CoverageMetrics;
    option.per_instance = 1;
    
    // Coverpoint for distance metric
    cpBestDistance: coverpoint transactionData.bestDistance;

    // Coverpoint for expected X motion values
    cpExpectedX: coverpoint transactionData.expectedMotionX {
      bins negativeRange[] = {[-8:-1]};
      bins zeroValue  = {0};
      bins positiveRange[] = {[1:7]};
    }

    // Coverpoint for expected Y motion values
    cpExpectedY: coverpoint transactionData.expectedMotionY {
      bins negativeRange[] = {[-8:-1]};
      bins zeroValue  = {0};
      bins positiveRange[] = {[1:7]};
    }

    // Coverpoint for actual X motion values
    cpActualX: coverpoint transactionData.motionX {
      bins negativeRange[] = {[-8:-1]};
      bins zeroValue  = {0};
      bins positiveRange[] = {[1:7]};
    }

    // Coverpoint for actual Y motion values
    cpActualY: coverpoint transactionData.motionY {
      bins negativeRange[] = {[-8:-1]};
      bins zeroValue  = {0};
      bins positiveRange[] = {[1:7]};
    }
    
    // Cross coverage for expected motion
    crossExpected: cross cpExpectedX, cpExpectedY;
    
    // Cross coverage for actual motion
    crossActual: cross cpActualX, cpActualY;
  endgroup
  
  // Constructor to initialize the coverage analysis
  function new(virtual MemoryInterface memInterface, mailbox monitorMailbox);
    this.memInterface = memInterface;
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
