{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    anythingllm
  ];
}
