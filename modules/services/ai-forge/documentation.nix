{ config, lib, pkgs, ... }:

let
  # The "Knowledge Sources" - Immutable manuals from the Nix Store
  nixosManual = pkgs.fetchurl {
    url = "https://nixos.org/manual/nixos/stable/index.html";
    hash = "sha256-YOUR_VERIFIED_HASH_FROM_STEP_4";
  };

  darwinManual = pkgs.fetchurl {
    url = "https://github.com/nix-darwin/nix-darwin/archive/master.tar.gz";
    hash = lib.fakeHash; # Get this on next rebuild
  };

  onDroidManual = pkgs.fetchurl {
    url = "https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html";
    hash = lib.fakeHash; # Get this on next rebuild
  };
in {
  # Activation Script to build the AnythingLLM "Library"
  system.activationScripts.aiForgeLibrary = {
    text = ''
      # The internal path inside the AnythingLLM Docker container
      # This assumes your volume is mounted to /var/lib/anythingllm
      DOC_PATH="/var/lib/anythingllm/storage/documents/forge-context"
      mkdir -p "$DOC_PATH"

      # Symlink the manuals. This is the "Training" part.
      ln -sfn ${nixosManual}   "$DOC_PATH/nixos-manual.html"
      ln -sfn ${darwinManual}  "$DOC_PATH/nix-darwin-manual.tar.gz"
      ln -sfn ${onDroidManual} "$DOC_PATH/nix-on-droid-options.html"

      # Also link your actual live dotfiles for real-time awareness
      # Replace with your actual path on the ProDesk
      ln -sfn /home/jchambers/dotfiles "$DOC_PATH/my-actual-configs"
    '';
  };
}
