# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/audio.nix (PipeWire Multimedia Stack)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Replaces legacy PulseAudio with the modern PipeWire multimedia server.
#   Enables RealtimeKit (rtkit) scheduling priority for glitch-free audio and
#   exposes ALSA (32-bit/64-bit) and PulseAudio compatibility layers alongside
#   the 'pavucontrol' graphical mixer.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Disable legacy PulseAudio daemon and enable RealtimeKit scheduling
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # 2. Enable PipeWire with ALSA and PulseAudio compatibility bridges
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # Enable if low-latency JACK pro-audio routing is needed
  };

  # 3. Graphical Volume & Stream Routing Control
  environment.systemPackages = [ pkgs.pavucontrol ];
}
