{ inputs, ... }:

{
  sops = {
    # 1. Point to your default secrets file in the repository
    defaultSopsFile = "${inputs.self}/secrets/308-secrets.yaml";
    defaultSopsFormat = "yaml";

    # 2. Tell it to look specifically for your new work private key file
    age.keyFile = "/var/lib/sops-nix/308-key.txt";

    # 3. Define the secrets to extract and where they should go on the live system
    secrets = {
      "credentials-adminjc" = {
        path = "/etc/nixos/secrets/308-adminjc";
        mode = "0600";
      };
      "credentials-macos-admin308" = {
        path = "/etc/nixos/secrets/308-admin308";
        mode = "0600";
      };
    };
  };
}
