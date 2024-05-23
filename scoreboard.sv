//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Scoreboard.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Scoreboard Class 
//////////////////////////////////////////////////////////////////////////////////////////

class scoreboard;
  mailbox mon2scb; 
  int no_transactions, perfect,nomatch,partial;
  integer motionX, motionY;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb; 
    //ME_covergroup = new();
  endfunction
  
  task main;
    Transaction trans; 
    partial = 0;
    perfect = 0;
    nomatch = 0;
    $display("############################################ [SCOREBOARD_INFO] :: Main Task Starts #########################################");     
    forever begin
      mon2scb.get(trans);
      $display("[SCOREBOARD_INFO] :: Expected_motionX : %d, Expected_motionY : %d", trans.Expected_motionX, trans.Expected_motionY);
    if (trans.motionX >= 8)
      motionX = trans.motionX - 16;
    else
      motionX = trans.motionX;

    if (trans.motionY >= 8)
      motionY = trans.motionY - 16;
    else
      motionY = trans.motionY;
  $display("\n #############################################  [SCOREBOARD_RESULTS] ############################################### ");

  if (trans.BestDist == 8'hFF) begin
    $display("[SCOREBOARD_INFO] :: Reference Memory Not Found in the Search Window!");
    nomatch++;
  end
  else begin
      if (trans.BestDist == 8'h00)begin
        $display("[SCOREBOARD_INFO] :: Perfect Match Found for Reference Memory in the Search Window"); 
        $display("[SCOREBOARD_INFO] :: BestDist = %0d, motionX  = %0d , motionY =  %0d Expected motionX  = %0d , Expected motionY =  %0d ", trans.BestDist, motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
        perfect++;
      end
      else begin
        $display("[SCOREBOARD_INFO] :: Partial Match Found: BestDist = %0d, motionX  = %0d , motionY =  %0d Expected motionX  = %0d , Expected motionY =  %0d ", trans.BestDist, motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
        partial++;
      end
  end

  if (motionX == trans.Expected_motionX && motionY == trans.Expected_motionY)
    $display("[SCOREBOARD_INFO] :: Motion As Expected :: DUT motionX = %0d DUT motionY = %0d Expected_motionX = %0d Expected_motionY = %0d",motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
  else
    $display("[SCOREBOARD_INFO] :: Motion Not As Expected : DUT motionX = %0d DUT motionY = %0d Expected_motionX = %0d Expected_motionY = %0d",motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
    $display(" ################################################################################################################### \n");  
      no_transactions++;
      $display("[SCOREBOARD_INFO] :: Number of Transaction Packets: %d", no_transactions);
      $display("------------------------------------------------------------------------------------------------------------------------\n");

    end


  endtask

  function void summary();
    $display("-----------------------------------------");
    $display("| Test Results                          |");
    $display("-----------------------------------------");
    $display("| Total Packets          | %6d       |", no_transactions);
    $display("| Perfect Matches        | %6d       |", perfect);
    $display("| Partial Matches        | %6d       |", partial);
    $display("| No Matches             | %6d       |", nomatch);
    $display("-----------------------------------------");
  endfunction
  
endclass
