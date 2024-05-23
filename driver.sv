//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Driver.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Driver Class 
//////////////////////////////////////////////////////////////////////////////////////////

`include "defines.sv"
class driver;
  int no_transactions, j;             //Number of transactions
  virtual ME_interface mem_intf;      //Virtual interface handle
  mailbox gen2driv;                   //creating mailbox handle for Gen2Driver
  
  //constructor
  function new(virtual ME_interface mem_intf,mailbox gen2driv); //virtual ROM_R memR_u,virtual ROM_S memS_u,
    this.mem_intf = mem_intf; 
    this.gen2driv = gen2driv;     
  endfunction
  
  //Start Task to reset the values in Memories
  task start;
    $display(" ####################################### Start of driver, mem_intf.start: %b ############################################\n", mem_intf.start);
    wait(!mem_intf.start);
    $display(" ####################################### [DRIVER_INFO] Initialised to Default ###########################################\n");
    for(j = 0; j < `SMEM_MAX; j++)
      `DRIV_IF.S_mem[j] <= 0;
    for(j = 0; j < `RMEM_MAX; j++)
      `DRIV_IF.R_mem[j] <= 0;
    wait(mem_intf.start);
    $display(" ####################################### [DRIVER_INFO] All Mems Set #####################################################");
  endtask
  
  //Drive Packets into DUT through Interface
  task drive;
    Transaction trans;
    forever
     begin
      gen2driv.get(trans);
      $display(" ##################################### [DRIVER_INFO] :: Driving Transaction %0d ######################################## ",no_transactions);
      mem_intf.R_mem = trans.R_mem;                                      //Drive Mem to intf
      mem_intf.S_mem = trans.S_mem;
      mem_intf.start=1; 
      @(posedge mem_intf.ME_DRIVER.clk);
      //`DRIV_IF.S_mem <= trans.S_mem;
      `DRIV_IF.Expected_motionX <= trans.Expected_motionX;                //Driver Exp Motion pkt to intf
      `DRIV_IF.Expected_motionY <= trans.Expected_motionY;
      $display("[DRIVER_INFO]     :: Driver Packet Expected_motionX: %d and Expected_motionY: %d", trans.Expected_motionX, trans.Expected_motionY);       
      wait(mem_intf.completed == 1);                                      //Wait fot DUT completion
      mem_intf.start = 0;
      $display("[DRIVER_INFO]     :: DUT sent completed = 1 ");
      no_transactions++;
       @(posedge mem_intf.ME_DRIVER.clk);
    end
  endtask

  task main;
    $display("[DRIVER_INFO]   :: ############################### Driver Main Started ############################");
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