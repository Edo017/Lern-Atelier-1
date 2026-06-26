<# Scriptname: System-Health-Checker.ps1
 Author: Edim  
 Date: 2026-06-24 
 Version: 1.7
 Description: System-Health-Check mit globalem Hotkey STRG+UMSCHALT+C. Prüft Speicher, CPU und RAM. Schreibt Ergebnisse in eine Logdatei auf dem Desktop. Öffnet Log in VS Code oder Standard-Editor. 
 #>

# ==============================================================================
# Automatischer System-Health-Checkinator 4000 (Universal Version)
# ==============================================================================

Add-Type -AssemblyName System.Windows.Forms

# --- Abschnitt 1: Pfade definieren ---
$DesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$LogPath = Join-Path $DesktopPath "SystemHealthLog.txt"

# --- Globaler Cooldown-Schutz (verhindert Mehrfach-Trigger) ---
$LastCheck = [DateTime]::MinValue

# Funktion zum Öffnen in VS Code mit Pfad-Suche
function Open-InVSCode {
    param([string]$Path)
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $Path
        return $true
    }
    
    $VSCodePaths = @(
        "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
        "$env:ProgramFiles(x86)\Microsoft VS Code\bin\code.cmd"
    )
    
    foreach ($vpath in $VSCodePaths) {
        if (Test-Path $vpath) {
            & $vpath $Path
            return $true
        }
    }
    
    return $false
}

# --- Funktion zum Ausführen des Health Checks ---
function Invoke-SystemHealthCheck {
    param([string]$LogFilePath)

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "`n--- System Check: $Timestamp ---`n"

    # --- Speicherplatz prüfen ---
    $DriveC = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $FreeSpaceGB = [math]::Round($DriveC.FreeSpace / 1GB, 2)
    
    if ($FreeSpaceGB -lt 10) {
        $LogEntry += "[WARNUNG] Speicher C: kritisch ($FreeSpaceGB GB)`n"
    } else {
        $LogEntry += "Speicher C: OK ($FreeSpaceGB GB)`n"
    }

    # --- CPU prüfen ---
    $CPU = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average
    $CPULoad = [math]::Round($CPU.Average, 2)
    
    if ($CPULoad -gt 90) {
        $LogEntry += "[WARNUNG] CPU hoch ($CPULoad %)`n"
    } else {
        $LogEntry += "CPU: OK ($CPULoad %)`n"
    }

    # --- RAM & Prozesse ---
    $OS = Get-WmiObject Win32_OperatingSystem
    $FreeRAMGB = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
    $ProcessCount = (Get-Process).Count
    $LogEntry += "RAM frei: $FreeRAMGB GB | Prozesse: $ProcessCount`n"

    Add-Content -Path $LogFilePath -Value $LogEntry
    return $LogFilePath
}

# ✅ KORREKTUR: Korrekte Tastenerkennung über GetAsyncKeyState (Win32 API)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class KeyboardHelper {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
    
    public static bool IsKeyDown(int vKey) {
        return (GetAsyncKeyState(vKey) & 0x8000) != 0;
    }
}
"@

# Virtual Key Codes
$VK_CONTROL = 0x11
$VK_SHIFT   = 0x10
$VK_C       = 0x43

# --- Hauptschleife ---
Write-Host "System Health Checkinator 4000 ist aktiv." -ForegroundColor Yellow
Write-Host "Hotkey: STRG + UMSCHALT + C" -ForegroundColor Cyan
Write-Host "Beenden mit STRG+C im Terminal`n" -ForegroundColor Gray

while ($true) {
    $ctrlDown  = [KeyboardHelper]::IsKeyDown($VK_CONTROL)
    $shiftDown = [KeyboardHelper]::IsKeyDown($VK_SHIFT)
    $cDown     = [KeyboardHelper]::IsKeyDown($VK_C)

    if ($ctrlDown -and $shiftDown -and $cDown) {
        
        # ✅ Cooldown: Verhindert Mehrfach-Trigger solange Taste gehalten wird
        $now = [DateTime]::Now
        if (($now - $LastCheck).TotalSeconds -lt 2) {
            Start-Sleep -Milliseconds 150
            continue
        }
        $LastCheck = $now

        Write-Host "`n[!] Check wird ausgeführt..." -ForegroundColor Cyan
        $res = Invoke-SystemHealthCheck -LogFilePath $LogPath
        Write-Host "[OK] Check abgeschlossen. Log: $res" -ForegroundColor Green

        # ✅ KORREKTUR: MessageBox statt Read-Host (blockiert die Schleife nicht dauerhaft)
        $mbResult = [System.Windows.Forms.MessageBox]::Show(
            "Check abgeschlossen!`nMöchtest du die Log-Datei in VS Code öffnen?",
            "System Health Checkinator 4000",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        if ($mbResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            if (-not (Open-InVSCode -Path $res)) {
                Write-Host "[!] VS Code nicht gefunden. Öffne Standard-Editor..." -ForegroundColor Yellow
                Invoke-Item $res
            }
        }

        Write-Host "Warte auf Hotkey (STRG+UMSCHALT+C)...`n" -ForegroundColor Gray
    }

    Start-Sleep -Milliseconds 150
}