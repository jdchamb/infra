# USD 308 Project Board

## 🏃 In Progress
* **Project 2:** Compile list of bills for non-returned staff equipment for 2025-2026.
* **Project 9:** Update Autodesk Fusion installer and isolate the FeatureCAM module deployment workflow.
* **Project 11:** Pull all Wi-Fi MAC addresses for every device in Snipe-IT and compile a CSV import for macauth validation.
* **Project 13:** Maintain and update comprehensive ClearTouch inventory information on the master spreadsheet.

## 📋 To Do (Active Queue)


## ⏳ On Hold / Future Prospects
* **Project 10:** Review, optimize, and update the UltraVNC PDQ deployment package.
* **Project 3:** Update Snipe-IT and host OS (Evaluate current Debian + Git clone path vs fresh VM).
* **Project 4:** Test if FileWave macOS updates will function natively off of the 308 network.
* **Project 5:** Make a better Windows 11 deployment image using DISM.
* **Project 6:** Setup a centralized password manager vault for the USD 308 Tech Dept.
* **Project 7:** Create a mock ticketing system with internal documentation.
* **Project 8:** Create an internal USD 308 technical wiki for department documentation.
* **Project 14:** Engineer an automated method/uninstaller to strip all lingering Autodesk registry and file remnants from Windows 11.
* **Project 15:** Setup FOG Server as a potential modern replacement for WDS (as WDS deprecates on newer Windows Server editions).
* **Project 16:** Configure PDQ email notification delivery pipeline (Pending supervisor/boss decision).
* **Project 22:** Print asset labels for cleartouches @ grandview
* **Project 23:** Go to grandview to scope out the situation
* **Project 24:** Need to check out devices according to Pam's labels for HHS and HVS
* **Project 25:** Need to add MAC addresses for ct wireless modules into snipeit
* **Project 27:** User profiles for cleartouch boards (android). Hoping to be able to allow more apps like play store on the admin user but set the default to a second user account to avoid access.

---

## ✅ Completed Tasks
* **Project 1: Update PDQ packages (Adobe, Autodesk, HoverCAM, VLC, DYMO)**
    * *Current status:* Underway. Adobe and Autodesk silent deployments are almost complete. Successful runs: 4/10 on test devices. Ready to grab the latest installers for VLC, DYMO, and HoverCAM to incorporate into the deployment job next.
* **Project 26:** CTEA missed boards, HHS A204 A106 f100 f105, HMS8 3rd floor, HMS8  414 115 116, lil hawks childcare center, SJH, Lincoln
* **Project 28:** Process RMA'd boards
* **Project 30:** Process another iphone for James
* **Project 29:** Process iphone for James
    * *Completion Date:* 2026.07.10 CDT
    * *Resolution:* Processed all the data into snipeit and put device into the delivery cabinet
* **Project 20:** Inventory HP laptops for James
    * *Completion Date:* 2026-06-29 13:21:28 CDT
    * *Resolution:* Processed all the data into a spreadsheet. Sent the list to Vance for assets and gave the labels to James for the laptops. They are in SnipeIT ready for checkout.
* **Project 21:** Print HVS Labels for Pam
    * *Completion Date:* 2026-06-29 09:29:17 CDT
    * *Resolution:* Labels printed and completed.
* **Project 19: Print chromebook labels for Pam**
    * *Completion Date:* 2026-06-26 16:11 CDT
    * *Resolution:* Labels printed and completed.
* **Project 17: Setup secrets management using SOPS / age for encrypted credentials**
    * *Completion Date:* 2026-06-26
    * *Resolution:* Successfully integrated `sops-nix` engine into `wrk-dt01` using a locally stored master age key file. Automated variables securely decrypt straight into a volatile in-memory tmpfs filesystem (`/run/secrets/`), eliminating cleartext keys on permanent physical storage.
* **Project 18: Wire up and test USD 308 network share automounts**
    * *Completion Date:* 2026-06-25
    * *Resolution:* Refactored all infrastructure shares (`WorkStorage`, `CloudStorage`, `PDQServer/Software`, and `PDQServer/Scripts`) into true kernel-level boot-time systemd mounts with explicit `network-online.target` dependencies. Verified to ingest the newly created SOPS secret symlinks flawlessly without a machine reboot.
2026-06-29 09:29:17
