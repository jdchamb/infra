<#
.SYNOPSIS
  USD 308 Project 16: Tests SMTP relay connectivity and TLS delivery for PDQ Deploy notifications.
#>
param(
  [string]$SmtpServer = "smtp.usd308.com",
  [int]$Port = 587,
  [string]$From = "pdq-alerts@usd308.com",
  [string]$To = "jchambers@usd308.com"
)

Send-MailMessage -SmtpServer $SmtpServer -Port $Port -UseSsl `
  -From $From -To $To `
  -Subject "[USD 308 PDQ] Deployment Notification Pipeline Test" `
  -Body "PDQ notification relay test succeeded from $(hostname) at $(Get-Date -Format o)."
