#pragma once

#include <windows.h>
#include <string>
#include <iostream>

// Runtime loader for C8855-01api.dll. This avoids needing C8855-01api.lib.
struct C8855Api {
    HMODULE dll = nullptr;

    using Open_t = HANDLE (__cdecl *)(void);
    using MOpen_t = BOOL (__cdecl *)(BYTE, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*, HANDLE*);
    using Close_t = BOOL (__cdecl *)(HANDLE);
    using Reset_t = BOOL (__cdecl *)(HANDLE);
    using CountStart_t = BOOL (__cdecl *)(HANDLE, BYTE);
    using CountStop_t = BOOL (__cdecl *)(HANDLE);
    using Setup_t = BOOL (__cdecl *)(HANDLE, BYTE, BYTE, WORD);
    using ReadData_t = BOOL (__cdecl *)(HANDLE, DWORD*, BYTE*);
    using SetPmtPower_t = BOOL (__cdecl *)(HANDLE, BYTE);
    using WritePort_t = BOOL (__cdecl *)(HANDLE, BYTE);
    using ReadId_t = BOOL (__cdecl *)(HANDLE, BYTE*);
    using SetupEx_t = BOOL (__cdecl *)(HANDLE, BYTE, BYTE, WORD, BYTE);

    Open_t Open = nullptr;
    MOpen_t MOpen = nullptr;
    Close_t Close = nullptr;
    Reset_t Reset = nullptr;
    CountStart_t CountStart = nullptr;
    CountStop_t CountStop = nullptr;
    Setup_t Setup = nullptr;
    ReadData_t ReadData = nullptr;
    SetPmtPower_t SetPmtPower = nullptr;
    WritePort_t WritePort = nullptr;
    ReadId_t ReadId = nullptr;
    SetupEx_t SetupEx = nullptr;

    ~C8855Api() { unload(); }

    bool load(const std::string& path) {
        unload();
        dll = LoadLibraryA(path.c_str());
        if (!dll) {
            std::cerr << "LoadLibrary failed for '" << path << "'.\n"
                      << "Put C8855-01api.dll next to the executable, pass --dll <path>, or add it to PATH.\n"
                      << "Windows error code: " << GetLastError() << "\n";
            return false;
        }

        bool ok = true;
        ok &= load_one(Open, "C8855Open");
        ok &= load_one(MOpen, "C8855MOpen");
        ok &= load_one(Close, "C8855Close");
        ok &= load_one(Reset, "C8855Reset");
        ok &= load_one(CountStart, "C8855CountStart");
        ok &= load_one(CountStop, "C8855CountStop");
        ok &= load_one(Setup, "C8855Setup");
        ok &= load_one(ReadData, "C8855ReadData");
        ok &= load_one(SetPmtPower, "C8855SetPmtPower");
        ok &= load_one(WritePort, "C8855WritePort");
        ok &= load_one(ReadId, "C8855ReadId");
        ok &= load_one(SetupEx, "C8855SetupEx");

        if (!ok) {
            std::cerr << "One or more C8855 API functions are missing from the DLL.\n";
            unload();
        }
        return ok;
    }

    void unload() {
        Open = nullptr; MOpen = nullptr; Close = nullptr; Reset = nullptr;
        CountStart = nullptr; CountStop = nullptr; Setup = nullptr; ReadData = nullptr;
        SetPmtPower = nullptr; WritePort = nullptr; ReadId = nullptr; SetupEx = nullptr;
        if (dll) {
            FreeLibrary(dll);
            dll = nullptr;
        }
    }

private:
    template <typename T>
    bool load_one(T& fn, const char* name) {
        FARPROC p = GetProcAddress(dll, name);
        if (!p) {
            std::cerr << "GetProcAddress failed for " << name << ", Windows error code: " << GetLastError() << "\n";
            fn = nullptr;
            return false;
        }
        fn = reinterpret_cast<T>(p);
        return true;
    }
};
