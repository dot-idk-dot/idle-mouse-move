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
        uint result = SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
        return result;
    }
}
"@

Write-Host "Testing SetThreadExecutionState..." -ForegroundColor Yellow
$result = [Power]::PreventSleep()
Write-Host "Return value: $result" -ForegroundColor Cyan

if ($result -eq 0) {
    Write-Host "ERROR: SetThreadExecutionState failed!" -ForegroundColor Red
    Write-Host "You need Administrator privileges!" -ForegroundColor Red
} else {
    Write-Host "SUCCESS: Sleep prevention enabled (Return value: $result)" -ForegroundColor Green
    Write-Host "Flags: ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED" -ForegroundColor Green
}
