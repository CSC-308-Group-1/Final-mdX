
`timescale 1ns/1ps

class scoreboard;

  // Mailbox for receiving transactions from the monitor
  mailbox mon2scb; 
  
  // Counters for different types of matches and transactions
  int no_transactions, perfect, nomatch, partial;
  
  // Variables for motion values
  integer motionX, motionY;

  // Constructor: Initializes the mailbox handle
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb; 
  endfunction
  
  // Main task: Processes transactions and evaluates their results
  task main;
    Transaction trans; 
    partial = 0;
    perfect = 0;
    nomatch = 0;
    $display("================================================= [SCOREBOARD_INFO] :: Main Task Starts =================================================");
    forever begin
      mon2scb.get(trans); // Get transaction from monitor
      $display("[SCOREBOARD_INFO] :: Expected_motionX : %d, Expected_motionY : %d", trans.Expected_motionX, trans.Expected_motionY);
      
      // Adjust motionX and motionY for signed values
      if (trans.motionX >= 8)
        motionX = trans.motionX - 16;
      else
        motionX = trans.motionX;

      if (trans.motionY >= 8)
        motionY = trans.motionY - 16;
      else
        motionY = trans.motionY;

    $display("\n================================================= [SCOREBOARD_RESULTS] =================================================");

  // Evaluate the transaction based on BestDist value
  if (trans.BestDist == 8'hFF) begin
    $display("[SCOREBOARD_INFO] :: Reference Memory Not Found in the Search Window!");
    nomatch++;
  end
  else begin
    if (trans.BestDist == 8'h00) begin
      $display("[SCOREBOARD_INFO] :: Perfect Match Found for Reference Memory in the Search Window"); 
      $display("[SCOREBOARD_INFO] :: BestDist = %0d, motionX = %0d, motionY = %0d, Expected_motionX = %0d, Expected_motionY = %0d", 
                trans.BestDist, motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
      perfect++;
    end
    else begin
      $display("[SCOREBOARD_INFO] :: Partial Match Found: BestDist = %0d, motionX = %0d, motionY = %0d, Expected_motionX = %0d, Expected_motionY = %0d", 
                trans.BestDist, motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
      partial++;
    end
  end

  // Compare DUT motion values with expected values
  if (motionX == trans.Expected_motionX && motionY == trans.Expected_motionY) begin
    $display("[SCOREBOARD_INFO] :: Motion As Expected :: DUT motionX = %0d, DUT motionY = %0d, Expected_motionX = %0d, Expected_motionY = %0d", 
              motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
  end
  else begin
    $display("[SCOREBOARD_INFO] :: Motion Not As Expected :: DUT motionX = %0d, DUT motionY = %0d, Expected_motionX = %0d, Expected_motionY = %0d", 
              motionX, motionY, trans.Expected_motionX, trans.Expected_motionY);
  end

$display("========================================================================================================================\n");  
no_transactions++;
$display("[SCOREBOARD_INFO] :: Number of Transaction Packets: %d", no_transactions);
$display("------------------------------------------------------------------------------------------------------------------------\n");
end
endtask


  // Summary function: Displays a summary of the test results
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
