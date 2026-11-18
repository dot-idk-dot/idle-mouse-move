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

    public static void PreventSleep() {
        SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
    }
}
"@

Power::PreventSleep()
Write-Host "System sleep prevention: Enabled" -ForegroundColor Green

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

# Helper function to get current position
function Get-MousePosition {
    $point = New-Object Mouse+POINT
    [Mouse]::GetCursorPos([ref]$point)
    return $point
}

# Helper function to move mouse
function Set-MousePosition {
    param([int]$X, [int]$Y)
    [Mouse]::SetCursorPos($X, $Y)
    Start-Sleep -Milliseconds 50  # Brief pause to ensure movement registers
    return $true
}

Write-Host "Initial move left 50px..." -ForegroundColor Yellow

# Initial move left
$point = Get-MousePosition
Write-Host "Current position: X=$($point.X), Y=$($point.Y)" -ForegroundColor White
Set-MousePosition -X ($point.X - $moveAmount) -Y $point.Y

# Wait 5 seconds
Start-Sleep -Milliseconds $leftMoveTime

Write-Host "Move right 50px..." -ForegroundColor Yellow

# Move right
$point = Get-MousePosition
Write-Host "Current position: X=$($point.X), Y=$($point.Y)" -ForegroundColor White
Set-MousePosition -X ($point.X + $moveAmount) -Y $point.Y

# Wait 5 seconds
Start-Sleep -Milliseconds $rightMoveTime

Write-Host "Starting loop..." -ForegroundColor Cyan
Write-Host "Left move 50px..." -ForegroundColor Yellow

# Loop movement
$loopCount = 0
while ($true) {
    $loopCount++

    # Move left 50px
    Write-Host "[$loopCount] Move left 50px..." -ForegroundColor Yellow

    $point = Get-MousePosition
    $newX = $point.X - $moveAmount
    Write-Host "  Current: X=$($point.X) -> New: X=$newX" -ForegroundColor White
    Set-MousePosition -X $newX -Y $point.Y

    # Wait 5 seconds
    Write-Host "  Waiting 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Milliseconds $leftMoveTime

    # Move right 50px
    Write-Host "[$loopCount] Move right 50px..." -ForegroundColor Yellow

    $point = Get-MousePosition
    $newX = $point.X + $moveAmount
    Write-Host "  Current: X=$($point.X) -> New: X=$newX" -ForegroundColor White
    Set-MousePosition -X $newX -Y $point.Y

    # Wait 5 seconds
    Write-Host "  Waiting 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Milliseconds $rightMoveTime
}
