{ pkgs, aiLibrary, ... }: # Add aiLibrary to the arguments here

{
  virtualisation.oci-containers.containers."anythingllm" = {
    image = "mintplexlabs/anythingllm";
    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"
      "/nix/store:/nix/store:ro"

      # DIRECT BIND: Mount the Nix-managed library into the container's document folder
      "${aiLibrary}:/app/server/storage/documents/forge-context:ro"

      # BIND your actual dotfiles so the AI can see them
      "/home/jchambers/src/dotfiles:/app/server/storage/documents/my-configs:ro"
    ];

    extraOptions = [ "--network=host" ];
    environment.STORAGE_DIR = "/app/server/storage";
    autoStart = true;
  };
}
