# Idle-Mouse‑Move
## About
Windows PowerShell auto‑mouse‑move script, used to avoid system determining long‑time idle.
- ✅ Reciprocating mouse movement: offset left specified pixels, wait for a period of time then move back, loop execution
- ✅ Built‑in real system anti‑sleep API, prevent system sleep and monitor auto‑off
- ✅ Pure local run, no network required, call Windows API to implement cursor control and power management
- ✅ Two versions: Release version (no disk log), Debug version (output coordinate logs for troubleshooting)

> ⚠️ Important Notice
> Both scripts use relative displacement logic, **do not lock mouse baseline coordinate captured when script starts**.
> If you manually move mouse during running, or tiny system mouse jitter occurs, cursor position will drift gradually.

> ⚠️ Environment Limitations
> Virtual machines and some remote desktop sessions will intercept `SetCursorPos` API, mouse cannot move; security software may block script calling Windows system interfaces.
> On some devices, only mouse movement works and cannot prevent monitor from turning off,It may also be related to the system power policy.

## File List
### `mouse_move.ps1` - **【Main Script｜Release Version】**
- Purpose: Daily idle usage, only console output, **will not write log files to disk**
- Features: Reciprocating mouse movement + enable system sleep prevention (`SetThreadExecutionState`)
- Matching launcher: `run_mouse_move.bat`

### `run_test.ps1` - **【Debug Script｜For Troubleshooting】**
- Purpose: Issue diagnosis and debugging, generate `mouse_log.txt` under script directory to record mouse coordinates of each loop
- Features: Reciprocating mouse movement + enable system sleep prevention + disk log recording
- Notice: Continuously write logs to disk, **not suitable for long‑time idle running**
- Matching launcher: `run_test.bat`

### `run_mouse_move.bat`
Release batch launcher, double‑click to run main script `mouse_move.ps1`.
> The prompt `Keep screen awake` inside batch matches actual script behavior, sleep‑prevention is enabled inside script.
Stop method: Press `Ctrl+C` in console window, or close console window directly.

### `run_test.bat`
Debug batch launcher, run debug script, generate log file and enable sleep prevention.

### `mouse_log.txt`
> **Only generated when running `run_test.ps1`. Release main script will NOT produce this file.**
> Contains timestamp, loop counter, mouse coordinates before and after movement; file uses append‑write mode, old logs will not be overwritten automatically.

## Usage
### Method 1: Double‑click to launch (Recommended)
1. Daily idle: double‑click `run_mouse_move.bat`
2. Need debug logs for troubleshooting: double‑click `run_test.bat`
3. Terminate script: press `Ctrl+C`, or close console window

### Method 2: Run manually via command‑line
```cmd
:: Run release main script
cd script‑folder
run_mouse_move.bat

:: Run debug script
run_test.bat
```

### Method 3: Execute PowerShell script directly
```powershell
# Release version
powershell -NoProfile -ExecutionPolicy Bypass -File mouse_move.ps1

# Debug version
powershell -NoProfile -ExecutionPolicy Bypass -File run_test.ps1
```

## Parameter Configuration
Edit corresponding ps1 file to modify parameters:

**mouse_move.ps1 (Release Version)**
```powershell
$moveAmount = 50        # Pixel distance for single movement
$leftMoveTime = 5000    # Milliseconds to wait after moving left
$rightMoveTime = 5000   # Milliseconds to wait after moving back
```

**run_test.ps1 (Debug Version)**
```powershell
$moveAmount = 50        # Pixel distance for single movement
$leftTime = 5000        # Milliseconds to wait after moving left
$rightTime = 5000       # Milliseconds to wait after moving back
```

## FAQ
### Q1: Mouse does not move at all?
A: Troubleshoot item by item:
1. Whether running in virtual machine / remote desktop environment, which intercepts `SetCursorPos`;
2. Security software blocks script calling Windows mouse API;
3. Use debug script `run_test.bat`, check `mouse_log.txt` to judge whether script runs normally.

### Q2: Monitor still turns off after script started?
A: `SetThreadExecutionState` only works for current script process; system power policy restores after closing script. Some third‑party power‑management software may override effect of this API.

### Q3: Cannot find mouse_log.txt?
A: Log file **is only output by debug script run_test.ps1**, release main script will not generate logs.

### Q4: Mouse position drifts gradually after running for a while?
A: Script uses relative displacement logic without locking initial origin. Try not to move mouse manually while script is running.

## Technical Details
1. Cursor control API: `SetCursorPos`, `GetCursorPos` from user32.dll
2. Sleep‑prevention implementation: `SetThreadExecutionState` from kernel32.dll
    - Flags: `ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED`
    - Effect: Prevent system sleep and monitor auto‑off; automatically invalid after process exits.

## Disclaimer
This script is for learning and testing only. You shall bear all risks for any consequences caused by using this script, including but not limited to system exception, abnormal mouse behavior. Do not use for game AFK, some games detect simulated input behavior.

## Author & AI Generation Notice
- Initial code draft generated by **GLM‑4.7‑Flash**;
- README.md, description, .gitignore and partial code review processed by **Doubao**;
- Additional code review done by **dot‑idk‑dot** and **LLLyyy‑star** for testing
- Version: 1.0
- Last modified: 2026‑11‑18(YYYY-MM-DD)