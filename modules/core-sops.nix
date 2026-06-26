sops = {
    # 1. Point to your default secrets file in the repository
    defaultSopsFile = "${inputs.self}/secrets/308-secrets.yaml";
    defaultSopsFormat = "yaml";

    # 2. Tell it to look specifically for your new work private key file
    age.keyFile = "/var/lib/sops-nix/308-key.txt";

    # 3. Define the secrets to extract and where they should go on the live system
    secrets = {
      "smb-credentials-jc" = {
        path = "/etc/nixos/secrets/308-adminjc";
        mode = "0600";
      };
      "smb-credentials-308" = {
        path = "/etc/nixos/secrets/308-admin308";
        mode = "0600";
      };
    };
  };
