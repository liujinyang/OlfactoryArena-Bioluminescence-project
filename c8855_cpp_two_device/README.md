# C8855-01 dual-device acquisition, dynamic DLL-loading version

This C++ console example controls two Hamamatsu C8855-01 devices with ID switches set to `0` and `1`.
It opens all detected units with `C8855MOpen`, reads each unit ID with `C8855ReadId`, maps handles by actual ID, acquires both channels, and writes one CSV file.

This version **does not require `C8855-01api.lib`**. It loads `C8855-01api.dll` at runtime using `LoadLibraryA` and `GetProcAddress`.

## Requirements

- Windows 10/11
- Visual Studio 2022 C++ build tools or CMake + MSVC
- `C8855-01api.dll`
- the Hamamatsu device driver installed
- two C8855-01 units with ID switches set to 0 and 1

Place `C8855-01api.dll` next to the built EXE, put it on `PATH`, or pass its full path with `--dll`.

## Build with Visual Studio

Open `c8855_dual_acquire.sln`, select `Release|x64`, and build.

## Build with CMake

```bat
build_vs2022_x64.bat
```

## Run examples

Basic software-trigger acquisition:

```bat
c8855_dual_acquire.exe --csv dual.csv --gate 1ms --points 100 --batches 100
```

Specify DLL path explicitly:

```bat
c8855_dual_acquire.exe --dll C:\Hamamatsu\C8855-01api.dll --csv dual.csv --gate 1ms --points 100 --batches 100
```

Continuous run until Ctrl+C:

```bat
c8855_dual_acquire.exe --csv dual.csv --gate 1ms --points 100 --batches -1
```

External trigger using SetupEx:

```bat
c8855_dual_acquire.exe --csv dual.csv --gate 1ms --points 100 --batches 100 --trigger external --setupex --edge fall
```

## TCP server mode

Run the acquisition program as a localhost TCP server:

```bat
c8855_dual_acquire.exe --tcp-server --tcp-port 55000 --gate 10ms --points auto --trigger external --setupex --edge rise
```

The server accepts newline-terminated text commands and replies with `OK ...` or `ERR ...`.

Supported commands:

```text
PING
STATUS
SETDATADIR D:\path\to\experiment_folder
SETCSVNAME section_01.csv
START
STOP
PMT_ON
PMT_OFF
SHUTDOWN
```

`SETDATADIR` changes the output folder for the next run. `SETCSVNAME` changes the output filename for the next run. In server mode the PMT CSV filename defaults to `dual.csv`, so the file written is:

```text
<data_dir>\dual.csv
```

MATLAB can talk to the server with the helper class in [yoshi_RGB/C8855TcpClient.m](../yoshi_RGB/C8855TcpClient.m).

`PMT_ON` and `PMT_OFF` are intended for idle/manual control. They are rejected while acquisition is running. `STOP` still stops acquisition and turns the PMTs off.

## CSV format

```text
batch,index,time_s,ch0_count,ch1_count
```

`ch0_count` is the device whose ID switch returned 0. `ch1_count` is the device whose ID switch returned 1.

## MATLAB plotting

```matlab
plot_c8855_dual_csv('dual.csv')
live_plot_c8855_dual_csv('dual.csv', 0.5)
```

## Notes

- This program intentionally does not assume that the handle order returned by `C8855MOpen` matches the ID switch order.
- Only this EXE should own the two C8855 devices while it is running.
- For short gate times, use a larger `--points` value so USB transfer can keep up.
