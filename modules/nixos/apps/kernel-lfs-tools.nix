# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kernel-lfs-tools.nix (Systems Toolchain)
# ==============================================================================
#
# ROLE & ARCHITECTURE (docs/pprojectslearn.md — Silicon, LFS & Nix Store Lab):
#   Provisions the comprehensive systems engineering and operating systems learning
#   toolchain mapped to the three educational milestones in 'docs/pprojectslearn.md':
#     - Milestone 1 (Silicon, Registers, IRQs & UEFI Boot):
#         'nasm', 'gdb', 'qemu_full', 'OVMF.fd', 'evtest', 'libinput', 'acpica-tools', 'cpuid'.
#     - Milestone 2 (Linux From Scratch & Custom Kernel Compilation):
#         'gcc', 'binutils', 'gnumake', 'ncurses', 'flex', 'bison', 'bc', 'elfutils',
#         'openssl', 'pahole', 'cpio', 'zstd', 'strace', 'ltrace', 'perf'.
#     - Milestone 3 (Nix Store, Derivations & Flake Architecture):
#         'nix-tree', 'nix-diff', 'nix-output-monitor' ('nom'), 'nvd', 'nix-index'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   To truly understand how computers work under the hood, software engineers study
#   three fundamental abstraction layers:
#     1. The Silicon & Boot Layer: How CPU instruction pointer registers (RIP) start
#        in 16-bit real mode, transition through UEFI firmware (OVMF), and handle
#        hardware interrupts (IRQs) from keyboards and mice. Tools like QEMU, GDB,
#        and NASM let you simulate hardware and step through assembly code instruction by instruction.
#     2. The Kernel & POSIX Layer: How an operating system kernel is compiled from C
#        source code into a bootable binary, and how userspace programs talk to the
#        kernel via system calls (syscalls). Tools like GCC, Make, Flex/Bison, and
#        Strace allow you to compile custom Linux kernels and spy on every syscall
#        crossing the Ring 3 (user) to Ring 0 (kernel) boundary.
#     3. The Functional Nix Layer: How NixOS eliminates dependency hell by treating
#        software builds as pure mathematical functions with cryptographic hashes.
#        Tools like 'nom', 'nvd', and 'nix-tree' let you visualize the dependency
#        graph, spot bloated packages, and inspect exact diffs between system rebuilds.
#
# HOW TO USE:
#   - Visualize /nix/store disk space usage: 'nix-tree'
#   - See what changed between two NixOS generations:
#       nvd diff /nix/var/nix/profiles/system-42-link /nix/var/nix/profiles/system-43-link
#   - Trace system calls made by a running program: 'strace -f -e trace=openat,read ls'
#   - Trace hardware input events (keyboard scancodes): 'sudo evtest'
# ==============================================================================

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --------------------------------------------------------------------------
    # Milestone 1: Silicon, Bare Metal, Interrupts & UEFI Boot Sequence
    # --------------------------------------------------------------------------
    nasm                        # Netwide Assembler: x86/x86_64 assembler for bootloader experiments
    gdb                         # GNU Debugger: inspects CPU registers (RIP, RSP), stack frames, memory
    qemu_full                   # Full system emulator for simulating virtual x86_64 and ARM hardware
    OVMF.fd                     # Open Virtual Machine Firmware: UEFI BIOS binary used by QEMU
    evtest                      # Real-time event tracer for /dev/input devices (scancodes & key releases)
    libinput                    # Input device event validation ('libinput debug-events')
    acpica-tools                # Intel ACPI Component Architecture compiler and disassembler ('iasl')
    cpuid                       # Dumps raw CPU capability instruction leaves directly from the processor

    # --------------------------------------------------------------------------
    # Milestone 2: Linux From Scratch (LFS) & Monolithic Kernel Tailoring
    # --------------------------------------------------------------------------
    gcc                         # GNU Compiler Collection: standard C/C++ compiler for Linux kernels
    binutils                    # Binary utilities: linker ('ld'), assembler ('as'), 'objdump', 'readelf'
    gnumake                     # Controls the compilation of source trees from Makefiles
    ncurses                     # Terminal GUI library required for 'make menuconfig' kernel configuration
    pkg-config                  # Resolves compile/link flags for shared libraries automatically
    flex                        # Fast lexical analyzer generator (scans kernel grammar tokens)
    bison                       # GNU general-purpose parser generator (builds kernel parser tables)
    bc                          # Arbitrary precision decimal calculator used during kernel compilation
    elfutils                    # libelf development headers for kernel module signature verification
    openssl                     # Cryptographic toolkit used for generating kernel module signing keys
    pahole                      # DWARF structure inspector; converts debug types to BTF for eBPF/CO-RE
    cpio                        # Archive tool used to create initial RAM disk images ('initramfs')
    zstd                        # Real-time compression engine used to compress modern Linux kernels
    strace                      # System call tracer: captures interactions between programs and the kernel
    ltrace                      # Dynamic library call tracer: intercepts shared library calls (libc)
    linuxPackages_latest.perf   # Linux kernel performance profiler for CPU cache misses and flamegraphs

    # --------------------------------------------------------------------------
    # Milestone 3: Declarative NixOS, Derivations & Dependency Graph Inspection
    # --------------------------------------------------------------------------
    nix-tree                    # Interactive terminal UI to browse closure trees and package sizes
    nix-diff                    # Explains structural differences between two Nix store derivation files
    nix-output-monitor          # 'nom' command: renders real-time graphical progress bars for Nix builds
    nvd                         # Shows package version upgrades/downgrades between two NixOS generations
    nix-index                   # Fast index to find which nixpkgs derivation provides an uninstalled command
  ];
}
