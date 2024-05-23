`timescale 1ns/1ps

`include "defines.sv"

class driver;

  // Number of transactions and loop variable
  int no_transactions, j;             

  // Virtual interface handle
  virtual ME_interface mem_intf;      

  // Mailbox handle for Gen2Driver
  mailbox gen2driv;                   
  
  // Constructor: Initializes the virtual interface and mailbox
  function new(virtual ME_interface mem_intf, mailbox gen2driv);
    this.mem_intf = mem_intf; 
    this.gen2driv = gen2driv;     
  endfunction
  
  // Start task: Resets the values in memories before starting the operation
  task start;
    $display(" ================================================= Start of driver, mem_intf.start: %b =================================================\n", mem_intf.start);
    wait(!mem_intf.start);
    $display(" ================================================= [DRIVER_INFO] Initialized to Default =================================================\n");
    for(j = 0; j < `SMEM_MAX; j++)
      `DRIV_IF.S_mem[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      `DRIV_IF.R_mem[j] <= 0;
    wait(mem_intf.start);
    $display(" ================================================= [DRIVER_INFO] All Memories Set =================================================");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction trans;
    forever begin
      gen2driv.get(trans);
      $display(" ================================================= [DRIVER_INFO] :: Driving Transaction %0d ================================================= ", no_transactions);
      mem_intf.R_mem = trans.R_mem;  // Drive R_mem to interface
      mem_intf.S_mem = trans.S_mem;  // Drive S_mem to interface
      mem_intf.start = 1; 
      @(posedge mem_intf.ME_DRIVER.clk);
      `DRIV_IF.Expected_motionX <= trans.Expected_motionX;  // Drive Expected Motion X to interface
      `DRIV_IF.Expected_motionY <= trans.Expected_motionY;  // Drive Expected Motion Y to interface
      $display("[DRIVER_INFO]     :: Driver Packet Expected_motionX: %d and Expected_motionY: %d", trans.Expected_motionX, trans.Expected_motionY);       
      wait(mem_intf.completed == 1);  // Wait for DUT to signal completion
      mem_intf.start = 0;
      $display("[DRIVER_INFO]     :: DUT sent completed = 1 ");
      no_transactions++;
      @(posedge mem_intf.ME_DRIVER.clk);
    end
  endtask

  // Main task: Starts the driver and continuously drives transactions
  task main;
    $display("[DRIVER_INFO]   :: ================================================= Driver Main Started =================================================");
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
