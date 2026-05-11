{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    anything-llm
  ];
}
