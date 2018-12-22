`include "defines.vh"

/***********************************
 * CTL module
 **********************************/
module CTL(
	   clk,
	   reset,
	   start,
	   sram_ADDR,
	   sram_DI,
	   sram_EN,
	   sram_WE,
	   sram_DO,
	   opcode,
	   alu0,
	   alu1,
	   aluout_wire
	   );

   // inputs
   input clk;
   input reset;
   input start;
   input [31:0] sram_DO;
   input signed [31:0] aluout_wire;

   // outputs
   output [15:0] sram_ADDR;
   output [31:0] sram_DI;
   output 	 sram_EN;
   output 	 sram_WE;
   output signed [31:0] alu0;
   output signed [31:0] alu1;
   output [4:0]  opcode;

   // registers
   reg [31:0] 	 r2;
   reg [31:0] 	 r3;
   reg [31:0] 	 r4;
   reg [31:0] 	 r5;
   reg [31:0] 	 r6;
   reg [31:0] 	 r7;
   reg [15:0] 	 pc;
   reg [31:0] 	 inst;
   reg [4:0] 	 opcode;
   reg [2:0] 	 dst;
   reg [2:0] 	 src0;
   reg [2:0] 	 src1;
   reg [31:0] 	 alu0;
   reg [31:0] 	 alu1;
   reg [31:0] 	 aluout;
   reg [31:0] 	 immediate;
   reg [31:0] 	 cycle_counter;
   reg [2:0] 	 ctl_state;

   integer 	 verilog_trace_fp, rc;
   
   initial
     begin
	verilog_trace_fp = $fopen("verilog_trace.txt", "w");
     end

	 
	assign sram_DI = alu0;
	assign sram_ADDR = (ctl_state == `CTL_STATE_FETCH0) ? pc : alu1;
	assign sram_EN = 1;
	assign sram_WE = (ctl_state == `CTL_STATE_EXEC1 && opcode == `ST) ? 1 : 0;

   
   // synchronous instructions
   always@(posedge clk)
     begin
	if (reset) begin
	   // registers reset
	   r2 <= 0;
	   r3 <= 0;
	   r4 <= 0;
	   r5 <= 0;
	   r6 <= 0;
	   r7 <= 0;
	   pc <= 0;
	   inst <= 0;
	   opcode <= 0;
	   dst <= 0;
	   src0 <= 0;
	   src1 <= 0;
	   alu0 <= 0;
	   alu1 <= 0;
	   aluout <= 0;
	   immediate <= 0;
	   cycle_counter <= 0;
	   ctl_state <= 0;
	   
	end else begin
	   // generate cycle trace
	   $fdisplay(verilog_trace_fp, "cycle %0d", cycle_counter);
	   $fdisplay(verilog_trace_fp, "r2 %08x", r2);
	   $fdisplay(verilog_trace_fp, "r3 %08x", r3);
	   $fdisplay(verilog_trace_fp, "r4 %08x", r4);
	   $fdisplay(verilog_trace_fp, "r5 %08x", r5);
	   $fdisplay(verilog_trace_fp, "r6 %08x", r6);
	   $fdisplay(verilog_trace_fp, "r7 %08x", r7);
	   $fdisplay(verilog_trace_fp, "pc %08x", pc);
	   $fdisplay(verilog_trace_fp, "inst %08x", inst);
	   $fdisplay(verilog_trace_fp, "opcode %08x", opcode);
	   $fdisplay(verilog_trace_fp, "dst %08x", dst);
	   $fdisplay(verilog_trace_fp, "src0 %08x", src0);
	   $fdisplay(verilog_trace_fp, "src1 %08x", src1);
	   $fdisplay(verilog_trace_fp, "immediate %08x", immediate);
	   $fdisplay(verilog_trace_fp, "alu0 %08x", alu0);
	   $fdisplay(verilog_trace_fp, "alu1 %08x", alu1);
	   $fdisplay(verilog_trace_fp, "aluout %08x", aluout);
	   $fdisplay(verilog_trace_fp, "cycle_counter %08x", cycle_counter);
	   $fdisplay(verilog_trace_fp, "ctl_state %08x\n", ctl_state);

	   cycle_counter <= cycle_counter + 1;
	   case (ctl_state)
	      `CTL_STATE_IDLE: begin
                pc <= 0;
                if (start)
                  ctl_state <= `CTL_STATE_FETCH0;
          end
		  `CTL_STATE_FETCH0: begin
			//sp_trace_exec(spro);
			ctl_state <= `CTL_STATE_FETCH1;
		  end
		  `CTL_STATE_FETCH1: begin
			inst <= sram_DO;
			ctl_state <= `CTL_STATE_DEC0;
		  end
		  `CTL_STATE_DEC0: begin
			opcode <= inst[29:25];
			dst <= inst[24:22];
			src0 <= inst[21:19];
			src1 <= inst[18:16];
			immediate <= {inst[15:0], 16'b0} >>> 16;
			ctl_state <= `CTL_STATE_DEC1;
		  end
		  `CTL_STATE_DEC1: begin
			//sp_trace_inst(spro);
			if (opcode == `LHI) begin
			  alu0 <= readReg (dst);
			  alu1 <= immediate;
			end else begin
			  alu0 <= readReg (src0);
			  alu1 <= readReg (src1);
			end
			ctl_state <= `CTL_STATE_EXEC0;
		  end
		  `CTL_STATE_EXEC0: begin
			ctl_state <= `CTL_STATE_EXEC1;
		  end
		  `CTL_STATE_EXEC1: begin
		    if (opcode >= `AND && opcode <= `LHI) begin
			  writeReg (dst, aluout);
			end else if (opcode == `LD) begin
			  writeReg (dst, sram_DO);
			end else if (opcode >= `JLT && opcode <= `JNE) begin
			  if (aluout) begin
			    pc <= immediate;
				writeReg (7, pc);
			  end
			end else if (opcode == `JIN) begin
			  pc <= alu0;
			  writeReg (7, pc);
			end
			ctl_state <= `CTL_STATE_FETCH0;
		  end

	   endcase
	   
	   if (opcode == `HLT) begin
	      $fclose(verilog_trace_fp);
	      $writememh("verilog_sram_out.txt", top.SP.SRAM.mem);
	      $finish;
	   end
	end // !reset
     end // @posedge(clk)
	
	function readReg;
	    input d;
		begin
			case (d)
				0: readReg = 0;
				1: readReg = immediate;
				2: readReg = r2;
				3: readReg = r3;
				4: readReg = r4;
				5: readReg = r5;
				6: readReg = r6;
				7: readReg = r7;
			endcase
		end
	endfunction
	
	task writeReg;
		input d, v;
		begin
			case (d)
				2: r2 <= v;
				3: r3 <= v;
				4: r4 <= v;
				5: r5 <= v;
				6: r6 <= v;
				7: r7 <= v;
			endcase
		end
	endtask
	
endmodule // CTL


