# Linux Engineering & Declarative Architecture: Ground-Up Learning Plan

This document serves as our shared master roadmap for tracing computer systems from physical silicon up to purely functional, declarative operating systems. It structures our learning into clear, sequential milestones to maintain absolute continuity across our sessions.

> **Dedicated Engineering Lab Module:** [`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix) provisions the complete compiler, debugger, emulator, input-event tracer (`evtest`), kernel build (`make menuconfig`), and Nix store inspection (`nix-tree`, `nix-diff`, `nom`) toolchain for all three phases below.

---

## Roadmap Overview

```
 [ Phase 1: Silicon & Bare Metal ] ──> [ Phase 2: Linux From Scratch ] ──> [ Phase 3: Declarative NixOS ]
   - Architecture & Registers            - Toolchains & Compilation            - Functional Architecture
   - Interrupts & Real-Mode              - Kernel Configuration                - The Nix Store & Isolation
   - UEFI & Kernel Handoff               - Init & Userspace Layout             - Flakes & Multi-Node Design
```

---

## Phase 1: The Silicon & Bare Metal (The Hardware-OS Interface)
**Objective:** Comprehend the exact mechanical transitions that occur between completing an electrical circuit and handing execution off to a compiled operating system kernel.
**Estimated Time:** 4 to 8 Weeks
**Lab Tooling ([`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)):** `gdb`, `nasm`, `qemu_full`, `OVMF.fd`, `evtest`, `libinput`, `acpica-tools`, `cpuid`

### 1.1 Microarchitecture & Instruction Sets
- [ ] **Instruction Set Architectures (ISA):** Differentiate between register-rich x86-64 CISC and energy-efficient ARM64 RISC models at the execution level.
- [ ] **CPU Registers & State:** Map the roles of General Purpose Registers, Instruction Pointers (`RIP`), and Stack Pointers (`RSP`).
- [ ] **The Execution Ring Model:** Study the hardware-enforced isolation barriers protecting Ring 0 (Kernel Space) from Ring 3 (User Space).
- [ ] **Memory Management Units (MMU):** Learn how physical silicon maps arbitrary virtual memory addresses to physical RAM rows using page tables.

### 1.2 Hardware Interrupts & Input Pipelines
- [ ] **The Matrix Controller & Bus:** Trace the physical generation of scancodes from keyboard matrix sweeps through USB Host Controller registers (Practical reference: [`modules/nixos/hardware/apple-keyboard.nix`](../modules/nixos/hardware/apple-keyboard.nix)).
- [ ] **Interrupt Request (IRQ) Lines:** Track how hardware lines assert voltage to force the CPU into context-switching.
- [ ] **Interrupt Descriptor Table (IDT):** Examine the kernel-mapped vector table that translates IRQ indexes into target memory pointers for handlers.

### 1.3 The Boot Sequence Mechanics
- [ ] **The Reset Vector:** Trace the CPU's fixed initial execution jump point (`0xFFFFFFF0`) immediately following power stabilization.
- [ ] **UEFI Execution Phase:** Understand the transition phases from SEC (Security) $\rightarrow$ PEI (Pre-EFI Initialization) $\rightarrow$ DXE (Driver Execution Environment) $\rightarrow$ BDS (Boot Device Selection).
- [ ] **The Bootloader Handoff:** Analyze how tools like systemd-boot ([`modules/nixos/core/boot.nix`](../modules/nixos/core/boot.nix)) or GRUB load the compressed kernel image (`vmlinuz`) into memory, construct the initial RAM disk (`initramfs`), and jump execution directly into kernel initialization.

---

## Phase 2: Linux From Scratch (The Classic OS Layer)
**Objective:** Demystify traditional Linux environments by compiling a completely self-sustaining, functional Unix system directly from upstream source repositories.
**Estimated Time:** 4 to 8 Weeks
**Lab Tooling ([`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)):** `gcc`, `binutils`, `gnumake`, `ncurses`, `flex`, `bison`, `bc`, `elfutils`, `pahole`, `cpio`, `strace`, `ltrace`, `perf`

### 2.1 Cross-Compilation & Host Isolation
- [ ] **The Toolchain Build:** Compile a clean cross-compilation environment containing `binutils`, `gcc`, and the GNU C Library (`glibc`) to isolate the target build from host environment pollution.
- [ ] **Virtual Filesystem Injection:** Manually create and mount the foundational kernel interfaces: `/proc` (procfs), `/sys` (sysfs), `/dev` (devtmpfs), and `/run`.

### 2.2 Kernel Configuration & Mainlining
- [ ] **Monolithic Kernel Tailoring:** Master `make menuconfig` to strip away generic boilerplate, explicitly matching driver targets to specific local physical storage controllers, USB topologies, and silicon features.
- [ ] **Compilation Artifacts:** Build the live kernel image alongside individual dynamically-loadable kernel modules (`.ko`).

### 2.3 Foundational Userspace & The Filesystem Hierarchy
- [ ] **FHS Compliance:** Construct standard physical system directories (`/bin`, `/sbin`, `/lib`, `/etc`, `/usr`).
- [ ] **Core Utilities Integration:** Source-compile the absolute baseline execution environment (`bash`, `coreutils`, `util-linux`, `findutils`, `grep`, `sed`).
- [ ] **The Init Daemon:** Write structural initialization logic to orchestrate process spawning, logging management, and terminal multi-plexing.

---

## Phase 3: Mastering NixOS & Functional Package Management
**Objective:** Break away from traditional mutable state distributions and learn to manage system configuration as a pure, mathematical, deterministic function.
**Estimated Time:** 8 to 16 Weeks
**Lab Tooling ([`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)):** `nix-tree`, `nix-diff`, `nix-output-monitor`, `nvd`, `nix-index`, `nixd`

### 3.1 The Nix Expression Language
- [x] **Functional Paradigms:** Learn functional patterns within the Nix language, focusing on lazy evaluation, immutability, and side-effect isolation.
- [x] **Language Primitives:** Master attributes, attribute sets, lists, functions, and bindings (`let ... in ...`, `with`, `inherit`).
- [x] **Derivations:** Deconstruct how the low-level `derivation` primitive converts a functional declaration into a concrete build instructions file (`.drv`).

### 3.2 The Nix Store & Architecture
- [x] **Cryptographic Isolation:** Study how `/nix/store` completely replaces the traditional Filesystem Hierarchy Standard using a content-addressable storage model based on hashes of inputs (`/nix/store/[hash]-package-version`).
- [x] **Eliminating Dependency Hell:** Understand how atomic symlinks allow multiple conflicting versions of the exact same package or library to run concurrently on a single system without collision.
- [x] **The Atomic Generation Paradigm:** Trace how system activations operate via symlink updates, enabling instantaneous, safe system rollbacks at the bootloader stage (and stateless root resets via [`modules/nixos/core/impermanence.nix`](../modules/nixos/core/impermanence.nix)).

### 3.3 Advanced Architecture: Flakes & Modules
- [x] **Nix Flakes:** Implement modern Hermetic builds using explicit inputs ([`flake.nix`](../flake.nix), [`flake.lock`](../flake.lock)) and predictable outputs to completely bypass traditional reliance on mutable local channels.
- [x] **The Module System:** Master the `options` and `config` abstraction layer to build clean, reusable configuration schemas (e.g., [`modules/nixos/core/impermanence.nix`](../modules/nixos/core/impermanence.nix), [`modules/nixos/services/nut.nix`](../modules/nixos/services/nut.nix), [`modules/nixos/services/snipeit.nix`](../modules/nixos/services/snipeit.nix)).
- [x] **Multi-Node Declarative Management:** Structuring multi-node automation systems ([`modules/nixos/core/nixos-anywhere.nix`](../modules/nixos/core/nixos-anywhere.nix), [`deploy-rs.nix`](../modules/nixos/core/deploy-rs.nix), [`colmena.nix`](../modules/nixos/core/colmena.nix)), handling cross-compilation targets, and structuring declarative deployment matrices across diverse hardware configurations ([`hosts/nixos/lab-probook/default.nix`](../hosts/nixos/lab-probook/default.nix)).

---

## Shared Execution Log & Scope Tracking

Use this section to log open inquiries, design patterns, or current technical blockers across our sessions.

| Target Module | Current Objective / Project Focus | Status | Notes / Blockers |
| :--- | :--- | :--- | :--- |
| *Example: 1.2* | *Tracing `/dev/input/event` buffers* | *In Progress* | *Analyzing byte alignment differences between x86 and ARM64 (`evtest` installed via `kernel-lfs-tools.nix`)* |
| *3.3* | *1-to-1 Multi-OS Module Matrix* | *Completed* | *Built 1-to-1 NixOS & shared modules across `common/`, `shared/`, and `nixos/{core,hardware,desktop,apps,services}/`* |

---

## Architectural Equations Reference

When configuring and validating resource boundaries or hashing parameters across environments, use these standard primitives as design references:

### Content Addressable Store Hash Input
The cryptographic store path is a deterministic derivation output hash function:
<div style="text-align:center; margin:1em 0; font-size:1.1em;">
<span class="math">PathHash = Base32(SHA256(Type + ":" + Inputs + ":" + SourcePath + ":" + Name))</span>
</div>

### System Execution State Matrix
A purely functional operating system state calculation can be modeled as:
<div style="text-align:center; margin:1em 0; font-size:1.1em;">
<span class="math">f(Inputs, Configuration) → SystemState</span>
</div>
Where every modification to <span class="math">Configuration</span> produces a completely new, immutable instance of <span class="math">SystemState</span>, leaving previous iterations perfectly intact for rollback operations.
