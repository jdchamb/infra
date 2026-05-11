{ inputs, ... }:

{
  # 1. Import the nix-flatpak logic into this specific module
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;

    # 2. THE SECRET SAUCE:
    # This tells Nix to UNINSTALL any flatpak not listed below.
    uninstallUnmanaged = true;

    # 3. Add the Flathub repo automatically
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    # 4. Declare the package
    packages = [
      "com.useanything.anythingllm"
    ];
  };
}
