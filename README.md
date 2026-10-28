# ECE520_Lab3_BRAM_FIFO

# Overview
In this lab, students must implement a parameterized, single-clock FIFO that uses Block RAM (BRAM) for its internal memory in Verilog. The BRAM can be inferred or instantiated, and students are allowed to use the Block Memory Generator IP. Students must write a self-checking testbench to verify the functionality of the FIFO design and generate a text file containing input data for the FIFO to use in simulation using Python. A Tcl script must also be written to automate the creation of the Vivado project. 

# Design Summary
  I implemented the parameterizable single-clock FIFO that uses Black RAM inference for its internal memory. I inferred the BRAM into my FIFO design by following the RAM_STYLE Verilog example provided by Vivado. The example is as follows: 
  (* ram_style = "ultra" *) reg [data_size-1:0] myram [2**addr_size-1:0]; 
A counter was created to keep track of the current number of values stored in the FIFO and to generate the FIFO status signals such as EMPTY, FULL, and ALMOST_FULL. 

# Verification and Results
I verified my design by testing the following cases in my testbench:
- Output returns to 0 after reset is asserted
- Write all 1s and reading out all 1s, then writing all 0s and reading out all 0s
- Alternating bit patterns
- Writing to every memory location and reading every memory location back
- Status flags: EMPTY, FULL, ALMOST_EMPTY, and ALMOST_FULL
- Read_Enable and Write_Enable signals

<img width="698" height="90" alt="image" src="https://github.com/user-attachments/assets/21a26187-ade7-4655-af6f-d566a6007c76" />
<img width="825" height="218" alt="image" src="https://github.com/user-attachments/assets/b0adbdd2-96c3-48f2-bbc3-e67b720a063c" />



# Known Issues or Limitations
I was able to generate the Vivado file using a Tcl script, but when I went back to generate the file again, it was not able to regenerate. 

# Refernces

https://docs.amd.com/r/en-US/ug901-vivado-synthesis/Attributes-for-Controlling-UltraRAM
