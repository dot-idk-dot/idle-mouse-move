# Mouse Auto-Move Script with Logging

$moveAmount = 50
$leftTime = 5000
$rightTime = 5000
$logFile = "$PSScriptRoot\mouse_log.txt"

# Create log file
"Mouse Auto-Move Script Started" | Out-File -FilePath $logFile -Encoding UTF8
"Log file: $logFile" | Out-File -FilePath $logFile -Encoding UTF8 -Append
"========================================" | Out-File -FilePath $logFile -Encoding UTF8 -Append
"" | Out-File -FilePath $logFile -Encoding UTF8 -Append

# Prevent system sleep using SetThreadExecutionState
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);

    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;

    public static void PreventSleep() {
        SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
    }
}
"@

Write-Host "System sleep prevention: Enabled" -ForegroundColor Green

# Mouse movement
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Mouse {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int X;
        public int Y;
    }
}
"@

function Get-MousePosition {
    $point = New-Object Mouse+POINT
    [Mouse]::GetCursorPos([ref]$point)
    return $point
}

function Set-MousePosition {
    param([int]$X, [int]$Y)
    [Mouse]::SetCursorPos($X, $Y)
    Start-Sleep -Milliseconds 50
}

Write-Host "Mouse movement started (infinite loop)..." -ForegroundColor Green
"Mouse movement started (no sleep prevention): infinite loop" | Out-File -FilePath $logFile -Encoding UTF8 -Append

$i = 0
while ($true) {
    $i++
    $p = Get-MousePosition
    $logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Write-Host "[$i] Left: X=$($p.X) -> $($p.X - $moveAmount)" -ForegroundColor Yellow
    Write-Host "[$i] Right: X=$($p.X) -> $($p.X + $moveAmount)" -ForegroundColor Yellow

    "[$logTime] Loop #$i - Left move: $($p.X) -> $($p.X - $moveAmount)" | Out-File -FilePath $logFile -Encoding UTF8 -Append
    "[$logTime] Loop #$i - Right move: $($p.X) -> $($p.X + $moveAmount)" | Out-File -FilePath $logFile -Encoding UTF8 -Append

    Set-MousePosition -X ($p.X - $moveAmount) -Y $p.Y
    Start-Sleep -Milliseconds $leftTime

    $p = Get-MousePosition
    "[$logTime] Loop #$i - Left finished, current: $($p.X)" | Out-File -FilePath $logFile -Encoding UTF8 -Append

    Set-MousePosition -X ($p.X + $moveAmount) -Y $p.Y
    Start-Sleep -Milliseconds $rightTime
}
