{ pkgs, ... }:

{
  # Only install the client tool
  environment.systemPackages = [ pkgs.ollama ];

  # Point the ProDesk to the MacBook's IP
  environment.variables = {
    # Replace '192.168.x.x' with your MacBook's actual local IP
    OLLAMA_HOST = "http://10.14.5.16:11434";
  };
}
