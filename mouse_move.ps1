# Mouse Auto-Move Script with Sleep Prevention
# Moves mouse left 50px every 5 seconds, then right 50px every 5 seconds

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);

    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;

    public static uint PreventSleep() {
        // Set all three flags: ES_CONTINUOUS, ES_SYSTEM_REQUIRED, ES_DISPLAY_REQUIRED
        // ES_CONTINUOUS: Continue setting execution state
        // ES_SYSTEM_REQUIRED: Prevent system entering sleep mode
        // ES_DISPLAY_REQUIRED: Prevent display from going into low-power state
        uint result = SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
        return result;
    }

    public static void ResetSleepState() {
        // Clear all sleep prevention flags
        SetThreadExecutionState(ES_CONTINUOUS);
    }
}
"@

# Prevent system sleep using SetThreadExecutionState
Write-Host "Setting sleep prevention flags..." -ForegroundColor Yellow
$result = [Power]::PreventSleep()

if ($result -eq 0) {
    Write-Host "ERROR: SetThreadExecutionState failed! Return value: $result" -ForegroundColor Red
    Write-Host "This usually means the script is not running with Administrator privileges." -ForegroundColor Red
    Write-Host "Please run as Administrator: Right-click PowerShell -> 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "SUCCESS: Sleep prevention enabled (Return value: $result)" -ForegroundColor Green
    Write-Host "Flags set: ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED" -ForegroundColor Cyan
}

# Disable unattended sleep timeout (Windows 10/11 has 2-minute default)
Write-Host "Disabling unattended sleep timeout..." -ForegroundColor Yellow
$dcTimeout = 0
$acTimeout = 0

try {
    $dcOutput = powercfg /getactivevalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>&1 | Out-String
    if ($dcOutput -match "(\d+)") { $dcTimeout = [int]$matches[1] }
} catch {}

try {
    $acOutput = powercfg /getactivevalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>&1 | Out-String
    if ($acOutput -match "(\d+)") { $acTimeout = [int]$matches[1] }
} catch {}

Write-Host "Current settings: DC timeout=$dcTimeout sec, AC timeout=$acTimeout sec" -ForegroundColor Gray

# Use correct alias: STANDBYIDLE (not DCINDEX/ACINDEX)
$null = Start-Process -FilePath "powercfg" -ArgumentList "/setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0" -Wait -NoNewWindow
$null = Start-Process -FilePath "powercfg" -ArgumentList "/setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 0" -Wait -NoNewWindow
Write-Host "Unattended sleep timeout disabled" -ForegroundColor Green

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

$moveAmount = 50
$leftMoveTime = 5000
$rightMoveTime = 5000

Write-Host "Mouse auto-move script started..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Cyan

function Get-MousePosition {
    $point = New-Object Mouse+POINT
    [Mouse]::GetCursorPos([ref]$point)
    return $point
}

function Set-MousePosition {
    param([int]$X, [int]$Y)
    [Mouse]::SetCursorPos($X, $Y)
    Start-Sleep -Milliseconds 50  # Brief pause to ensure movement registers
    return $true
}

$loopCount = 0
while ($true) {
    $loopCount++

    # Move left 50px
    Write-Host "[$loopCount] Left: X=$($point.X) -> $($point.X - $moveAmount)" -ForegroundColor Yellow

    $point = Get-MousePosition
    $newX = $point.X - $moveAmount
    Write-Host "  Current: X=$($point.X) -> New: X=$newX" -ForegroundColor White
    Set-MousePosition -X $newX -Y $point.Y

    # Wait 5 seconds
    Write-Host "  Waiting 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Milliseconds $leftMoveTime

    # Move right 50px
    Write-Host "[$loopCount] Right: X=$($point.X) -> $($point.X + $moveAmount)" -ForegroundColor Yellow

    $point = Get-MousePosition
    $newX = $point.X + $moveAmount
    Write-Host "  Current: X=$($point.X) -> New: X=$newX" -ForegroundColor White
    Set-MousePosition -X $newX -Y $point.Y

    # Wait 5 seconds
    Write-Host "  Waiting 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Milliseconds $rightMoveTime
}

# Restore original power settings on exit
trap {
    Write-Host "`n" -NoNewline
    Write-Host "Restoring original power settings..." -ForegroundColor Yellow

    if ($dcTimeout -ne 0) {
        $null = Start-Process -FilePath "powercfg" -ArgumentList "/setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $dcTimeout" -Wait -NoNewWindow
        Write-Host "Restored DC timeout to $dcTimeout seconds" -ForegroundColor Cyan
    }

    if ($acTimeout -ne 0) {
        $null = Start-Process -FilePath "powercfg" -ArgumentList "/setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $acTimeout" -Wait -NoNewWindow
        Write-Host "Restored AC timeout to $acTimeout seconds" -ForegroundColor Cyan
    }

    Write-Host "Done! Press any key to exit..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    [Power]::ResetSleepState()
    exit
}