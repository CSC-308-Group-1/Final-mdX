//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Test.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Test Class 
//////////////////////////////////////////////////////////////////////////////////////////

`include "environment.sv"
program test(ME_interface mem_intf); //,ROM_R memR_u,ROM_S memS_u
  
  //Environment Handle
  environment env;
  
  initial begin
    env = new(mem_intf);      //, memR_u, memS_u
    env.gen.trans_count = `TRANSACTION_COUNT;                                //Total Transaction count
    env.run();                                                              //Run task to start
  end
endprogram