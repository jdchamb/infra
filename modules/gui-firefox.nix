{pkgs, ...}:
{
environment.systemPackages = [ pkgs.firefox ];
extraConfig = [ taskbar ];
}
