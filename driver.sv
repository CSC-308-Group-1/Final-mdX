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
      `DRIV_IF.searchMemory[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      `DRIV_IF.referenceMemory[j] <= 0;
    wait(mem_intf.start);
    $display(" ================================================= [DRIVER_INFO] All Memories Set =================================================");
  endtask
  
  // Drive task: Drives transactions into DUT through the interface
  task drive;
    Transaction trans;
    forever begin
      gen2driv.get(trans);
      $display(" ================================================= [DRIVER_INFO] :: Driving Transaction %0d ================================================= ", no_transactions);
      mem_intf.referenceMemory = trans.referenceMemory;  // Drive referenceMemory to interface
      mem_intf.searchMemory = trans.searchMemory;  // Drive searchMemory to interface
      mem_intf.start = 1; 
      @(posedge mem_intf.ME_DRIVER.clk);
      `DRIV_IF.expectedXMotion <= trans.expectedXMotion;  // Drive Expected X Motion to interface
      `DRIV_IF.expectedYMotion <= trans.expectedYMotion;  // Drive Expected Y Motion to interface
      $display("[DRIVER_INFO]     :: Driver Packet Expected X Motion: %d and Expected Y Motion: %d", trans.expectedXMotion, trans.expectedYMotion);       
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
