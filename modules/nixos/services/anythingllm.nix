# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/anythingllm.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for AnythingLLM):
#   Deploys the AnythingLLM OCI container bound to host networking and backed by
#   persistent local storage ('/home/jchambers/anythingllm'), allowing private
#   RAG indexing over local technical documentation and runbooks.
# ==============================================================================

{ pkgs, ... }:

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
