//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Monitor.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Monitor Class 
//////////////////////////////////////////////////////////////////////////////////////////

class monitor;
  int j;
  //Virtual interface handle
  virtual ME_interface mem_intf;
  
  //Mailbox handle for coverage and scoreboard
  mailbox mon2scb;
  mailbox mon2cov;
  
  //constructor
  function new(virtual ME_interface mem_intf,mailbox mon2scb,mailbox mon2cov);
    this.mem_intf = mem_intf;
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
  endfunction
  
  task main;
    $display("############################### Monitor main #############################\n");
    forever begin
      Transaction trans,cov_trans;
      trans = new();
      wait(mem_intf.start ==1);
      @(posedge mem_intf.ME_MONITOR.clk);
        trans.R_mem = mem_intf.R_mem;
        trans.S_mem = mem_intf.S_mem;
      @(posedge mem_intf.ME_MONITOR.clk);
        trans.Expected_motionX = `MON_IF.Expected_motionX;
        trans.Expected_motionY = `MON_IF.Expected_motionY;
     wait(`MON_IF.completed);
     $display("[MONITOR_INFO]    :: COMPLETED");                                                 //collect data from  DUT
     trans.BestDist = `MON_IF.BestDist;   
      trans.motionX = `MON_IF.motionX;
      trans.motionY = `MON_IF.motionY;
      if(trans.motionX >= 8)
          trans.motionX = trans.motionX - 16;
       else
          trans.motionX = trans.motionX;
      if(trans.motionY >= 8)
          trans.motionY = trans.motionY - 16;
       else
          trans.motionY = trans.motionY;
      $display("[MONITOR_INFO]    :: DUT OUTPUT Packet motionX: %d and motionY: %d", trans.motionX, trans.motionY);
        cov_trans = new trans;                          //Copy packet data to coverage class 
        mon2scb.put(trans);                             // Mailbox to Scoreboard
        mon2cov.put(cov_trans);                         // Mailbox to Coverage class

    end
   
  endtask
  
endclass