module gaming_led (
  input iCLOCK,
  input iRESET_n,
  output [2:0] oLED // RGB(Actieve-Low)
  );
  
  // Color phase clock
  logic [23:0] rPHASE_CLK;
  always_ff @( posedge iCLOCK or negedge iRESET_n ) begin
    if (!iRESET_n)
    rPHASE_CLK <= 0;
    else if (rPHASE_CLK < 24'd6_0000)
    rPHASE_CLK <= rPHASE_CLK+1;
    else
    rPHASE_CLK <= 0;
  end
  
  // Color phase
  logic [10:0] rR_PHASE = 256*0;
  logic [10:0] rG_PHASE = 256*2;
  logic [10:0] rB_PHASE = 256*4;
  always_ff @( posedge iCLOCK or negedge iRESET_n ) begin 
    if (!iRESET_n) begin
      rR_PHASE <= 256*0;
      rG_PHASE <= 256*2;
      rB_PHASE <= 256*4;
    end else if (rPHASE_CLK == 0) begin
      rR_PHASE <= (rR_PHASE == 11'h5ff) ? 0 : rR_PHASE+1;
      rG_PHASE <= (rG_PHASE == 11'h5ff) ? 0 : rG_PHASE+1;
      rB_PHASE <= (rB_PHASE == 11'h5ff) ? 0 : rB_PHASE+1;
    end else begin
      rR_PHASE <= rR_PHASE;
      rG_PHASE <= rG_PHASE;
      rB_PHASE <= rB_PHASE;
    end
  end
  
  // Color transition
  logic signed [10:0] wR;
  assign wR = 512 - ((512-rR_PHASE >= 0) ? 512-rR_PHASE : -(512-rR_PHASE));
  logic signed [10:0] wG;
  assign wG = 512 - ((512-rG_PHASE >= 0) ? 512-rG_PHASE : -(512-rG_PHASE));
  logic signed [10:0] wB;
  assign wB = 512 - ((512-rB_PHASE >= 0) ? 512-rB_PHASE : -(512-rB_PHASE));
  
  // RGB intensities
  logic [7:0] rPWM_R, rPWM_G, rPWM_B;
  always_ff @( posedge iCLOCK ) begin
    rPWM_R <= (wR>255) ? 255 : (wR<0) ? 0 : wR[7:0];
    rPWM_G <= (wG>255) ? 255 : (wG<0) ? 0 : wG[7:0];
    rPWM_B <= (wB>255) ? 255 : (wB<0) ? 0 : wB[7:0];
  end
  
  // RGB LED out with PWM
  logic [7:0] rPWM_CNT;
  always_ff @( posedge iCLOCK or negedge iRESET_n ) begin
    if (!iRESET_n)
    rPWM_CNT <= 0;
    else 
    rPWM_CNT <= rPWM_CNT+1;
  end
  
  assign oLED[2] = (rPWM_CNT <= (rPWM_R>>1)) ? 1'b0 : 1'b1;
  assign oLED[1] = (rPWM_CNT <= (rPWM_G>>3)) ? 1'b0 : 1'b1;
  assign oLED[0] = (rPWM_CNT <= rPWM_B) ? 1'b0 : 1'b1;
  
endmodule
