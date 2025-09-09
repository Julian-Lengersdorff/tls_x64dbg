# TLS Secret Tracking for x64dbg

A debugging script that tracks TLS secrets from the Windows LSASS process using x64dbg. This tool intercepts the `derive_secret` function in the `ncryptsslp` module to capture and log TLS handshake secrets, enabling TLS secret material availability analysis. 


## 📋 Prerequisites

### Required Software
- **x64dbg**: Windows x64 debugger ([Download](https://x64dbg.com/))
- **Administrative Privileges**: Required to attach to LSASS process
- **Windows 11**: Target system with TLS 1.3 support

### Required Plugin
- **LogToCSV Plugin**: Custom x64dbg plugin for CSV export
  - Repository: https://github.com/Julian-Lengersdorff/logToCSV
  - Pre-built binary: `LogToCSV.dp64`

## 🚀 Installation & Setup

### 1. Install x64dbg Plugin

```bash
# Copy the plugin to your x64dbg plugins directory
copy LogToCSV.dp64 "C:\Path_To_x64dbg\release\x64\plugins\"
```


### 2. Configure Paths

Edit `run.bat` and update the x64dbg path:
```batch
set X64DBG_PATH="C:\Your_x64dbg_Path\release\x64\x64dbg.exe"
```

### 3. Verify Setup

Ensure the following files are in place:
- `script.txt` - Main debugging script
- `run.bat` - Automated launcher
- `LogToCSV.dp64` - Plugin in x64dbg plugins folder

## 🎮 Usage

### Automated Method (Not Available)

1. **Run as Administrator**:
   ```cmd
   # Right-click run.bat and select "Run as administrator"
   run.bat
   ```

2. **Wait for Attachment**: The script will:
   - Find the LSASS process PID
   - Launch x64dbg with elevated privileges
   - Automatically load the debugging script

### Manual Method (If Batch Fails)

If the automated batch file doesn't work completely:

1. **Launch x64dbg as Administrator**
2. **Attach to LSASS Process**:
   - File → Attach → Select `lsass.exe`
3. **Load Script**:
   - Script → Load Script → Select `script.txt`
4. **Control Execution**:
   - Pause debugger (`F12`)
   - Run script (`Ctrl+F5`)
   - Resume debugger (`F9`)

## 🔧 How It Works

### 1. Pattern Recognition
The script searches for a specific byte pattern in the `ncryptsslp` module to locate the `derive_secret` function:
```assembly
48 8B C4 44 88 48 20 4C 89 40 18 48 89 50 10 53 56 41 54 41 55 41 56 41 57...
```

### 2. Secret Interception
- Sets breakpoints on function entry and exit
- Captures secret labels (client/server handshake, application data)
- Extracts secret data from nested data structures

### 3. Memory Monitoring
- Places hardware watchpoints on secret memory locations
- Logs secret access with precise timestamps
- Tracks secret lifecycle and usage patterns

### 4. Data Structure Navigation
The script navigates through Windows TLS internal structures:
```
mybdd → struct_3lss → struct_RUUU → struct_YKSM → secret_data
```

## 📊 Output Format

The tool generates CSV logs with the following information:
- **Secret Type**: Client/Server Handshake or Application secrets
- **Secret Size**: Length of the secret data
- **Timestamp**: Microsecond precision timing
- **Secret Data**: Hexadecimal representation of the secret

## ⚠️ Important Notes

### Troubleshooting
If you encounter errors attaching to LSASS, you may need to temporarily disable process protection:

**Disable LSASS Protection (Windows 11):**
1. Open Windows Security → Device Security → Core Isolation.
2. Turn off "Memory Integrity" and restart your computer.
3. Try attaching to LSASS again.

**Warning:** Disabling protection reduces system security. Re-enable after debugging.

### Registry Modification

In some cases, you may need to disable LSASS protection via the Windows Registry:

**Disable LSASS Protection (Registry):**
1. Open `regedit.exe` as Administrator.
2. Navigate to:  
    ```
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa
    ```
3. Set the value of `RunAsPPL` to `0`.
4. Restart your computer.

**Note:** Modifying the registry can affect system security and stability. Always back up your registry before making changes.

