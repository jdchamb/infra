# ==============================================================================
# WINDOWS AUTOMATION SCRIPT: modules/windows/scripts/Test-PDQEmailPipeline.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 16):
#   Tests SMTP relay connectivity, port 587 firewall clearance, and TLS delivery
#   from the PDQ Deploy server before enabling automated deployment summary emails.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When PDQ Deploy runs overnight software updates across school buildings, we
#   want it to email a pass/fail report. However, internal SMTP relays often
#   require specific IP whitelisting or TLS settings. Running this one-shot test
#   script verifies that the PDQ server can successfully reach the mail server
#   and deliver an encrypted test message before configuring scheduled jobs.
# ==============================================================================

param(
  # Internal or relay SMTP server hostname
  [string]$SmtpServer = "smtp.usd308.com",

  # Standard STARTTLS submission port (587)
  [int]$Port = 587,

  # Sender address configured in PDQ Deploy Preferences -> Mail Server
  [string]$From = "pdq-alerts@usd308.com",

  # Recipient address for verifying end-to-end inbox delivery
  [string]$To = "jchambers@usd308.com"
)

# Send a timestamped test email over TLS (-UseSsl) to confirm SMTP relay health
Send-MailMessage -SmtpServer $SmtpServer -Port $Port -UseSsl `
  -From $From -To $To `
  -Subject "[USD 308 PDQ] Deployment Notification Pipeline Test" `
  -Body "PDQ notification relay test succeeded from $(hostname) at $(Get-Date -Format o)."
