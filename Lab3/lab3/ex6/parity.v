module parity(clk, in, reset, out);

  input clk, in, reset;
  output out;

  reg 	  out;
  reg 	  state;

  localparam zero=0, one=1;
  
  wire neg_in;
  not g0(neg_in, in);

  always @(posedge clk)
  begin
    if (reset)
      state <= zero;
    else
      case (state)
        zero:
          state <= in;
        one:
          state <= neg_in;
      endcase
    end

  always @(state) 
  begin
    case (state)
      zero:
        out <= zero;
      one:
        out <= one;
    endcase
  end

endmodule
