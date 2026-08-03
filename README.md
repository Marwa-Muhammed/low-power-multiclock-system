# Low-Power Multi-Clock Digital Communication System

RTL-to-GDS ASIC design flow for a low-power, multi-clock digital communication system —
covering RTL design, verification, logic synthesis, DFT, formal verification, and physical
implementation (Place & Route to GDS).

Developed as the final project for the **Full Digital IC Design Diploma**
(under the supervision of Eng. Ali El-Temsah).

---

## Project Description

The system receives commands through a UART receiver to perform various functions such as
register file read/write or ALU-based processing, then transmits results back out through
a UART transmitter. Data passes through an asynchronous FIFO to safely handle multiple
clock domains and avoid data loss between the system's clock domains.

**Key system blocks:**
- ALU
- Register File
- Asynchronous FIFO
- Integer Clock Divider
- Clock Gating Unit
- Reset/Data Synchronizers
- System Controller
- UART Transmitter (TX)
- UART Receiver (RX)

---

## Project Phases

1. RTL design from scratch for all system blocks
2. Integration and functional verification through self-checking testbenches
3. Constraining the system via synthesis TCL scripts
4. Synthesis and optimization using Design Compiler
5. Lint / CDC / RDC analysis and fixes using SpyGlass
6. Static timing analysis — setup and hold violation fixes
7. Functional equivalence verification using Formality (formal verification)
8. Physical implementation through the full ASIC flow, generating the final GDS
9. Post-layout verification via gate-level simulation (GLS), accounting for real delays

---

## Status by Block

| Block | RTL | Verification | Lint/CDC | Synthesis | DFT | PnR | GLS |
|---|---|---|---|---|---|---|---|
| UART TX | ✅ | ✅ | 🔄 | 🔄 | ⬜ | ⬜ | ⬜ |
| UART RX | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| ALU | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Register File | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Async FIFO | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Clock Divider | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Clock Gating | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Synchronizers | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| System Controller | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| **System Top (integration)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

**Legend:** ✅ Done  🔄 In progress  ⬜ Not started

---

## Repository Structure

Each block follows the same standard layout:

```
<block_name>/
├── rtl/                RTL source files (Verilog/SystemVerilog)
├── tb/                 Self-checking testbench + simulation scripts (.do files)
├── lint/               SpyGlass project file + lint/CDC reports
│   └── reports/
├── synthesis/          Design Compiler scripts, netlists, and reports
│   ├── scripts/        syn_script.tcl, cons.tcl
│   ├── logs/           syn.log
│   ├── netlist/        Gate-level netlist (.v, .ddc), SDC, SDF
│   └── reports/        Area, power, timing, clocks, constraints reports
└── docs/               Design & verification report (PDF)
```

System-level stages, applied to the fully integrated `sys_top` design, live at the
repository root:

```
dft/         Scan insertion scripts, DFT-inserted netlist, coverage reports
formal/      Formal verification: RTL-vs-netlist, netlist-vs-DFT, DFT-vs-PnR
pnr/         Place & Route: floorplanning, timing closure, final GDS
gls/         Post-layout gate-level simulation (with SDF back-annotation)
```

Shared standard-cell libraries (TSMC 0.13µm) live in `std_cells/`. These are **excluded
from version control** due to foundry licensing — see `std_cells/README.md` for details.

---

## Tools Used

| Purpose | Tool |
|---|---|
| Simulation | ModelSim / QuestaSim |
| Lint / CDC / RDC | Synopsys SpyGlass |
| Logic Synthesis | Synopsys Design Compiler |
| Formal Verification | Synopsys Formality |
| Place & Route | *(TBD)* |
| Scripting | TCL |

---

## Notes

- All RTL is written to be synthesizable and lint-clean before moving to the next flow stage.
- Each block is verified individually before integration into `sys_top`.
- Synthesis constraints, reports, and netlists per block are kept under that block's own
  `synthesis/` folder until final system-level synthesis is performed on the integrated design.

---

## Author

**Marwa Muhammed**
Full Digital IC Design Diploma — Digital IC Design Track
