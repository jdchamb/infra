# modules/tooling/ollama.nix
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ollama ];
  environment.variables = {
    OLLAMA_HOST = "http://10.14.5.16:11434";
  };
}
