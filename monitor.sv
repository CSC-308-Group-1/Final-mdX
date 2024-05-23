`timescale 1ns/1ps

class monitor;

  // Loop variable
  int j;

  // Virtual interface handle
  virtual ME_interface mem_intf;
  
  // Mailbox handles for communication with scoreboard and coverage
  mailbox mon2scb;
  mailbox mon2cov;
  
  // Constructor: Initializes the virtual interface and mailboxes
  function new(virtual ME_interface mem_intf, mailbox mon2scb, mailbox mon2cov);
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
      trans.R_mem = mem_intf.R_mem; // Capture R memory state
      trans.S_mem = mem_intf.S_mem; // Capture S memory state
      @(posedge mem_intf.ME_MONITOR.clk);
      trans.Expected_motionX = `MON_IF.Expected_motionX;
      trans.Expected_motionY = `MON_IF.Expected_motionY;
      wait(`MON_IF.completed); // Wait for completion signal from DUT
      $display("[MONITOR_INFO]    :: COMPLETED");
      trans.BestDist = `MON_IF.BestDist;
      trans.motionX = `MON_IF.motionX;
      trans.motionY = `MON_IF.motionY;

      // Adjust motionX and motionY for signed values
      if (trans.motionX >= 8)
        trans.motionX = trans.motionX - 16;
      if (trans.motionY >= 8)
        trans.motionY = trans.motionY - 16;
        
      $display("[MONITOR_INFO]    :: DUT OUTPUT Packet motionX: %d and motionY: %d", trans.motionX, trans.motionY);

      // Copy transaction data for coverage
      cov_trans = new trans; 
      
      // Send transaction to scoreboard and coverage
      mon2scb.put(trans); 
      mon2cov.put(cov_trans); 
    end
  endtask
  
endclass
