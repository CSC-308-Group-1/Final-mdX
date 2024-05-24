`timescale 1ns/1ps

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"

class environment;
  // Handles for Generator, Driver, Monitor, Scoreboard, and Coverage
  generator gen;                          
  driver driv;
  monitor mon;
  scoreboard scb;
  coverageanalysis cov;                 
  
  // Mailbox handles for communication between components
  mailbox genToDriver, monitorToScoreboard, monitorToCoverage;      
  
  // Events for synchronization
  event generatorDone;
  event monitorDone;
  
  // Virtual interface handle
  virtual MemoryInterface memInterface;          

  // Constructor: Initializes the virtual interface and component instances
  function new(virtual MemoryInterface memInterface);
    this.memInterface = memInterface;   
    genToDriver = new();
    monitorToScoreboard = new();
    monitorToCoverage = new();
    gen = new(genToDriver, generatorDone);
    driv = new(memInterface, genToDriver);
    mon = new(memInterface, monitorToScoreboard, monitorToCoverage);
    scb = new(monitorToScoreboard);
    cov = new(memInterface, monitorToCoverage);
  endfunction
  
  // Pre-test task: Initializes default values
  task preTest();
    $display("================================================= [ENV_INFO] Driver start ===============================================");
    driv.start();  // Initialize default values
  endtask
  
  // Test task: Executes the main tasks of all components
  task test();
    fork
      gen.main();
      driv.main();
      mon.main();
      scb.main();
      cov.trackCoverage();
    join_any
  endtask
  
  // Post-test task: Waits for completion and prints the coverage report
  task postTest();
    wait(generatorDone.triggered);
    wait(gen.trans_count == driv.no_transactions);
    wait(gen.trans_count == scb.no_transactions);
    $display (" Coverage Report = %0.2f %% \n", cov.coverageMetric);  // Print coverage report
    scb.summary();  // Print summary
  endtask 
  
  // Run task: Executes the complete test sequence
  task run;
    preTest();
    $display("================================================= [ENV_INFO] Done with pre-test, Test Started. =================================================");
    test();
    postTest();
    $finish;
  endtask
  
endclass;
