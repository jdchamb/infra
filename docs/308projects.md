# USD 308 Project Board

## 🏃 In Progress
* **Project 17:** Setup secrets management using SOPS / age for encrypted credentials.
    * *Current status:* On deck. Holding off on implementation until local file mount layout settles.
* **Project 1: Update PDQ packages (Adobe, Autodesk, HoverCAM, VLC, DYMO)**
    * *Current status:* Underway. Adobe and Autodesk silent deployments are almost complete. Successful runs: 4/10 on test devices. Ready to grab the latest installers for VLC, DYMO, and HoverCAM to incorporate into the deployment job next.

## 📋 To Do (Active Queue)
* **Project 2:** Compile list of bills for non-returned staff equipment for 2025-2026.
* **Project 3:** Update Snipe-IT and host OS (Evaluate current Debian + Git clone path vs fresh VM).
* **Project 4:** Test if FileWave macOS updates will function natively off of the 308 network.
* **Project 5:** Make a better Windows 11 deployment image using DISM.
* **Project 6:** Setup a centralized password manager vault for the USD 308 Tech Dept.
* **Project 7:** Create a mock ticketing system with internal documentation.
* **Project 8:** Create an internal USD 308 technical wiki for department documentation.
* **Project 9:** Update Autodesk Fusion installer and isolate the FeatureCAM module deployment workflow.
* **Project 10:** Review, optimize, and update the UltraVNC PDQ deployment package.
* **Project 11:** Pull all Wi-Fi MAC addresses for every device in Snipe-IT and compile a CSV import for macauth validation.
* **Project 12:** Verify all ClearTouch boards at HMS8 and HHS (Create automation folders to ingest device photos automatically for HMS8, HMS7, CTEA, and HHS).
* **Project 13:** Maintain and update comprehensive ClearTouch inventory information on the master spreadsheet.
    * *Current status:* HHS is wrapping up. All CT boards are installed in HMS8 HMS7 CTEA and HHS(a-hall,b-hall,c-hall,v-hall).
* **Project 14:** Engineer an automated method/uninstaller to strip all lingering Autodesk registry and file remnants from Windows 11.

## ⏳ On Hold / Future Prospects
* **Project 15:** Setup FOG Server as a potential modern replacement for WDS (as WDS deprecates on newer Windows Server editions).
* **Project 16:** Configure PDQ email notification delivery pipeline (Pending supervisor/boss decision).

---

## ✅ Completed Tasks
* [x] **Project 18: Wire up and test USD 308 network share automounts.**
    * *Completion Date:* 2026-06-25
    * *Resolution:* Refactored all infrastructure shares (`WorkStorage`, `CloudStorage`, `PDQServer/Software`, and `PDQServer/Scripts`) into true kernel-level boot-time systemd mounts with explicit `network-online.target` dependencies. All shares are fully active and available instantly at startup.
