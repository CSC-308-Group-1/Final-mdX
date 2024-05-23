//////////////////////////////////////////////////////////////////////////////////////////
//    ENGR_850 Term Project
//    File        : Assertion.sv
//    Authors     : Arok Lijo J , Chandan Gireesha , Saifulla 
//    Description : Assertion Module 
//////////////////////////////////////////////////////////////////////////////////////////

module ME_assertions(input clock, input start, input [7:0] BestDist, input [3:0] motionX, input [3:0] motionY, input completed);


  integer tmp_motionX, tmp_motionY;

  always@(*) begin
  

      if(motionX >= 8)
          tmp_motionX = motionX - 16;
       else
          tmp_motionX = motionX;
      if(motionY >= 8)
          tmp_motionY = motionY - 16;
       else
          tmp_motionY = motionY;

  end
  
  
  always @(posedge clock) begin

    // Assertion 1: Ensure that 'completed' signal is asserted when search is complete and vice-versa
    start_complete_chk: assert property (@(posedge clock) (start -> !completed));

    start_complete_chk1: assert property (@(posedge clock) (!start -> completed));

    // Assertion 2: Ensure that 'BestDist' is always within a valid range
    BestDist_valid_chk: assert property (@(posedge clock) disable iff (!start) ((BestDist >= 'h00) && (BestDist <= 'hFF)));

    // Assertion 3: Ensure that 'motionX' and 'motionY' are valid motion vectors
    Motion_vectors_chk: assert property (@(posedge clock) disable iff (!completed || !start) ((tmp_motionX >= -8) && (tmp_motionX <= 7) && (tmp_motionY >= -8) && (tmp_motionY <= 7)))
                        else
                          $display("Assertion failed at time = %0t MotionX = %0d MotionY = %d ", $time,motionX,motionY);
  end


endmodule
