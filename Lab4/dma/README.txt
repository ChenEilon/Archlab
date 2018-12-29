We found a mistake in the logic of the DMA state machine in the simulator in lab 2.
The mistake allowed the DMA state machine to initiate a read/write transaction during control state FETCH1.
We corrected the mistake in our verilog implementation, but got a different cycle trace logs (sram_out was identical).

To prove the correctness of our implementation, we corrected the mistake in the simulator.
All the simulator related files are in the lab2_sim directory:
sp.c - A corrected simulator.
dma.bin - The original test program (no changes).
dma_cycle_trace.txt, dma_inst_trace.txt, dma_sram_out.txt - The simulator's logs from the test program.
