`include "../ex3/fulladder.v"
module  add4( sum, co, a, b, ci);

  input   [3:0] a, b;
  input   ci;
  output  [3:0] sum;
  output  co;
  
  wire cin2;
  wire cin3;
  wire cin4;
  
  fulladder fAdd1( sum[0], cin2, a[0], b[0], ci);
  fulladder fAdd2( sum[1], cin3, a[1], b[1], cin2);
  fulladder fAdd3( sum[2], cin4, a[2], b[2], cin3);
  fulladder fAdd4( sum[3], co, a[3], b[3], cin4);
  
endmodule
