{ pkgs, aiLibrary, ... }: # Add aiLibrary to the arguments at the top

{
  virtualisation.oci-containers.containers."anythingllm" = {
    image = "mintplexlabs/anythingllm";
    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"
    ];

    extraOptions = [ "--network=host" ];
    environment.STORAGE_DIR = "/app/server/storage";
    autoStart = true;
  };
}
