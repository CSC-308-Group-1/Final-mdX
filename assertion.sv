`timescale 1ns/1ps

module ME_assertions(
    input clock, 
    input start, 
    input [7:0] BestDist, 
    input [3:0] motionX, 
    input [3:0] motionY, 
    input completed
);

  integer tmp_motionX, tmp_motionY;

  // Convert 4-bit signed motion vectors to 5-bit signed integers
  always @(*) begin
      if (motionX >= 8)
          tmp_motionX = motionX - 16;
      else
          tmp_motionX = motionX;

      if (motionY >= 8)
          tmp_motionY = motionY - 16;
      else
          tmp_motionY = motionY;
  end

  always @(posedge clock) begin
    // Assertion 1: Ensure that 'completed' signal is not asserted when 'start' is high
    start_complete_chk: assert property (@(posedge clock) (start -> !completed)) else
      $error("Assertion failed: start -> !completed at time %0t", $time);

    // Assertion 2: Ensure that 'completed' signal is asserted when 'start' is low
    start_complete_chk1: assert property (@(posedge clock) ((!start && !$past(start)) -> completed)) else
      $error("Assertion failed: (!start && !$past(start)) -> completed at time %0t", $time);

    // Assertion 3: Ensure that 'BestDist' is always within the valid range of 0x00 to 0xFF
    BestDist_valid_chk: assert property (@(posedge clock) disable iff (!start)
      ((BestDist >= 8'h00) && (BestDist <= 8'hFF))) else
      $error("Assertion failed: BestDist out of range at time %0t", $time);

    // Assertion 4: Ensure that 'motionX' and 'motionY' are valid motion vectors
    Motion_vectors_chk: assert property (@(posedge clock) disable iff (!completed || !start)
      ((tmp_motionX >= -8) && (tmp_motionX <= 7) && (tmp_motionY >= -8) && (tmp_motionY <= 7))) else
      $error("Assertion failed at time %0t: MotionX = %0d, MotionY = %0d", $time, tmp_motionX, tmp_motionY);
  end

endmodule
