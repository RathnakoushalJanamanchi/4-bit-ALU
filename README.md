# 4-Bit ALU — Verilog Design & Verification

A 16-input, 16-operation Arithmetic Logic Unit (ALU) implemented in Verilog, with a randomised testbench, written and simulated on EDA Playground.

> **Note on naming:** Despite the project being called "4-bit ALU", the actual implementation uses **16-bit operands** (`A`, `B`) with a **4-bit opcode** — the "4-bit" refers to the opcode width that selects one of 16 operations.

---

## Overview

This project implements a combinational ALU that supports a full set of arithmetic and logic operations, selected by a 4-bit opcode. The design is purely combinational — there is no clock — and is gated by an active-high enable signal (`en`). The result is 32 bits wide to accommodate operations like multiplication that can exceed 16 bits.

Key concepts demonstrated:
- Multi-operation combinational ALU using a `case` statement in Verilog
- Enable-gated output logic
- Randomised stimulus testbench using `$random`
- VCD waveform generation for post-simulation analysis

---
---

## Design — `ALU` (`design.sv`)

### Module Interface

| Port     | Direction | Width   | Description                              |
|----------|-----------|---------|------------------------------------------|
| `A`      | input     | 16-bit  | First operand                            |
| `B`      | input     | 16-bit  | Second operand                           |
| `en`     | input     | 1-bit   | Active-high enable                       |
| `opcode` | input     | 4-bit   | Operation select (16 operations)         |
| `result` | output    | 32-bit  | Operation result (wide enough for MUL)   |

### Operation Table

| Opcode   | Operation | Expression      | Description         |
|----------|-----------|-----------------|---------------------|
| `4'b0000`| ADD       | `A + B`         | Addition            |
| `4'b0001`| SUB       | `A - B`         | Subtraction         |
| `4'b0010`| MUL       | `A * B`         | Multiplication      |
| `4'b0011`| DIV       | `A / B`         | Division            |
| `4'b0100`| INC       | `A + 1`         | Increment A         |
| `4'b0101`| DEC       | `A - 1`         | Decrement A         |
| `4'b0110`| NOT       | `~A`            | Bitwise NOT         |
| `4'b0111`| AND       | `A & B`         | Bitwise AND         |
| `4'b1000`| OR        | `A \| B`        | Bitwise OR          |
| `4'b1001`| XOR       | `A ^ B`         | Bitwise XOR         |
| `4'b1010`| NAND      | `~(A & B)`      | Bitwise NAND        |
| `4'b1011`| NOR       | `~(A \| B)`     | Bitwise NOR         |
| `4'b1100`| XNOR      | `~(A ^ B)`      | Bitwise XNOR        |
| `4'b1101`| RSHIFT    | `A >> 1`        | Logical right shift |
| `4'b1110`| LSHIFT    | `A << 1`        | Logical left shift  |
| `4'b1111`| DIV       | `A / B`         | Division (repeat)   |

> When `en = 0`, the `always` block is not entered and `result` retains its previous value (no explicit reset/default outside the `if`).

### Implementation Notes

- The design uses a single **combinational `always` block** (`always @(A or B or opcode or en)`) — no clock, no flip-flops.
- The `result` output is declared `reg` as required by Verilog for procedural assignment, but it behaves as combinational logic.
- The 32-bit output width correctly handles multiplication overflow — a 16×16 multiply can produce up to a 32-bit result.
- `opcode 4'b1111` duplicates the division operation of `4'b0011`.

---

## Testbench — `ALU_tb` (`testbench.sv`)

The testbench uses three concurrent `initial` blocks:

### 1. VCD Setup
```verilog
$dumpfile("dump.vcd");
$dumpvars(0, ALU_tb);
```
Captures all signals in the testbench and DUT for waveform analysis.

### 2. Stimulus Block
Runs 20 iterations, each applying random 16-bit operands and a random 4-bit opcode, with `en` held high throughout. A 5 ns delay follows each stimulus before printing results via `$display`.

```verilog
for (integer i = 0; i < 20; i = i + 1) begin
    A = $random();
    B = $random();
    en = 1;
    opcode = $random;
    #5;
    $display("A=%d, B=%d, en=%d, opcode=%b, result=%d", A, B, en, opcode, result);
end
```

### 3. Simulation End
Calls `$finish` at t=400 ns as a safety timeout.

### Sample Simulation Results (from VCD)

A selection of operations observed during simulation:

| Time (ns) | Opcode   | Operation | A (hex)  | B (hex)  | Result (hex)         |
|-----------|----------|-----------|----------|----------|----------------------|
| 5         | `1101`   | RSHIFT    | `5663`   | `7D0D`   | `00002B31`           |
| 10        | `0001`   | SUB       | `8265`   | `5212`   | `00003053`           |
| 25        | `1010`   | NAND      | `2486`   | `8345`   | `FFFFBB3B`           |
| 30        | `0010`   | MUL       | `F7E5`   | `7277`   | `6ED53573`           |
| 35        | `1110`   | LSHIFT    | `DB8F`   | `68F2`   | `0001B71E`           |
| 40        | `1100`   | XNOR      | `7BA8`   | `4EC5`   | `FFFFCBD2`           |
| 50        | `0000`   | ADD       | `6263`   | `871A`   | `0000E97D`           |
| 80        | `0010`   | MUL       | `0B4A`   | `4C3C`   | `0036D678`           |
| 90        | `1011`   | NOR       | `F378`   | `1289`   | `FFFF0C06`           |

The NAND, NOR, and XNOR results show the expected sign-extension into 32-bit, producing `FFFF...` prefixes for bitwise complement operations.

---

## Simulation on EDA Playground

This project was written and simulated on **[EDA Playground](https://www.edaplayground.com)**, a free browser-based HDL simulator.

### Steps to Reproduce

1. Go to [https://www.edaplayground.com](https://www.edaplayground.com) and log in (free account).
2. Select **Synopsys VCS** as the simulator.
3. Paste `design.sv` into the **Design** panel.
4. Paste `testbench.sv` into the **Testbench** panel.
5. Enable **"Open EPWave after run"** to view the waveform in the browser.
6. Click **Run**.

### Alternatively — Running Locally with VCS

```bash
bash run.sh
```

Compiles both files and runs the simulation, producing `dump.vcd`.

### Viewing the Waveform

```bash
# GTKWave (open-source)
gtkwave dump.vcd
```

Recommended signals to add: `en`, `opcode[3:0]`, `A[15:0]`, `B[15:0]`, `result[31:0]`.

---

## Design Notes & Limitations

- **No clock / purely combinational.** The ALU output updates immediately whenever any input changes — there is no registered pipeline stage.
- **Division by zero is unhandled.** If `B = 0` and a division opcode (`0011` or `1111`) is selected, Verilog simulation produces an `X` (unknown) result. A production design should include a guard.
- **Testbench does not self-check.** Results are displayed via `$display` but not automatically verified against expected values. Adding a golden reference model would catch any functional bugs.
- **`en = 0` behaviour.** When `en` is de-asserted, `result` is not driven inside the `always` block. This can cause `result` to latch its last value in simulation (not synthesisable as intended — a `default` or an `else` clause assigning `result = 0` would make the intent explicit).
- **Opcode `1111` duplicates `0011` (DIV).** This is likely an oversight, leaving one unused opcode slot.

---

## Possible Extensions

- Add a **carry/overflow flag** output for arithmetic operations.
- Add a **zero flag** (`result == 0`) and **sign flag** (`result[31]`).
- Add **division-by-zero detection** and a dedicated error/exception output.
- Make the testbench **self-checking** by computing expected results in parallel and comparing with `$error`.
- Parameterise the operand width (currently hardcoded to 16 bits) to make the ALU reusable at different data widths.
- Add a **registered (clocked) output stage** for pipelined use.
