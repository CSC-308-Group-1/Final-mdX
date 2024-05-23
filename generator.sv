//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Generator.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Generator Class 
//////////////////////////////////////////////////////////////////////////////////////////
class generator;

  //Transaction class Handle
  rand Transaction trans ;

  //Number of Transaction
  int  trans_count;

  //mailbox Handle
  mailbox gen2driv;

  event ended;

  //Constructor
  function new(mailbox gen2driv,event ended);
    this.gen2driv = gen2driv;
    this.ended    = ended;
    //trans = new();
  endfunction

  
  task main();
    $display("########################### [GEN_INFO]: Generator Main Task #########################");
    repeat(trans_count) begin
      trans = new();
    if( !trans.randomize()) $fatal("[GEN_ERROR] :: Randomization failed"); //with {trans.rand_mismatch_index <256 ;}  //Randomise Transaction Class
      trans.gen_Rmem();                                                                                               //Generate Rmem from Smem
      //$display("[GEN_INFO]: Transaction values: x: %d and y: %d", trans.Expected_motionX, trans.Expected_motionY);
      trans.display();
      gen2driv.put(trans);                                                                                            //Put Transaction Packet into mailbox

    end
    -> ended; 
  endtask

endclass