`timescale 1ns/1ps

class coverage;

  real ME_Coverage;
  virtual ME_interface mem_intf;
  mailbox mon2cov;
  Transaction trans;
      
  covergroup ME_covergroup;
    option.per_instance = 1;
    
      Best_dist: coverpoint trans.BestDist ; // autobins
      Expect_motionX: coverpoint trans.Expected_motionX
      {
        //bins valid_values = {[-9:6]};
        bins neg_val[] = {[-8:-1]};
        bins zero_val  = {0};
        bins pos_val[] = {[1:7]};

      }
      Expect_motionY: coverpoint trans.Expected_motionY
      {
        //bins valid_values = {[-9:6]};
        bins neg_val[] = {[-8:-1]};
        bins zero_val  = {0};
        bins pos_val[] = {[1:7]};

      }
      Actual_motionX : coverpoint trans.motionX
      {
        //bins valid_values = {[-9:6]};
        bins neg_val[] = {[-8:-1]};
        bins zero_val  = {0};
        bins pos_val[] = {[1:7]};

      }
      Actual_motionY : coverpoint trans.motionY
      {
        //bins valid_values = {[-9:6]};
        bins neg_val[] = {[-8:-1]};
        bins zero_val  = {0};
        bins pos_val[] = {[1:7]};

      }
    
    	
  endgroup
  
  function new(virtual ME_interface mem_intf,mailbox mon2cov);
      this.mem_intf = mem_intf;
      this.mon2cov = mon2cov;
      ME_covergroup = new();
  endfunction
   
  
  task cove();
   begin
     forever 
      begin
       mon2cov.get(trans);
        ME_covergroup.sample(); // method for sampling coverage
        ME_Coverage = ME_covergroup.get_coverage();
      end
    end
  endtask
  
endclass
