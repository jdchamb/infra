# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/ollama.nix (Ollama LLM Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Ollama):
#   Installs the Ollama CLI client and points 'OLLAMA_HOST' at the dedicated
#   LAN inference server ('10.14.5.16:11434') so local terminals and editors can
#   query local models without taxing workstation CPU/RAM.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ollama ];
  environment.variables = {
    OLLAMA_HOST = "http://10.14.5.16:11434";
  };
}
