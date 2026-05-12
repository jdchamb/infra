{ pkgs, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers."anythingllm" = {
    image = "mintplexlabs/anythingllm";
    # REMOVE the 'ports' line if you use extraOptions below
    # ports = [ "3001:3001" ];

    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"
      "/nix/store:/nix/store:ro"
    ];

    # This lets the container see the ProDesk's network (and the Mac)
    extraOptions = [ "--network=host" ];

    environment = {
      STORAGE_DIR = "/app/server/storage";
    };
    autoStart = true;
  };
}
