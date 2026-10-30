# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/ollama.nix (Ollama LLM Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet AI Services Roadmap — 1-to-1 Module for Ollama):
#   Installs the Ollama command-line client and globally sets 'OLLAMA_HOST' to
#   point to the dedicated LAN inference server ('10.14.5.16:11434').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Large Language Models (LLMs) like Llama 3, Mistral, or DeepSeek require heavy
#   GPU compute and VRAM. Instead of running a resource-heavy AI engine directly
#   on lightweight laptops or VMs, USD 308 / the homelab runs a dedicated GPU
#   server at IP '10.14.5.16'.
#   By installing the 'ollama' CLI package and setting the 'OLLAMA_HOST' environment
#   variable, any command you run locally (e.g., 'ollama run codellama') forwards
#   its prompt to the high-powered server over the local network and streams the
#   tokens back to your terminal seamlessly.
#
# HOW TO USE:
#   - Importing this module makes the 'ollama' command available system-wide.
#   - Test connectivity to the LAN server:
#       ollama list
#   - Run an interactive session with an installed model:
#       ollama run llama3
#   - Verify your active target host:
#       echo $OLLAMA_HOST
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # System Packages: Ollama CLI
  # Installs the client binary needed to pull models, inspect contexts, and prompt.
  # --------------------------------------------------------------------------
  environment.systemPackages = [
    pkgs.ollama
  ];

  # --------------------------------------------------------------------------
  # Global Environment Variables
  # Tells the Ollama client to direct all REST API and streaming calls to the
  # remote GPU server rather than looking for a local daemon on 127.0.0.1:11434.
  # --------------------------------------------------------------------------
  environment.variables = {
    OLLAMA_HOST = "http://10.14.5.16:11434";
  };
}
