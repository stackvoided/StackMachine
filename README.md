# StackMachine

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lua](https://img.shields.io/badge/Lua-5.1%20%7C%205.2%20%7C%205.3%20%7C%205.4%20%7C%20LuaJIT-blue.svg)](https://www.lua.org)
[![Architecture](https://img.shields.io/badge/Architecture-16--bit%20Stack--based-red.svg)](#architecture-overview)

**StackMachine** is a clean, modular 16-bit virtual machine, custom assembly toolchain, and CPU emulator written entirely in Lua.

The project provides a complete execution pipeline, from assembly source code through lexical analysis, parsing, symbol resolution, and bytecode generation to runtime execution, profiling, and interactive debugging.

It is designed with **zero external dependencies** and supports Lua 5.1+, LuaJIT, and standard embedded Lua environments.

## 📑 Table of Contents

- [Key Features](#-key-features)
- [Architecture Overview](#-architecture-overview)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Assembly Specification](#-assembly-specification)
- [Developer Toolchain](#-developer-toolchain)
- [License](#-license)

## ✨ Key Features

- **Pure Lua implementation** — compatible with Lua 5.1+, LuaJIT, and standard embedded environments.
- **Zero external dependencies** — the core system is implemented entirely in Lua.
- **Complete assembler pipeline** — includes a lexer, symbol table resolver, AST parser, and bytecode generator.
- **16-bit CPU architecture** — provides a 16-bit address space and register set.
- **Stack-based execution** — includes bounded stack depth checking and frame pointer (`FP`) support.
- **CPU flags** — `ZERO` and `NEGATIVE` flags provide hardware-level condition tracking.
- **Programmable I/O** — port-mapped I/O through a customizable device interface and bus.
- **Software interrupts** — `INT` instructions with vector-table offset support.
- **Built-in profiler** — tracks opcode execution frequency and runtime statistics.
- **Interactive debugger** — supports step-by-step execution, stack inspection, and breakpoints.

## 🏗 Architecture Overview

StackMachine follows a classic **Von Neumann architecture** adapted for stack-based execution.

```text
+-------------------------------------------------------+
|                  StackMachine System                  |
+-------------------------------------------------------+

+------------------------------+-------------------------+
|                              |                         |
v                              v                         |
+-------------------------------+ +---------------------+
|       Assembler Pipeline      | |    Runtime Engine    |
|                               | |                     |
| Source Code                   | | +-----------------+ |
|      |                        | | |    CPU Core     | |
|      v                        | | | [IP] [FP]       | |
| [Lexer] -> Tokens             | | | [Registers]     | |
|      |                        | | +-----------------+ |
|      v                        | |          ^          |
| [Parser] + [SymbolTable]      | |          |          |
|      |                        | | +--------v--------+ |
|      v                        | | |  Bus / Memory   | |
| [CodeGen] -> Bytecode         | | | [RAM] [I/O]     | |
|                               | | +-----------------+ |
+-------------------------------+ +---------------------+
               |                           ^
               +-------- Bytecode ---------+
```

### Execution Pipeline

```text
Assembly Source
      |
      v
    Lexer
      |
      v
   Parser + Symbol Table
      |
      v
   AST / Semantic Checks
      |
      v
   Code Generator
      |
      v
   Bytecode
      |
      v
 CPU / Memory / I/O
      |
      v
   Execution
```

## 📁 Project Structure

```text
StackMachine/
├── bin/
│   └── main.lua                 # CLI entry point runner script
├── examples/
│   ├── math_demo.asm            # Mathematical operations example
│   └── memory_copy.asm          # Memory buffer manipulation example
├── src/
│   ├── asm/
│   │   ├── codegen.lua          # Bytecode generation from AST
│   │   ├── lexer.lua            # Tokenizer for assembly source
│   │   ├── parser.lua           # AST builder and semantic checks
│   │   └── symbol_table.lua     # Label and symbol resolution
│   ├── core/
│   │   ├── constants.lua        # Opcodes, flags, and system constants
│   │   ├── cpu.lua              # Fetch-decode-execute CPU loop
│   │   ├── memory.lua            # Byte/word RAM abstraction
│   │   ├── registers.lua        # Register and flag management
│   │   └── stack.lua            # Bounded execution stack
│   ├── io/
│   │   ├── bus.lua              # Port-mapped I/O bus
│   │   └── device.lua           # Peripheral device interface
│   ├── toolchain/
│   │   ├── debugger.lua         # Stepper and inspection engine
│   │   └── profiler.lua         # Opcode execution metrics
│   ├── utils/
│   │   ├── bit_ops.lua          # Bitwise operation utilities
│   │   └── string_buffer.lua    # High-performance string builder
│   ├── config.lua               # System memory and stack constraints
│   └── init.lua                 # High-level entry point API
└── README.md
```

## 🚀 Getting Started

### Prerequisites

All you need is a working Lua environment:

- Lua 5.1+
- or LuaJIT

No additional dependencies are required.

### Running an Example

Execute an assembly program through the CLI entry point:

```bash
lua bin/main.lua examples/math_demo.asm
```

### Using StackMachine as a Module

```lua
local System = require("src.init")

local vm = System.new()

local source = [[
PUSH 10
PUSH 20
ADD
HALT
]]

-- Compiles, loads into memory, executes,
-- and dumps profiling data.
vm:load_and_run(source)
```

## 📜 Assembly Specification

### Supported Instruction Set

| Category | Opcodes | Description |
|---|---|---|
| **Stack** | `PUSH`, `POP`, `DUP`, `SWAP`, `OVER` | Basic stack manipulation primitives |
| **Arithmetic** | `ADD`, `SUB`, `MUL`, `DIV`, `MOD` | 16-bit integer arithmetic |
| **Bitwise** | `AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR` | Bitwise logical operations and shifts |
| **Comparison** | `EQ`, `LT`, `GT` | Evaluates a condition and pushes `1` or `0` |
| **Control Flow** | `JMP`, `JZ`, `JNZ`, `CALL`, `RET` | Branching, conditional jumps, and subroutines |
| **Memory** | `LOAD`, `STORE`, `LOADB`, `STOREB` | Word (16-bit) and byte (8-bit) RAM access |
| **I/O & Control** | `IN`, `OUT`, `MOV`, `INT`, `HALT` | Hardware bus communication and CPU control |

## 🛠 Developer Toolchain

### Profiler

The built-in profiler records instruction frequencies and execution statistics during runtime.

```lua
vm.profiler:start()

-- ... VM execution ...

vm.profiler:generate_report()
```

### Interactive Debugger

The debugger can be used to trace execution step by step, inspect the VM state, and manage breakpoints.

```lua
local debugger = vm.debugger

debugger:set_breakpoint(0x0004)
debugger:step()

print("Current IP:", vm.cpu.ip)
print("Top Stack Value:", vm.cpu.stack:peek())
```

## 📄 License

This project is open-source and available under the **MIT License**.
