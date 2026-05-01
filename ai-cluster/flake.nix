{
  description = "NixOS Cluster Flake for HP ProBook AI Nodes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs:
    let
      nodeMap = {
        "308-210351" = "192.168.2.11";
        "308-210352" = "192.168.2.12";
        "308-210353" = "192.168.2.13";
        "308-210354" = "192.168.2.14";
        "308-210355" = "192.168.2.15";
      };

      commonConfig = { hostname, ip }: {
users.users.root.hashedPassword = "$6$dizpgXZUtlyN0hsj$HBuOCqj15NIBzT9iPO9F7D1o0L9cnMTYOba0m1jpf3NWBgTEcpeBPNGGc.CX3t.g6s1rjX7NJVDiUzkAOxdO40";
        networking.hostName = hostname;
        
        # --- BOOTLOADER FIX ---
        # Added this to satisfy the "Failed assertion" from your last run.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        
        # --- STATIC IP CONFIGURATION ---
        networking.useDHCP = false;
        # Note: Ensure 'enp0s31f6' is the correct interface name for these ProBooks.
        networking.interfaces.enp0s31f6.ipv4.addresses = [{
          address = ip;
          prefixLength = 24;
        }];
        networking.defaultGateway = "192.168.2.1";
        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

        zramSwap.enable = true;
        
        # --- LOGIND SETTINGS FIX ---
        # Fixed syntax: moved to services.logind.settings and used strings for "ignore".
        services.logind.settings = {
          Login = {
            HandleLidSwitch = "ignore";
            HandleLidSwitchExternalPower = "ignore";
            HandleLidSwitchDocked = "ignore";
          };
        };
        
        systemd.targets.sleep.enable = false;
        systemd.targets.suspend.enable = false;

        services.openssh.enable = true;
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHTjL0orfamy9FzS8ovJ+cyXOjw/PygUUmCAspsbsjOD 308-225660 USD308 macbook air m4"
        ];

        environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
          git
          vim
          python3
          pciutils
        ];

        # Set to the current stable or keep as is if you know what you're doing.
        system.stateVersion = "24.11"; 
      };

      mkNode = hostname: ip: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./disko-config.nix
          (commonConfig { inherit hostname ip; })
        ];
      };
    in {
      nixosConfigurations = nixpkgs.lib.mapAttrs (name: ip: mkNode name ip) nodeMap;
    };
}
