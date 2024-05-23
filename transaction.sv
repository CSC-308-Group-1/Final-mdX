//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Transaction.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Transaction Class 
//////////////////////////////////////////////////////////////////////////////////////////

class Transaction;
  logic [7:0] R_mem[`RMEM_MAX-1:0];
  rand logic [7:0]   S_mem[`SMEM_MAX-1:0];
  rand integer Expected_motionX;
  rand integer Expected_motionY;
  integer motionX;
  integer motionY;
  logic [7:0]   BestDist;

  rand int rand_mismatch_index;
  
  constraint Expec_Motion_const { 
                                  Expected_motionX dist {[-8:0]:=10 ,[1:7]:=10};
                                  Expected_motionY dist {[-8:0]:=10 ,[1:7]:=10}; //==-8;//inside {[-8:7]};
                                  };

  constraint mismatch_index_const {
                                   soft rand_mismatch_index dist { [0:255] :=10 , [256:511]:=10, [512:767]:=10}; 
                                  };

  constraint S_MEM_const { foreach(S_mem[i])
                              S_mem[i] inside {[0:`SMEM_MAX-1]};
                          };


function void display();
  
  $display(" ######################################## [TRANSACTION_INFO] :: SMEM Generated #######################################");
  for(int j = 0; j < `SMEM_MAX; j++)begin
    if(j%32 == 0) $display("  ");
    $write("%h  ",S_mem[j]);
    if(j == 1023) $display("  "); 
  end
  $display(" ######################################## [TRANSACTION_INFO] :: RMEM Generated #######################################");
  for(int j = 0; j < `RMEM_MAX; j++)begin
    if(j%16 == 0) $display("  ");
    $write("%h ", R_mem[j]);
    if(j == 255) $display("  ");
  end
  
  $display("\n[TRANSACTION_INFO] :: Rand_mismatch_index : %0d ",rand_mismatch_index);     
  $display("[TRANSACTION_INFO] :: Expected_motionX : %0d ",Expected_motionX);
  $display("[TRANSACTION_INFO] :: Expected_motionY : %0d ",Expected_motionY);
endfunction

function void gen_Rmem();
  foreach(R_mem[i])begin
    
      R_mem[i] = S_mem[32*8+8+(((i/16)+Expected_motionY)*32)+((i%16)+Expected_motionX)];        //Full match
      if(i==rand_mismatch_index)   
        R_mem[i] = $urandom_range(0,255);                                          //Partial Match
      
  end
  if(rand_mismatch_index>=400)begin
        R_mem.shuffle();                                                                        //No match
  end

endfunction


endclass