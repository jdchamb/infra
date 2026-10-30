# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/normcap.nix (NormCap Screen OCR)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for NormCap):
#   Installs NormCap, an OCR-powered screen-capture tool that extracts text
#   (such as MAC addresses, serial numbers, or error codes from remote VNC/RDP
#   windows) directly into the system clipboard.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Text inside a remote-desktop window, a video, or a screenshot is just
#   pixels—you can't highlight and copy it. NormCap lets you drag a box over
#   any area of the screen and instantly turns those pixels into real text on
#   your clipboard. Perfect for copying a 17-character MAC address from a VNC
#   session into Snipe-IT without typos.
#   (gimagereader.nix handles whole PDF/image files; NormCap handles live screen regions.)
# ==============================================================================

{ pkgs, ... }:

{
  # Install NormCap screen-region OCR capture tool
  environment.systemPackages = [
    pkgs.normcap
  ];
}
