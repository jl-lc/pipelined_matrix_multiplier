# pipelined_matrix_multiplier
Pipelined 4x4 signed 16-bit matrix multiplication core in VHDL

---
## Algorithm
Strassen’s algorithm, Winograd variation
7 multiplications & 15 additions, 3 less additions than the standard Strassen’s algorithm

---
## Design
Pipelined, designed for high throughput
Utilized Xilinx DSP multiplier IP cores for performance
Takes 2 256-bit std_logic_vectors inputs (DATA_WIDTH = 16:  [A B C D] => std_logic_vector AAAAAAAAAAAAAAAAB...B......O...OPPPPPPPPPPPPPPPP 
                                                            [E F G H]                     |------16------|
                                                            [I J K L]                    255                   downto                    0
                                                            [M N O P]
Output 1 512-bit std_logic_vector answer
AXI protocol READY and VALID signals

---
## Specifications
Implementation maximum 416.667 MHz clock speed; 50ns latency.
Implementation utilization: 3889 LUTs, 15348 FFs, 49 DSPs.

---
## Citation
Citation:        S. Winograd. On Multiplication of 2 × 2 Matrices. Linear Algebra and Application, 4: 381-388, 1971
