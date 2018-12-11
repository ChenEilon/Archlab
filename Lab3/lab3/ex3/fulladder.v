`include "../ex2/halfadder.v"
module fulladder(sum, co, a, b, ci);

  input   a, b, ci;
  output  sum, co;

  wire hadd1_sum;
  wire hadd1_co;
  wire hadd2_sum;
  wire hadd2_co;
  
  halfadder hadd1(a, b, hadd1_sum, hadd1_co);
  halfadder hadd2(ci, hadd1_sum, hadd2_sum, hadd2_co);
  
  assign sum = hadd2_sum;
  or g0(co, hadd1_co, hadd2_co);
endmodule
