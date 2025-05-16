# RISC-V Processor Design 🚀

## Overview 🌟
This repository contains the implementation of **RISC-V Processor** ,  course project for **EE705 : VLSI Design Lab (Spring 2025, IIT Bombay)** . This project demonstrates a **System-on-Chip (SoC)** built around a RISC-V processor, implemented in Verilog and validated using Xilinx Vivado. The design integrates a RISC-V core, AXI4-Lite to AXI4 converter, interrupt controller, and peripherals such as UART, SPI, and GPIO. 


## Key Features ✨
- **RISC-V Core**: Supports instruction fetch, decode, execution, load-store, and CSR operations. 
- **Instruction Cache**: Connects to AXI BRAM Controller for efficient instruction fetching. 
- **Data Port Bridge**: Manages AXI4 transactions for data memory access. 
- **SoC Peripherals**: Includes UART, Timer, SPI, GPIO, and an Interrupt Controller. 
- **AXI4-Lite to AXI4 Converter**: Ensures protocol compatibility. 
- **FPGA Implementation**: Verified on the PYNQ-Z2 board with GPIO-mapped LEDs. 
- **Simulation**: Behavioral, post-synthesis, and post-implementation timing results. 

