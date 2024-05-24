`timescale 1ns/1ps

class monitor;

  // Loop variable
  int j;

  // Virtual interface handle
  virtual MotionEstimationInterface mem_intf;
  
  // Mailbox handles for communication with scoreboard and coverage
  mailbox mon2scb;
  mailbox mon2cov;
  
  // Constructor: Initializes the virtual interface and mailboxes
  function new(virtual MotionEstimationInterface mem_intf, mailbox mon2scb, mailbox mon2cov);
    this.mem_intf = mem_intf;
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
  endfunction
  
  // Main monitoring task: Observes DUT activity, captures transactions, and communicates with scoreboard and coverage
  task main;
    $display("================================================= Monitor Main Task =================================================\n");
    forever begin
      Transaction trans, cov_trans;
      trans = new();
      wait(mem_intf.start == 1); // Wait for start signal from DUT
      @(posedge mem_intf.ME_MONITOR.clk);
      trans.referenceMemory = mem_intf.referenceMemory; // Capture reference memory state
      trans.searchMemory = mem_intf.searchMemory; // Capture search memory state
      @(posedge mem_intf.ME_MONITOR.clk);
      trans.expectedXMotion = `MON_IF.expectedXMotion;
      trans.expectedYMotion = `MON_IF.expectedYMotion;
      wait(`MON_IF.completed); // Wait for completion signal from DUT
      $display("[MONITOR_INFO]    :: COMPLETED");
      trans.bestDistance = `MON_IF.bestDistance;
      trans.actualXMotion = `MON_IF.motionX;
      trans.actualYMotion = `MON_IF.motionY;

      // Adjust actualXMotion and actualYMotion for signed values
      if (trans.actualXMotion >= 8)
        trans.actualXMotion = trans.actualXMotion - 16;
      if (trans.actualYMotion >= 8)
        trans.actualYMotion = trans.actualYMotion - 16;
        
      $display("[MONITOR_INFO]    :: DUT OUTPUT Packet motionX: %d and motionY: %d", trans.actualXMotion, trans.actualYMotion);

      // Copy transaction data for coverage
      cov_trans = new trans; 
      
      // Send transaction to scoreboard and coverage
      mon2scb.put(trans); 
      mon2cov.put(cov_trans); 
    end
  endtask
  
endclass
