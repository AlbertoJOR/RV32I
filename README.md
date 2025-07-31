# RV32I: 32-bit RISC-V Processor in VHDL

This project implements a **32-bit RV32I RISC-V processor** written in **VHDL**, designed with a classic 5-stage pipeline and essential features such as **hazard detection**, **branch prediction**, and **register forwarding**.

It is intended for educational purposes and experimentation with open instruction set architectures and digital design principles. The processor can be simulated with **GHDL** and visualized using **GTKWave**.

---

## Features

- ISA: RV32I (base integer instruction set)
- 5-stage pipeline: IF, ID, EX, MEM, WB
- Hazard detection unit (data & control hazards)
- Basic static branch prediction
- Forwarding logic
- Ready for integration with instruction and data memory modules
- Open-source and modular design

---

## Requirements

- **GHDL** (for VHDL simulation)  
  [Install GHDL](https://ghdl.github.io/ghdl/#install)

- **GTKWave** (for waveform viewing)
  ```bash
  sudo apt install gtkwave
  ```

- **Make** (optional, for running predefined flows)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/AlbertoJOR/RV32I.git
cd RV32I
```

### 2. Run Simulation

You can run a simulation using GHDL (example with a testbench):

```bash
ghdl -a src/*.vhdl
ghdl -a tb/tb_top.vhdl
ghdl -e tb_top
ghdl -r tb_top --vcd=wave.vcd
gtkwave wave.vcd
```

> Modify `tb/tb_top.vhdl` or add your own memory contents to simulate a specific RISC-V program.
