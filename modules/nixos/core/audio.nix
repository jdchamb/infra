# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/audio.nix (PipeWire Multimedia Stack)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Replaces legacy PulseAudio and JACK with the modern PipeWire multimedia graph
#   engine. Configures RealtimeKit (rtkit) for low-latency thread priority scheduling,
#   provides ALSA (both native 64-bit and 32-bit for legacy/Wine apps) and PulseAudio
#   compatibility layers, and installs 'pavucontrol' for graphical stream mixing.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In the Linux audio landscape:
#     - ALSA is the low-level kernel driver interface for sound cards.
#     - PulseAudio was the traditional desktop sound server, but had latency and
#       pro-audio routing limitations.
#     - JACK was used for professional music production, but was hard to configure
#       alongside desktop apps.
#     - PipeWire unifies all of them into a modern, fast, security-sandboxed audio
#       and video routing daemon.
#   - RealtimeKit ('security.rtkit'): When your CPU is busy compiling code or running
#     heavy tasks, audio threads can stutter. Rtkit allows PipeWire to safely acquire
#     real-time kernel CPU scheduling without needing full root privileges.
#   - 32-bit ALSA ('alsa.support32Bit'): Crucial for compatibility with 32-bit games
#     and Windows applications running inside Wine, Proton, or Steam.
#
# HOW TO USE:
#   - Audio works out of the box for desktop environments, browsers, and media players.
#   - Launch the audio mixer GUI: 'pavucontrol'
#   - Inspect PipeWire audio streams and nodes in terminal: 'pw-top' or 'wpctl status'
#   - Adjust volume from CLI: 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Daemon Conflicts & Realtime Scheduling
  # --------------------------------------------------------------------------
  # Explicitly turn off PulseAudio to prevent port/device contention with PipeWire
  services.pulseaudio.enable = false;

  # rtkit (RealtimeKit) hands out real-time scheduling priority to PipeWire threads
  # on demand, preventing clicks, pops, and buffer underruns during heavy system loads.
  security.rtkit.enable = true;

  # --------------------------------------------------------------------------
  # 2. PipeWire Audio Graph Engine
  # --------------------------------------------------------------------------
  services.pipewire = {
    enable = true;

    # Emulate ALSA interface so legacy Linux software plays sound through PipeWire
    alsa = {
      enable = true;
      # Build 32-bit ALSA plugin libraries for Wine, Proton, and 32-bit games
      support32Bit = true;
    };

    # PulseAudio emulation daemon (listens on standard PulseAudio UNIX socket)
    pulse.enable = true;

    # JACK emulation daemon (commented out by default; uncomment for pro-audio DAWs)
    # jack.enable = true;
  };

  # --------------------------------------------------------------------------
  # 3. User Tools
  # --------------------------------------------------------------------------
  # pavucontrol: PulseAudio Volume Control graphical tool (works seamlessly with PipeWire)
  environment.systemPackages = [
    pkgs.pavucontrol
  ];
}
