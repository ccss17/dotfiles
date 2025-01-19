# ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
If (Test-Path "~\miniconda3\Scripts\conda.exe") {
    (& "~\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}

function clearls { clear ; ls }
function cdup { cd .. }
function exitf { exit }
function lsa { ls -a }
function lsla { ls -la }
function lstree { ls --tree }
function get_ip {
  $IpAddress = (Get-NetIPAddress |
    Where-Object {
      $_.AddressState -eq 'Preferred' -and 
      $_.ValidLifetime -lt '24:00:00'
    }
  );$IpAddress.IPAddress
}
function get_public_ip {
  (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
}

New-Alias d docker
New-Alias c clear
New-Alias g git
New-Alias q exitf
Remove-Alias ls
New-Alias ls lsd
New-Alias l ls
New-Alias la lsa
New-Alias ll lsla
New-Alias lt lstree
New-Alias cl clearls
New-Alias cs cdup
New-Alias ip get_ip

$Env:ip = get_ip
$Env:public_ip = get_public_ip

oh-my-posh init pwsh --config ~\AppData\Local\Programs\oh-my-posh\themes\paradox_custom.omp.json | Invoke-Expression