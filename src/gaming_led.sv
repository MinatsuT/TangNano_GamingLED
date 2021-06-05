module gaming_led (
  input iCLOCK,
  input iRESET_n,
  output [2:0] oLED // RGB(Actieve-Low)
  );
  
  // Color phase clock
  logic [23:0] rPHASE_CLK;
  always_ff @(posedge iCLOCK or negedge iRESET_n) begin
    if (!iRESET_n)
    rPHASE_CLK <= 0;
    else if (rPHASE_CLK < 24'd06_0000)
    rPHASE_CLK <= rPHASE_CLK+1;
    else
    rPHASE_CLK <= 24'd0;
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
  logic signed [10:0] wR_DIFF;
  logic signed [10:0] wR;
  assign wR_DIFF = 512-rR_PHASE;
  assign wR = 512 - ((wR_DIFF >= 0) ? wR_DIFF : -wR_DIFF);
  logic signed [10:0] wG_DIFF;
  logic signed [10:0] wG;
  assign wG_DIFF = 512-rG_PHASE;
  assign wG = 512 - ((wG_DIFF >= 0) ? wG_DIFF : -wG_DIFF);
  logic signed [10:0] wB_DIFF;
  logic signed [10:0] wB;
  assign wB_DIFF = 512-rB_PHASE;
  assign wB = 512 - ((wB_DIFF >= 0) ? wB_DIFF : -wB_DIFF);

  // RGB intensities
  logic [7:0] rPWM_R = 0;
  logic [7:0] rPWM_G = 0;
  logic [7:0] rPWM_B = 0;
  always_ff @( posedge iCLOCK) begin
    if (wR>255) begin
      rPWM_R <= 255;
    end else if (wR<0) begin
      rPWM_R <= 0;
    end else begin
      rPWM_R <= wR[7:0];
    end
    
    if (wG>255) begin
      rPWM_G <= 255;
    end else if (wG<0) begin
      rPWM_G <= 0;
    end else begin
      rPWM_G <= wG[7:0];
    end
    
    if (wB>255) begin
      rPWM_B <= 255;
    end else if (wB<0) begin
      rPWM_B <= 0;
    end else begin
      rPWM_B <= wB[7:0];
    end
  end

  // RGB LED out with PWM
  logic [7:0] rPWM_CNT;
  always_ff @(posedge iCLOCK or negedge iRESET_n) begin
    if (!iRESET_n)
    rPWM_CNT <= 8'd0;
    else 
    rPWM_CNT <= rPWM_CNT+1;
  end
  
  assign oLED[2] = (rPWM_CNT <= (rPWM_R>>1)) ? 1'b0 : 1'b1;
  assign oLED[1] = (rPWM_CNT <= (rPWM_G>>3)) ? 1'b0 : 1'b1;
  assign oLED[0] = (rPWM_CNT <= rPWM_B) ? 1'b0 : 1'b1;
 
endmodule
