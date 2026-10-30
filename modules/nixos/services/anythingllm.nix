# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/anythingllm.nix (AnythingLLM)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet AI Services Roadmap — 1-to-1 Module for AnythingLLM):
#   Deploys AnythingLLM ('virtualisation.oci-containers.containers.anythingllm'),
#   a self-hosted, full-stack AI workspace and Retrieval-Augmented Generation (RAG)
#   application that runs locally in Podman.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   AnythingLLM lets you chat with documents (PDFs, Markdown notes, district manuals,
#   runbooks) using local or remote LLMs (like Ollama or OpenAI).
#   Instead of sending confidential district documentation to third-party cloud
#   providers, AnythingLLM processes and embeds your documents locally. It pairs
#   directly with our local Ollama server (see 'modules/nixos/services/ollama.nix').
#
# HOW TO USE:
#   - Importing this module turns the AnythingLLM container ON immediately.
#   - Access the web interface: http://<host-ip>:3001
#   - Document vector storage & application database: /home/jchambers/anythingllm
#   - When prompted for an LLM provider during onboarding, choose "Ollama" and enter:
#       http://127.0.0.1:11434 (or host IP).
#
# >>> CRITICAL PORT CONFLICT NOTICE <<<
#   AnythingLLM listens on TCP port 3001 by default. Because this module uses
#   '--network=host', it binds directly to port 3001 on the host machine.
#   Port 3001 is ALSO the default HTTP port configured for Forgejo
#   ('modules/nixos/services/forgejo.nix').
#   DO NOT import both 'anythingllm.nix' and 'forgejo.nix' on the same physical
#   or virtual host without remapping Forgejo's HTTP_PORT or AnythingLLM's port.
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # OCI Container Definition: AnythingLLM
  # --------------------------------------------------------------------------
  virtualisation.oci-containers.containers."anythingllm" = {
    # Official multi-architecture image maintained by Mintplex Labs
    image = "mintplexlabs/anythingllm";

    # Mount persistent data directory from the user's home folder
    volumes = [
      "/home/jchambers/anythingllm:/app/server/storage"
    ];

    # Host networking allows direct communication with local Ollama on 127.0.0.1:11434
    # NOTE: Binds AnythingLLM web interface to host port 3001. See port conflict notice above.
    extraOptions = [ "--network=host" ];

    # Set storage root inside the container
    environment.STORAGE_DIR = "/app/server/storage";

    # Automatically start on boot with systemd
    autoStart = true;
  };
}
