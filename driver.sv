`timescale 1ns/1ps

`include "defines.sv"

class driver;

  // Number of transactions and loop variable
  int trans_count, idx;             

  // Virtual interface handle
  virtual ME_interface vif_handle;      

  // Mailbox handle for Gen2Driver
  mailbox tx_mailbox;                   
  
  // Constructor: Initializes the virtual interface and mailbox
  function new(virtual ME_interface vif_handle, mailbox tx_mailbox);
    this.vif_handle = vif_handle; 
    this.tx_mailbox = tx_mailbox;     
  endfunction
  
  // Start task: Resets the values in memories before starting the operation
  task start;
    $display("\n==================================================\n| Start of driver, vif_handle.start: %b           |\n==================================================\n", vif_handle.start);
    wait(!vif_handle.start);
    $display("\n==================================================\n| [DRIVER_INFO] Initialized to Default            |\n==================================================\n");
    for(idx = 0; idx < `SMEM_MAX; idx++)
      `DRIV_IF.S_mem[idx] <= 0;
    for(idx = 0; idx < `RMEM_MAX; idx++)
      `DRIV_IF.R_mem[idx] <= 0;
    wait(vif_handle.start);
    $display("\n==================================================\n| [DRIVER_INFO] All Memories Set                  |\n==================================================\n");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction txn;
    forever begin
      tx_mailbox.get(txn);
      $display("\n==================================================\n| [DRIVER_INFO] Driving Transaction %0d            |\n==================================================\n", trans_count);
      vif_handle.R_mem = txn.R_mem;  // Drive R_mem to interface
      vif_handle.S_mem = txn.S_mem;  // Drive S_mem to interface
      vif_handle.start = 1; 
      @(posedge vif_handle.ME_DRIVER.clk);
      `DRIV_IF.Expected_motionX <= txn.Expected_motionX;  // Drive Expected Motion X to interface
      `DRIV_IF.Expected_motionY <= txn.Expected_motionY;  // Drive Expected Motion Y to interface
      $display("\n[DRIVER_INFO]     :: Driver Packet Expected_motionX: %d and Expected_motionY: %d\n", txn.Expected_motionX, txn.Expected_motionY);       
      wait(vif_handle.completed == 1);  // Wait for DUT to signal completion
      vif_handle.start = 0;
      $display("\n[DRIVER_INFO]     :: DUT sent completed = 1 \n");
      trans_count++;
      @(posedge vif_handle.ME_DRIVER.clk);
    end
  endtask

  // Main task: Starts the driver and continuously drives transactions
  task main;
    $display("\n[DRIVER_INFO]   :: =================================================\n| Driver Main Started                                              |\n==================================================\n");
    forever begin
      fork
        begin
          forever
            drive();
        end
      join
      disable fork;
    end
  endtask
        
endclass
