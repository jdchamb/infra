{ pkgs, aiLibrary, ... }: # Add aiLibrary to the arguments at the top

{
  virtualisation.oci-containers.containers."anythingllm" = {
    image = "mintplexlabs/anythingllm";
    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"

      # MOUNT THE NIX STORE (Required for links to work)
      "/nix/store:/nix/store:ro"

      # DIRECT BIND: Map the Nix folder to the container's document path
      "${aiLibrary}:/app/server/storage/documents/forge-context:ro"

      # BIND your actual dotfiles so the AI can see them
      "/home/jchambers/src/dotfiles:/app/server/storage/documents/my-configs:ro"
    ];

    extraOptions = [ "--network=host" ];
    environment.STORAGE_DIR = "/app/server/storage";
    autoStart = true;
  };
}
