{ config, pkgs, inputs, ... }:

{
  # --- Core Plasma 6 System Service Activation
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kdf
    kdePackages.isoimagewriter
  ];

  # --- Declarative Taskbar Panel and System Monitor Configuration
  home-manager = {
    # Fixes the evaluation warning by using the updated upstream module name mapping
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

    users.jchambers = { ... }: {
      # Add standard home-manager file generation for Kate Snippets
      home.file.".local/share/ktexteditor/snippets/task_logging.xml".text = ''
        <snippets namespace="" version="1">
          <item id="cdate">
            <displaystring>Completion Date</displaystring>
            <script><![CDATA[
        var now = new Date();
        var yyyy = now.getFullYear();
        var mm = String(now.getMonth() + 1).padStart(2, '0');
        var dd = String(now.getDate()).padStart(2, '0');
        var hh = String(now.getHours()).padStart(2, '0');
        var min = String(now.getMinutes()).padStart(2, '0');
        var ss = String(now.getSeconds()).padStart(2, '0');

        return "* *Completion Date:* " + yyyy + "-" + mm + "-" + dd + " " + hh + ":" + min + ":" + ss + " CDT";
            ]]></script>
          </item>
          <item id="res">
            <displaystring>Resolution</displaystring>
            <script><![CDATA[
        return "* *Resolution:* ";
            ]]></script>
          </item>
          <item id="p21">
            <displaystring>Project 21</displaystring>
            <script><![CDATA[
        return "* **Project 21:** ";
            ]]></script>
          </item>
        </snippets>
      '';

      programs.plasma = {
        enable = true;
        overrideConfig = true; # Force matching declarative state on system activation

        panels = [
          {
            location = "bottom";
            height = 40;

            widgets = [
              # Left Side: Launcher
              "org.kde.plasma.kickoff"

              # Center: Window Tracking Task Manager
              "org.kde.plasma.icontasks"

              # Right Side: Integrated Compact Performance Sensors
              {
                name = "org.kde.plasma.systemmonitor";
                config = {
                  Appearance = {
                    "showTitle" = "false";
                    "faceId" = "org.kde.ksysguard.grid";
                  };
                  Sensors = {
                    "highPrioritySensors" = [
                      "cpu/all/usage"
                      "mem/physical/utilization"
                      "gpu/gpu0/usage"
                      "network/all/download"
                      "network/all/upload"
                      "disk/all/usedpercent"
                    ];
                    "labels" = [
                      "CPU"
                      "RAM"
                      "GPU"
                      "DL"
                      "UL"
                      "STR"
                    ];
                  };
                };
              }

              # End Elements: Tray & Clock
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
            ];
          }
        ];
      };
    };
  };
}
