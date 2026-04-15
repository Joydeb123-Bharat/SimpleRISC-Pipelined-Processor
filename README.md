# SimpleRISC: 32-bit Pipelined Processor & Web Assembler 🚀

![SimpleRISC Banner](https://img.shields.io/badge/Architecture-32--bit_RISC-blue)
![Pipeline](https://img.shields.io/badge/Pipeline-5_Stages-brightgreen)
![Hardware](https://img.shields.io/badge/Hardware-Verilog_HDL-orange)
![Software](https://img.shields.io/badge/Software-Python_|_Streamlit-red)

**Try the Live Web Assembler:** [SimpleRISC Web Compiler](https://simplerisc-pipelined-proceappr-mnivdiygjkgfdbkhwmboyf.streamlit.app/)

Welcome to the **SimpleRISC** project! This repository contains the complete RTL (Verilog) and software toolchain for a custom 32-bit, 5-stage pipelined RISC processor. Built from the ground up, this project features a hardware datapath optimized for speed and a "Smart Compiler" that handles pipeline hazards via software interlocking.

---

## 🏗️ Hardware Architecture

The processor implements a classic **5-Stage Pipeline**:
1. **IF (Instruction Fetch):** Fetches the 32-bit instruction from Instruction Memory (IMEM).
2. **OF (Operand Fetch / Decode):** Decodes the opcode, resolves branches (Early Branching), generates immediate values, and reads from the Register Bank.
3. **EX (Execute):** Performs arithmetic, logical, and shift operations using a custom ALU equipped with hardware multipliers and dividers.
4. **MA (Memory Access):** Reads from or writes to Data Memory (DMEM).
5. **RW (Register Writeback):** Writes ALU results, Memory Data, or Return Addresses (PC+4) back to the Register Bank.

### Key Architectural Features:
* **Harvard Architecture:** Separate 4KB Instruction Memory and 4KB Data Memory.
* **Internal Forwarding:** The Register Bank supports instantaneous write-around forwarding, allowing the OF stage to read a value in the exact same clock cycle it is being written by the RW stage.
* **Early Branch Resolution:** Branches are resolved in the OF stage using a dedicated hardware comparator, minimizing the branch penalty.

---

## 🧠 Instruction Set Architecture (ISA)

SimpleRISC uses a custom 32-bit instruction set. 

### Register File
The processor contains 16 general-purpose 32-bit registers.
* **`R0`**: Hardwired to `0`. Cannot be overwritten.
* **`R1` - `R14`**: General Purpose Registers.
* **`R15`**: Return Address Register (Implicitly used by `CALL` and `RET` instructions).

### Opcode Map (5-bit Opcodes)

| Opcode (Bin) | Mnemonic | Type | Description |
| :--- | :--- | :--- | :--- |
| `00000` | **ADD** | Math | Addition (`rd = rs1 + rs2`) |
| `00001` | **SUB** | Math | Subtraction (`rd = rs1 - rs2`) |
| `00010` | **MUL** | Math | Hardware Multiplication |
| `00011` | **DIV** | Math | Hardware Division (Quotient) |
| `00100` | **MOD** | Math | Hardware Division (Remainder) |
| `00101` | **CMP** | Logic | Compare (Sets internal Equal/Greater flags) |
| `00110` | **AND** | Logic | Bitwise AND |
| `00111` | **OR** | Logic | Bitwise OR |
| `01000` | **NOT** | Logic | Bitwise NOT |
| `01001` | **MOV** | Data | Move data/immediate into register |
| `01010` | **LSL** | Shift | Logical Shift Left |
| `01011` | **LSR** | Shift | Logical Shift Right |
| `01100` | **ASR** | Shift | Arithmetic Shift Right |
| `01101` | **NOP** | Control | No Operation |
| `01110` | **LD** | Mem | Load word from memory to register |
| `01111` | **ST** | Mem | Store word from register to memory |
| `10000` | **BEQ** | Branch | Branch to Label if Equal flag is set |
| `10001` | **BGT** | Branch | Branch to Label if Greater Than flag is set |
| `10010` | **B** | Branch | Unconditional Branch (Jump) |
| `10011` | **CALL** | Branch | Jump to subroutine, store PC+4 in `R15` |
| `10100` | **RET** | Branch | Return to address stored in `R15` |
| `10101` | **XOR** | Logic | Bitwise XOR |
| `10110` | **HLT** | Control | Halt Processor Execution |

---

## 🛡️ Hazard Mitigation (The "Smart Compiler")

To keep the hardware incredibly lightweight and fast, SimpleRISC offloads pipeline hazard mitigation to the software Assembler using **Software Interlocking**.

### 1. Data Hazards (Read-After-Write)
If an instruction attempts to read a register that was just modified by a previous instruction, it must wait for the data to reach the Writeback stage. 
* The custom Python Assembler tracks register usage in real-time.
* It automatically injects **1 or 2 NOPs** depending on the distance between the dependent instructions.
* *Note: Because of Hardware Internal Forwarding in the Register Bank, we only require a maximum of 2 NOPs instead of 3.*

### 2. Control Hazards (Branches)
Because branches are evaluated in the OF stage, the instruction immediately following a branch has already been fetched into the IF pipeline register before the processor knows it needs to jump.
* SimpleRISC implements **Software Branch Delay Slots**. 
* The Assembler automatically injects **2 NOPs** immediately following any `BEQ`, `BGT`, `B`, `CALL`, or `RET` instruction to protect the pipeline from executing ghost instructions.

---

## 📁 Repository Structure

* `/Hardware` - Contains all Verilog (`.v`) modules.
  * `SimpleRISC_Top.v` - The main motherboard wiring the pipeline.
  * `tb_SimpleRISC_Top.v` - The verification testbench.
  * *Submodules:* ALU, Control Unit, Register Bank, Memories, Pipeline Registers.
* `/Software` - Contains the Assembler toolchain.
  * `app.py` - The Streamlit Web GUI and Compiler backend.
  * `requirements.txt` - Deployment dependencies.

---

## ⚙️ How to Use

### 1. Generating Machine Code (Software)
You do not need to install anything to write code for SimpleRISC!
1. Visit the [Live Web Assembler](https://simplerisc-pipelined-proceappr-mnivdiygjkgfdbkhwmboyf.streamlit.app/).
2. Type your assembly code into the browser editor (or upload a `.txt` file).
3. Click **Compile & Assemble**. The UI will automatically resolve jump labels, inject NOPs for pipeline hazards, and generate the 32-bit machine hex.
4. Click **Download output.hex**.

### 2. Simulating the Processor (Hardware)
To run your machine code on the Verilog hardware:
1. Open Xilinx Vivado (or any Verilog simulator).
2. Add all `.v` files from the `/Hardware` folder as design sources.
3. Open `IMEM.v` and update the `$readmemb` path to point to your newly downloaded `output.hex` file.
4. Set `tb_SimpleRISC_Top.v` as the active simulation source.
5. Run **Behavioral Simulation**. The TCL console will output a final register dump to verify your program executed correctly!

---
*Architected and Developed by Joydeb Sarkar | IIT Patna*
