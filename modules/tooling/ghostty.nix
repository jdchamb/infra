{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ghostty ];


  # Note: Since Ghostty is newer, if 'pkgs.ghostty' fails,
  # we may need to add the Ghostty flake to your inputs.
}
