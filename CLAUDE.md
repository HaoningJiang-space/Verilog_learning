# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Verilog learning repository focused on CPU design projects for SME309. The codebase contains template Verilog modules for an FPGA-based processor implementation targeting Xilinx boards.

## Project Structure

The main project is located in `SME309_CPU_design/Lab1/Vivado_Template/` and contains:

- **top.v**: Top-level module connecting control unit, memory, and seven-segment display
- **control.v**: Control unit module for address generation with pause/speed controls
- **mem.v**: Memory module template for instruction/data storage
- **Seven_Seg.v**: Seven-segment display driver for debugging output
- **control_tb.v**: Testbench for the control module
- **top.xdc**: Xilinx constraint file mapping signals to FPGA pins

## Architecture

The design follows a modular CPU architecture:
- **Control Unit** (`control.v`): Manages program counter/address generation with user input controls (pause, speedup, speeddown)
- **Memory Unit** (`mem.v`): Stores program instructions/data accessed by 8-bit addresses
- **Display Unit** (`Seven_Seg.v`): Converts 32-bit memory data to seven-segment display output
- **Top Module** (`top.v`): Integrates all components and handles I/O connections

The system is designed for 100MHz operation on Xilinx boards (50MHz on Pango boards).

## Common Development Tasks

### Simulation
```bash
# Using Icarus Verilog (if available)
iverilog -o control_test control_tb.v control.v
vvp control_test
gtkwave testbench.wave

# The testbench generates waveforms in testbench.wave format
```

### FPGA Implementation
This project targets Xilinx FPGAs and uses Vivado for synthesis and implementation. The constraint file (`top.xdc`) maps:
- Clock input to pin E3 (100MHz)
- Button controls to pins N17, M18, P18
- LEDs to pins H17, K15, J13, N14, R18, V17, U16, U17
- Seven-segment display to various pins with LVCMOS18 standard

### Module Completion
Many modules contain TODO comments indicating incomplete implementations. When working on these:
1. Implement missing logic in control.v for address generation and timing control
2. Complete memory initialization and read logic in mem.v
3. Implement seven-segment encoding and multiplexing in Seven_Seg.v
4. Connect missing signals in top.v (note the TODO comment)

## Testing
The project includes a testbench (`control_tb.v`) that:
- Tests control module with various button press sequences
- Generates clock and stimulus signals
- Outputs waveform data for analysis
- Uses 100ns clock period (10MHz test frequency)