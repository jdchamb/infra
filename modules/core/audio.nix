{ pkgs, ... }:

{
  # Disable PulseAudio in favor of Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Add jack.enable = true; here if you ever do pro-audio work
  };

  # Helpful audio management tool
  environment.systemPackages = [ pkgs.pavucontrol ];
}
