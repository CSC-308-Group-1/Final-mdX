`timescale 1ns/1ps

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"

class environment;
  generator gen;                          // Create Handle for Generator,Driver,Monitor and Scoreboard
  driver driv;
  monitor mon;
  scoreboard scb;
  mailbox gen2driv, mon2scb,mon2cov;      //Create Mailbox Handle for Gen-Driver,Mon-Scoreboard and Mon-Coverage class
  coverage cov;                 
  event gen_ended;
  event mon_done;
  
  virtual ME_interface mem_intf;          //Create Virtual Interface Handle
	
  function new(virtual ME_interface mem_intf);          //Constructor //,virtual ROM_R memR_u,virtual ROM_S memS_u
    this.mem_intf = mem_intf;   
    gen2driv = new();
    mon2scb = new();
    mon2cov = new();
    gen = new(gen2driv,gen_ended);
    driv = new(mem_intf, gen2driv); //, memR_u, memS_u
    mon = new(mem_intf, mon2scb,mon2cov);
    scb = new(mon2scb);
    cov = new(mem_intf,mon2cov);
  endfunction
  
  task pre_test();
    $display("############################### [ENV_INFO] Driver start ###########################");
    driv.start();                                         //Initialise default value
  endtask
  
  task test();
    fork
      gen.main();
      driv.main();
      mon.main();
      scb.main();
      cov.cove();
    join_any
  endtask
  
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.trans_count == driv.no_transactions);
    wait(gen.trans_count == scb.no_transactions);
    $display (" Motion Estimator Coverage Report = %0.2f %% \n", cov.ME_Coverage);        //Print coverage report
    scb.summary();                                                                        
  endtask 
  
  task run;
    pre_test();
    $display("################################### [ENV_INFO] Done with pre test, Test Started.#######################");
    test();
    post_test();
    $finish;
  endtask
  
endclass;
