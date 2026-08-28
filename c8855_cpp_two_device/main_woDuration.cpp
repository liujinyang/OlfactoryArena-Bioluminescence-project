
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <atomic>
#include <csignal>
#include <chrono>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <vector>
#include <algorithm>

#include "C8855-01api.h"
#include "c8855_dynamic_api.h"

struct Options {
    std::string csv_path = "c8855_dual_data.csv";
    BYTE gate_time = C8855_GATETIME_1MS;
    WORD points_per_batch = 100;
    int batches = 100;
    BYTE trigger_mode = C8855_SOFTWARE_TRIGGER;
    BYTE trigger_edge = C8855_SET_FALL_EDGE;
    bool use_setup_ex = false;
    bool pmt_on = false;
    int poll_ms = 0;
    std::string dll_path = "C8855-01api.dll";
};

struct DevicePair {
    HANDLE id0 = INVALID_HANDLE_VALUE;
    HANDLE id1 = INVALID_HANDLE_VALUE;
};

static std::atomic<bool> g_stop{false};
static void on_signal(int) { g_stop = true; }

static std::string upper_copy(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c){ return (char)std::toupper(c); });
    return s;
}

static bool parse_gate_time(const std::string& text, BYTE& out) {
    const std::string t = upper_copy(text);
    if (t == "50US") out = C8855_GATETIME_50US;
    else if (t == "100US") out = C8855_GATETIME_100US;
    else if (t == "200US") out = C8855_GATETIME_200US;
    else if (t == "500US") out = C8855_GATETIME_500US;
    else if (t == "1MS") out = C8855_GATETIME_1MS;
    else if (t == "2MS") out = C8855_GATETIME_2MS;
    else if (t == "5MS") out = C8855_GATETIME_5MS;
    else if (t == "10MS") out = C8855_GATETIME_10MS;
    else if (t == "20MS") out = C8855_GATETIME_20MS;
    else if (t == "50MS") out = C8855_GATETIME_50MS;
    else if (t == "100MS") out = C8855_GATETIME_100MS;
    else if (t == "200MS") out = C8855_GATETIME_200MS;
    else if (t == "500MS") out = C8855_GATETIME_500MS;
    else if (t == "1S") out = C8855_GATETIME_1S;
    else if (t == "2S") out = C8855_GATETIME_2S;
    else if (t == "5S") out = C8855_GATETIME_5S;
    else if (t == "10S") out = C8855_GATETIME_10S;
    else return false;
    return true;
}

static double gate_time_seconds(BYTE gate_time) {
    switch (gate_time) {
        case C8855_GATETIME_50US: return 50e-6;
        case C8855_GATETIME_100US: return 100e-6;
        case C8855_GATETIME_200US: return 200e-6;
        case C8855_GATETIME_500US: return 500e-6;
        case C8855_GATETIME_1MS: return 1e-3;
        case C8855_GATETIME_2MS: return 2e-3;
        case C8855_GATETIME_5MS: return 5e-3;
        case C8855_GATETIME_10MS: return 10e-3;
        case C8855_GATETIME_20MS: return 20e-3;
        case C8855_GATETIME_50MS: return 50e-3;
        case C8855_GATETIME_100MS: return 100e-3;
        case C8855_GATETIME_200MS: return 200e-3;
        case C8855_GATETIME_500MS: return 500e-3;
        case C8855_GATETIME_1S: return 1.0;
        case C8855_GATETIME_2S: return 2.0;
        case C8855_GATETIME_5S: return 5.0;
        case C8855_GATETIME_10S: return 10.0;
        default: return 0.0;
    }
}

static void print_usage() {
    std::cout
        << "Usage: c8855_dual_acquire.exe [options]\n"
        << "  --csv <path>            Output CSV path (default: c8855_dual_data.csv)\n"
        << "  --gate <50us|100us|...|10s>\n"
        << "  --points <1..512>       Samples per batch (default: 100)\n"
        << "  --batches <n|-1>        Number of batches, -1 for continuous (default: 100)\n"
        << "  --trigger <software|external>\n"
        << "  --edge <fall|rise>      External-trigger edge, used with --setupex\n"
        << "  --setupex               Use C8855SetupEx instead of C8855Setup\n"
        << "  --pmt-on                Enable PMT power on both devices\n"
        << "  --poll-ms <n>           Sleep between batches (default: 0)\n"
        << "  --dll <path>            Path to C8855-01api.dll (default: search next to EXE/PATH)\n"
        << "  --help                  Show this message\n";
}

static bool parse_args(int argc, char** argv, Options& opt) {
    for (int i = 1; i < argc; ++i) {
        std::string a = argv[i];
        if (a == "--help" || a == "-h") {
            print_usage();
            return false;
        } else if (a == "--csv" && i + 1 < argc) {
            opt.csv_path = argv[++i];
        } else if (a == "--gate" && i + 1 < argc) {
            if (!parse_gate_time(argv[++i], opt.gate_time)) {
                std::cerr << "Unknown gate time.\n";
                return false;
            }
        } else if (a == "--points" && i + 1 < argc) {
            int n = std::stoi(argv[++i]);
            if (n < 1 || n > 512) {
                std::cerr << "--points must be in [1, 512].\n";
                return false;
            }
            opt.points_per_batch = static_cast<WORD>(n);
        } else if (a == "--batches" && i + 1 < argc) {
            opt.batches = std::stoi(argv[++i]);
            if (opt.batches == 0 || opt.batches < -1) {
                std::cerr << "--batches must be positive or -1.\n";
                return false;
            }
        } else if (a == "--trigger" && i + 1 < argc) {
            std::string t = upper_copy(argv[++i]);
            if (t == "SOFTWARE") opt.trigger_mode = C8855_SOFTWARE_TRIGGER;
            else if (t == "EXTERNAL") opt.trigger_mode = C8855_EXTERNAL_TRIGGER;
            else {
                std::cerr << "--trigger must be software or external.\n";
                return false;
            }
        } else if (a == "--edge" && i + 1 < argc) {
            std::string e = upper_copy(argv[++i]);
            if (e == "FALL") opt.trigger_edge = C8855_SET_FALL_EDGE;
            else if (e == "RISE") opt.trigger_edge = C8855_SET_RISE_EDGE;
            else {
                std::cerr << "--edge must be fall or rise.\n";
                return false;
            }
        } else if (a == "--setupex") {
            opt.use_setup_ex = true;
        } else if (a == "--pmt-on") {
            opt.pmt_on = true;
        } else if (a == "--poll-ms" && i + 1 < argc) {
            opt.poll_ms = std::stoi(argv[++i]);
            if (opt.poll_ms < 0) opt.poll_ms = 0;
        } else if (a == "--dll" && i + 1 < argc) {
            opt.dll_path = argv[++i];
        } else {
            std::cerr << "Unknown argument: " << a << "\n";
            return false;
        }
    }
    return true;
}

static bool open_two_devices_by_id(C8855Api& api, DevicePair& pair) {
    HANDLE h[16];
    for (auto &x : h) x = INVALID_HANDLE_VALUE;

    if (!api.MOpen(16,
        &h[0], &h[1], &h[2], &h[3], &h[4], &h[5], &h[6], &h[7],
        &h[8], &h[9], &h[10], &h[11], &h[12], &h[13], &h[14], &h[15])) {
        std::cerr << "C8855MOpen failed.\n";
        return false;
    }

    int found = 0;
    for (int i = 0; i < 16; ++i) {
        if (h[i] == INVALID_HANDLE_VALUE) continue;
        ++found;
        BYTE id = 255;
        if (!api.ReadId(h[i], &id)) {
            std::cerr << "C8855ReadId failed for handle index " << i << "\n";
            continue;
        }
        std::cout << "Detected handle[" << i << "] with device ID " << static_cast<int>(id) << "\n";
        if (id == 0) pair.id0 = h[i];
        else if (id == 1) pair.id1 = h[i];
    }

    if (found < 2) {
        std::cerr << "Expected at least 2 connected devices, found " << found << "\n";
        return false;
    }
    if (pair.id0 == INVALID_HANDLE_VALUE || pair.id1 == INVALID_HANDLE_VALUE) {
        std::cerr << "Could not map both device IDs 0 and 1.\n";
        return false;
    }
    return true;
}

static void close_if_valid(C8855Api& api, HANDLE h) {
    if (h != INVALID_HANDLE_VALUE) api.Close(h);
}

static bool reset_and_configure(C8855Api& api, HANDLE h, const Options& opt) {
    if (!api.Reset(h)) {
        std::cerr << "C8855Reset failed.\n";
        return false;
    }
    if (opt.pmt_on && !api.SetPmtPower(h, C8855_PMT_POWER_ON)) {
        std::cerr << "C8855SetPmtPower(ON) failed.\n";
        return false;
    }
    if (opt.use_setup_ex) {
        if (!api.SetupEx(h, opt.gate_time, C8855_BLOCK_TRANSFER, opt.points_per_batch, opt.trigger_edge)) {
            std::cerr << "C8855SetupEx failed.\n";
            return false;
        }
    } else {
        if (!api.Setup(h, opt.gate_time, C8855_BLOCK_TRANSFER, opt.points_per_batch)) {
            std::cerr << "C8855Setup failed.\n";
            return false;
        }
    }
    return true;
}

static bool acquire_batch(C8855Api& api, HANDLE h0, HANDLE h1, const Options& opt,
                          std::vector<DWORD>& d0, BYTE& r0,
                          std::vector<DWORD>& d1, BYTE& r1) {
    d0.assign(opt.points_per_batch, 0);
    d1.assign(opt.points_per_batch, 0);
    r0 = 255;
    r1 = 255;

    if (!api.CountStart(h0, opt.trigger_mode)) {
        std::cerr << "C8855CountStart failed for ID0.\n";
        return false;
    }
    if (!api.CountStart(h1, opt.trigger_mode)) {
        std::cerr << "C8855CountStart failed for ID1.\n";
        api.CountStop(h0);
        return false;
    }

    bool ok0 = (api.ReadData(h0, d0.data(), &r0) == TRUE);
    bool ok1 = (api.ReadData(h1, d1.data(), &r1) == TRUE);
    bool stop0 = (api.CountStop(h0) == TRUE);
    bool stop1 = (api.CountStop(h1) == TRUE);

    if (!ok0 || !ok1 || !stop0 || !stop1) {
        std::cerr << "Read or stop failed. ok0=" << ok0 << " ok1=" << ok1
                  << " stop0=" << stop0 << " stop1=" << stop1 << "\n";
        return false;
    }
    if (r0 == C8855_ERROR_TRANSFER || r1 == C8855_ERROR_TRANSFER) {
        std::cerr << "Transfer error reported by device. r0=" << (int)r0 << " r1=" << (int)r1 << "\n";
        return false;
    }
    return true;
}

int main(int argc, char** argv) {
    std::signal(SIGINT, on_signal);

    Options opt;
    if (!parse_args(argc, argv, opt)) return 1;

    C8855Api api;
    if (!api.load(opt.dll_path)) return 10;

    std::ofstream csv(opt.csv_path, std::ios::out | std::ios::trunc);
    if (!csv) {
        std::cerr << "Failed to open CSV file: " << opt.csv_path << "\n";
        return 1;
    }
    csv << "batch,index,time_s,ch0_count,ch1_count\n";
    csv.flush();

    DevicePair pair;
    if (!open_two_devices_by_id(api, pair)) {
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        return 2;
    }
    if (!reset_and_configure(api, pair.id0, opt) || !reset_and_configure(api, pair.id1, opt)) {
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        return 3;
    }

    std::cout << "Mapped device IDs 0 and 1 successfully. Writing to " << opt.csv_path << "\n";
    std::cout << "Gate time = " << gate_time_seconds(opt.gate_time) << " s, points/batch = " << opt.points_per_batch << "\n";

    const double dt = gate_time_seconds(opt.gate_time);
    int batch = 0;
    const bool continuous = (opt.batches < 0);

    while (!g_stop && (continuous || batch < opt.batches)) {
        std::vector<DWORD> d0, d1;
        BYTE r0 = 255, r1 = 255;
        if (!acquire_batch(api, pair.id0, pair.id1, opt, d0, r0, d1, r1)) {
            std::cerr << "Acquisition failed on batch " << batch << "\n";
            break;
        }
        for (WORD i = 0; i < opt.points_per_batch; ++i) {
            double t = (batch * static_cast<int>(opt.points_per_batch) + i) * dt;
            csv << batch << ',' << i << ',' << std::fixed << std::setprecision(9) << t << ',' << d0[i] << ',' << d1[i] << '\n';
        }
        csv.flush();
        std::cout << "Batch " << batch << " complete. first[ch0,ch1]=[" << d0.front() << ',' << d1.front()
                  << "] last[ch0,ch1]=[" << d0.back() << ',' << d1.back() << "]\n";
        ++batch;
        if (opt.poll_ms > 0) std::this_thread::sleep_for(std::chrono::milliseconds(opt.poll_ms));
    }

    if (opt.pmt_on) {
        api.SetPmtPower(pair.id0, C8855_PMT_POWER_OFF);
        api.SetPmtPower(pair.id1, C8855_PMT_POWER_OFF);
    }
    api.WritePort(pair.id0, 0);
    api.WritePort(pair.id1, 0);
    close_if_valid(api, pair.id0);
    close_if_valid(api, pair.id1);
    std::cout << "Finished.\n";
    return 0;
}
