module main;
  reg a, b, ci;
  wire sum, co;
  fulladder fadd(sum, co, a, b, ci);

  always@(a or b or ci)
  begin
    $display("time=%d: %b + %b = %b, carry_in = %b, carry_out = %b\n", $time, a, b, sum, ci, co);
  end

  initial
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
    a = 0; b = 0; ci = 0;
    #5
    a = 0; b = 1; ci = 0;
    #5
    a = 1; b = 0; ci = 0;
    #5
    a = 1; b = 1; ci = 0;
    #5
    a = 0; b = 0; ci = 1;
    #5
    a = 0; b = 1; ci = 1;
    #5
    a = 1; b = 0; ci = 1;
    #5
    a = 1; b = 1; ci = 1;
    #5
    $finish;
  end
endmodule
