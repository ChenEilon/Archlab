module main;
  reg clk, reset, push, pop;
  reg [1:0] in;
  wire [1:0] out;
  wire full;
  
  reg ok;

  // Correct the parameter assignment
  fifo #(4, 2) uut(clk, reset, in, push, pop, out, full);

  always #5 clk = ~clk;
  
  always @(negedge clk) begin
    $display("time %d: reset %b, push %b, pop %b, in %b, out %b, full %b", $time, reset, push, pop, in, out, full);
  end

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
    clk = 0;
    reset = 1;
    push = 0;
    pop = 0;
    in = 0;
    ok = 1;
    
    #10; // W = <>
    ok = ok && out == 2'b00 && full == 0;
    reset = 0;
    push = 0;
    pop = 0;
    in = 2'b01;
    
    #10; // W = <>
    ok = ok && out == 2'b00 && full == 0;
    push = 0;
    pop = 1;
    in = 2'b01;
    
    #10; // W = <>
    ok = ok && out == 2'b00 && full == 0;
    push = 1;
    pop = 1;
    in = 2'b11;
    
    #10; // W = <11>
    ok = ok && out == 2'b11 && full == 0;
    push = 0;
    pop = 0;
    in = 2'b01;
    
    #10; // W = <11>
    ok = ok && out == 2'b11 && full == 0;
    push = 0;
    pop = 1;
    in = 2'b01;
    
    #10; // W = <>
    ok = ok && out == 2'b00 && full == 0;
    push = 1;
    pop = 0;
    in = 2'b11;
    
    #10; // W = <11>
    ok = ok && out == 2'b11 && full == 0;
    push = 1;
    pop = 1;
    in = 2'b01;
    
    #10; // W = <01>
    ok = ok && out == 2'b01 && full == 0;
    push = 1;
    pop = 0;
    in = 2'b10;
    
    #10; // W = <10, 01>
    ok = ok && out == 2'b01 && full == 0;
    push = 1;
    pop = 0;
    in = 2'b00;
    
    #10; // W = <00, 10, 01>
    ok = ok && out == 2'b01 && full == 0;
    push = 1;
    pop = 0;
    in = 2'b11;
    
    #10; // W = <11, 00, 10, 01>
    ok = ok && out == 2'b01 && full == 1;
    push = 0;
    pop = 0;
    in = 2'b10;
    
    #10; // W = <11, 00, 10, 01>
    ok = ok && out == 2'b01 && full == 1;
    push = 1;
    pop = 0;
    in = 2'b10;
    
    #10; // W = <11, 00, 10, 01>
    ok = ok && out == 2'b01 && full == 1;
    push = 1;
    pop = 1;
    in = 2'b01;
    
    #10; // W = <01, 11, 00, 10>
    ok = ok && out == 2'b10 && full == 1;
    push = 0;
    pop = 1;
    in = 2'b10;
    
    #10; // W = <01, 11, 00>
    ok = ok && out == 2'b00 && full == 0;
    push = 0;
    pop = 1;
    in = 2'b10;
    
    #10; // W = <01, 11>
    ok = ok && out == 2'b11 && full == 0;
    reset = 1;
    push = 0;
    pop = 0;
    in = 2'b10;
    
    #10; // W = <>
    ok = ok && out == 2'b11 && full == 0;
    
    if (ok)
      $display("PASSED ALL TESTS");
    
    $finish;
  end
endmodule
