`timescale 1ns/10ps
module CS(Y, X, reset, clk);

  input clk, reset; 
  input 	[7:0] X;
  output reg [9:0] Y;
  
  //--------------------------------------
  //  \^o^/   Write your code here~  \^o^/ Meow~
  //--------------------------------------
  
  reg [7:0] x1, x2, x3, x4, x5, x6, x7, x8, x9;
  reg [7:0] Xapp;
  reg [7:0] Xavg; // sum/9
  reg [11:0] XS; // sum of x (255*9 = 2295 < 2^12)
  reg [7:0] temp; // record the closest xi for Xapp
  
  
  // STEP1: get the nine input first
  always@(posedge clk or negedge reset) begin
    if(reset) begin
      x1 <= 8'd0;
      x2 <= 8'd0;
      x3 <= 8'd0;
      x4 <= 8'd0;
      x5 <= 8'd0;
      x6 <= 8'd0;
      x7 <= 8'd0;
      x8 <= 8'd0;
      x9 <= 8'd0;
      XS <= 11'd0; 
      // not x1 plus to x9
      // because at the moment, the x is not zero
      Xavg <= 8'd0 ;
    end
    else begin
      x1 <= x2;
      x2 <= x3;
      x3 <= x4;
      x4 <= x5;
      x5 <= x6;
      x6 <= x7;
      x7 <= x8;
      x8 <= x9;
      x9 <= X;
      XS <= XS - x1 + X; // IMPORTANT: this x1 is the old one
      // IMPORTANT: cannot put Xavg = XS / 9 here!!
      // because at the moment XS is old
    end
  end
  
  // STEP2: the math part
  // we have to count whenever there's something change
  // no clk
  always@(*) begin 
    Xavg = XS / 9;
    temp = 0; // find the closest number(xi) that smaller than Xavg
    Xapp = 0;
    
    if((x1 <= Xavg) && (x1 > temp)) temp = x1;
    if((x2 <= Xavg) && (x2 > temp)) temp = x2;
    if((x3 <= Xavg) && (x3 > temp)) temp = x3;
    if((x4 <= Xavg) && (x4 > temp)) temp = x4;
    if((x5 <= Xavg) && (x5 > temp)) temp = x5;
    if((x6 <= Xavg) && (x6 > temp)) temp = x6;
    if((x7 <= Xavg) && (x7 > temp)) temp = x7;
    if((x8 <= Xavg) && (x8 > temp)) temp = x8;
    if((x9 <= Xavg) && (x9 > temp)) temp = x9;
    
      
    Xapp = temp;
    
    Y = (XS + (Xapp * 9))/ 8;
  end
endmodule

