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
   reg [1:0] 	 dma_state;
   reg [15:0] 	 dma_src;
   reg [15:0] 	 dma_dst;
   reg [15:0] 	 dma_counter;
   reg [31:0] 	 dma_reg;

   integer 	 verilog_trace_fp, rc;
   
	wire [15:0] pc_next = pc + 1;
	wire dma_read_flag = dma_state == `DMA_STATE_READ
						 && (ctl_state == `CTL_STATE_DEC0
						 || (ctl_state == `CTL_STATE_DEC1 && opcode != `LD)
						 || (ctl_state == `CTL_STATE_EXEC0 && opcode != `LD && opcode != `ST));
	wire dma_write_flag = dma_state == `DMA_STATE_WRITE
						  && (ctl_state == `CTL_STATE_DEC0
						  || ctl_state == `CTL_STATE_DEC1
						  || (ctl_state == `CTL_STATE_EXEC0 && opcode != `LD)
						  || (ctl_state == `CTL_STATE_EXEC1 && opcode != `LD && opcode != `ST));
   
   initial
     begin
	verilog_trace_fp = $fopen("verilog_trace.txt", "w");
     end

	
	assign sram_DI = dma_write_flag ? dma_reg : alu0;
	assign sram_ADDR = dma_read_flag ?
					   dma_src :
					   dma_write_flag ?
					   dma_dst :
					   ctl_state == `CTL_STATE_FETCH0 ?
					   pc :
					   alu1;
	assign sram_EN = 1;
	assign sram_WE = dma_write_flag || (ctl_state == `CTL_STATE_EXEC1 && opcode == `ST) ? 1 : 0;

   
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
			dma_state <= 0;
			dma_src <= 0;
			dma_dst <= 0;
			dma_counter <= 0;
			dma_reg <= 0;
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
			$fdisplay(verilog_trace_fp, "ctl_state %08x", ctl_state);
			$fdisplay(verilog_trace_fp, "dma_state %08x", dma_state);
			$fdisplay(verilog_trace_fp, "dma_src %08x", dma_src);
			$fdisplay(verilog_trace_fp, "dma_dst %08x", dma_dst);
			$fdisplay(verilog_trace_fp, "dma_counter %08x", dma_counter);
			$fdisplay(verilog_trace_fp, "dma_reg %08x\n", dma_reg);

			cycle_counter <= cycle_counter + 1;
			
			case (ctl_state)
				`CTL_STATE_IDLE: begin
					pc <= 0;
					if (start)
						ctl_state <= `CTL_STATE_FETCH0;
				end
				`CTL_STATE_FETCH0: begin
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
					if (opcode == `LHI) begin
						alu0 <= readReg (dst);
						alu1 <= immediate;
					end else if (opcode == `DMA) begin
						dma_counter <= readReg (src0);
						dma_src <= readReg (src1);
						dma_dst <= readReg (dst);
					end else if (opcode == `POL) begin
						alu0 <= dma_counter;
						alu1 <= 0;
					end else begin
						alu0 <= readReg (src0);
						alu1 <= readReg (src1);
					end
					ctl_state <= `CTL_STATE_EXEC0;
				end
				`CTL_STATE_EXEC0: begin
					aluout <= aluout_wire;
					ctl_state <= `CTL_STATE_EXEC1;
				end
				`CTL_STATE_EXEC1: begin
					case (opcode)
						`ADD, `SUB, `LSF, `RSF, `AND, `OR, `XOR, `LHI, `POL: begin
							writeReg (dst, aluout);
							pc <= pc_next;
						end
						`LD: begin
							writeReg (dst, sram_DO);
							pc <= pc_next;
						end
						`JLT, `JLE, `JEQ, `JNE, `JNE: begin
							if (aluout) begin
								writeReg (7, pc);
								pc <= immediate;
							end else begin
								pc <= pc_next;
							end
						end
						`JIN: begin
							writeReg (7, pc);
							pc <= alu0;
						end
						`HLT: begin
							$fclose(verilog_trace_fp);
							$writememh("verilog_sram_out.txt", top.SP.SRAM.mem);
							$finish;
						end
						default: begin
							pc <= pc_next;
						end
					endcase
					ctl_state <= `CTL_STATE_FETCH0;
				end
			endcase
			
			case (dma_state)
				`DMA_STATE_IDLE: begin
					if (dma_counter) begin
						dma_state <= `DMA_STATE_READ;
					end
				end
				`DMA_STATE_READ: begin
					if (dma_read_flag) begin
						dma_state <= `DMA_STATE_EXTRACT;
					end
				end
				`DMA_STATE_EXTRACT: begin
					dma_reg <= sram_DO;
					dma_state <= `DMA_STATE_WRITE;
				end
				`DMA_STATE_WRITE: begin
					if (dma_write_flag) begin
						dma_src <= dma_src + 1;
						dma_dst <= dma_dst + 1;
						dma_counter <= dma_counter - 1;
						if (dma_counter == 1) begin
							dma_state <= `DMA_STATE_IDLE;
						end else begin
							dma_state <= `DMA_STATE_READ;
						end
					end
				end
			endcase
		end // !reset
	end // @posedge(clk)

	function [31:0] readReg;
		input [2:0] d;
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
		input [2:0] d;
		input [31:0] v;
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


