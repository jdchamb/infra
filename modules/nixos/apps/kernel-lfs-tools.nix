# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kernel-lfs-tools.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (docs/pprojectslearn.md — Silicon, LFS & Nix Store Lab):
#   Provisions the low-level engineering toolchain mapped to the three phases in
#   'docs/pprojectslearn.md':
#     - Phase 1 (Silicon, Registers, IRQ/IDT & UEFI Boot):
#         'gdb', 'nasm', 'qemu_full', 'OVMF.fd', 'evtest' (for tracing
#         '/dev/input/event' scancode buffers), 'acpica-tools', 'cpuid'.
#     - Phase 2 (Linux From Scratch & Monolithic Kernel Tailoring):
#         'gcc', 'binutils', 'gnumake', 'ncurses' ('make menuconfig'), 'flex',
#         'bison', 'bc', 'elfutils', 'pahole', 'cpio', 'strace', 'ltrace', 'perf'.
#     - Phase 3 (Nix Store, Derivations & Flake Architecture):
#         'nix-tree', 'nix-diff', 'nix-output-monitor' ('nom'), 'nvd', 'nix-index'.
# ==============================================================================

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Phase 1: Silicon, Bare Metal, Interrupts & UEFI Handoff ---
    nasm                        # x86-64 assembler for real-mode / ring-0 experiments
    gdb                         # GNU Debugger for register inspection (RIP, RSP, page tables)
    qemu_full                   # x86_64 and AArch64 hardware virtualization emulator
    OVMF.fd                     # TianoCore UEFI firmware image for QEMU boot sequence tracing
    evtest                      # Live '/dev/input/event*' scancode & IRQ matrix tracer (Module 1.2)
    libinput                    # Input stack event debugging ('libinput debug-events')
    acpica-tools                # ACPI table disassembler ('iasl', 'acpidump')
    cpuid                       # Dump raw CPUID instruction register leaves

    # --- Phase 2: Linux From Scratch (LFS) & Kernel Compilation ---
    gcc                         # GNU C/C++ compiler collection
    binutils                    # Linker ('ld'), assembler ('as'), and ELF inspection ('objdump', 'readelf')
    gnumake                     # Build orchestration engine
    ncurses                     # Terminal UI library required by 'make menuconfig' / 'nconfig'
    pkg-config                  # Compiler/linker flag resolution helper
    flex                        # Fast lexical analyzer generator (required by Linux kernel build)
    bison                       # GNU parser generator (required by Linux kernel build)
    bc                          # Arbitrary precision calculator (required by kernel timeconst build)
    elfutils                    # 'libelf' headers required for kernel ORC unwinder & module signing
    openssl                     # Cryptographic library for kernel module signing
    pahole                      # DWARF to BTF type encoder for eBPF/kernel builds
    cpio                        # Packs and unpacks 'initramfs' initial RAM disk archives
    zstd                        # Fast kernel and initramfs compression engine
    strace                      # System call tracer (Ring 3 -> Ring 0 boundary inspection)
    ltrace                      # Dynamic library call tracer
    linuxPackages_latest.perf   # Hardware performance counter & kernel event profiler

    # --- Phase 3: Declarative NixOS, Derivations & Store Graph Inspection ---
    nix-tree                    # Interactive TUI to browse '/nix/store' closure sizes & references
    nix-diff                    # Explain exact input differences between two '.drv' store derivations
    nix-output-monitor          # Rich dependency-graph visualization for 'nix build' ('nom')
    nvd                         # Nix/NixOS package version diff tool between system generations
    nix-index                   # Locate which nixpkgs derivation provides any binary or header file
  ];
}
