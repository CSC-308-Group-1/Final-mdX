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
    $display(">>>> [SCOREBOARD] :: Starting Main Task");     
    forever begin
      mon2scb.get(trans); // Get transaction from monitor
      
      // Adjust motionX and motionY for signed values
      motionX = (trans.motionX >= 8) ? trans.motionX - 16 : trans.motionX;
      motionY = (trans.motionY >= 8) ? trans.motionY - 16 : trans.motionY;

      $display("\n==== [SCOREBOARD] :: Transaction Details ====");
      $display("* Expected Motion: X = %0d, Y = %0d", trans.Expected_motionX, trans.Expected_motionY);
      $display("* Actual Motion:   X = %0d, Y = %0d", motionX, motionY);
      $display("* Best Distance:   %0d", trans.BestDist);
      $display("================================================");

      // Evaluate the transaction based on BestDist value
      if (trans.BestDist == 8'hFF) begin
        $display("[SCOREBOARD] :: No Match Found in the Search Window");
        nomatch++;
      end
      else if (trans.BestDist == 8'h00) begin
        $display("[SCOREBOARD] :: Perfect Match Found");
        perfect++;
      end
      else begin
        $display("[SCOREBOARD] :: Partial Match Found");
        partial++;
      end

      // Compare DUT motion values with expected values
      if (motionX == trans.Expected_motionX && motionY == trans.Expected_motionY) begin
        $display("[SCOREBOARD] :: Motion Matches Expected Values");
      end
      else begin
        $display("[SCOREBOARD] :: Motion Does Not Match Expected Values");
      end

      $display("====================================================\n");  
      no_transactions++;
      $display("[SCOREBOARD] :: Total Transactions Processed: %d", no_transactions);
      $display("----------------------------------------------------\n");

      // Sample cross-coverage of motion vectors
      sample_coverage(motionX, motionY);
    end
  endtask

  // Summary function: Displays a summary of the test results
  function void summary();
    $display("----------------------------------------------------");
    $display("|                Test Results Summary              |");
    $display("----------------------------------------------------");
    $display("| Total Packets        : %6d                       |", no_transactions);
    $display("| Perfect Matches      : %6d                       |", perfect);
    $display("| Partial Matches      : %6d                       |", partial);
    $display("| No Matches           : %6d                       |", nomatch);
    $display("----------------------------------------------------");
  endfunction

  // Cross-coverage of motion vectors and match types
  covergroup motion_coverage;
    coverpoint motionX;
    coverpoint motionY;
    cross motionX, motionY;
  endgroup

  // Instantiation of the covergroup
  motion_coverage mcg = new();

  // Function to sample cross-coverage
  function void sample_coverage(int x, int y);
    mcg.motionX = x;
    mcg.motionY = y;
    mcg.sample();
  endfunction
  
endclass
