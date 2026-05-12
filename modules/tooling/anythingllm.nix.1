{ pkgs, ... }:

{
  # This enables the underlying container engine
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers."anythingllm" = {
    image = "mintplexlabs/anythingllm";
    ports = [ "3001:3001" ];
    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"
    ];
    environment = {
      STORAGE_DIR = "/app/server/storage";
    };
    autoStart = true;
  };

  # Open the port in your firewall so you can access the UI
  networking.firewall.allowedTCPPorts = [ 3001 ];
}
