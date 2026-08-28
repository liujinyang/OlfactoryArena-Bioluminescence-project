#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cmath>
#include <csignal>
#include <cctype>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

#pragma comment(lib, "Ws2_32.lib")

#include "C8855-01api.h"
#include "c8855_dynamic_api.h"

namespace fs = std::filesystem;

struct Options {
    std::string csv_path = "c8855_dual_data.csv";
    std::string csv_filename = "dual.csv";
    BYTE gate_time = C8855_GATETIME_1MS;
    WORD points_per_batch = 100;
    bool points_auto = false;
    int batches = 100;               // -1 = continuous, ignored when duration_s > 0
    double duration_s = -1.0;        // <=0 disabled
    BYTE trigger_mode = C8855_SOFTWARE_TRIGGER;
    BYTE trigger_edge = C8855_SET_FALL_EDGE;
    bool use_setup_ex = false;
    bool pmt_on = true;
    int poll_ms = 0;
    std::string dll_path = "C8855-01api.dll";
    bool tcp_server = false;
    unsigned short tcp_port = 55000;
    std::string tcp_bind = "127.0.0.1";
};

struct DevicePair {
    HANDLE id0 = INVALID_HANDLE_VALUE;
    HANDLE id1 = INVALID_HANDLE_VALUE;
};

struct ReadResult {
    BOOL ok = FALSE;
    BYTE result = 255;
};

struct ServerState {
    std::mutex mutex;
    Options base_options;
    std::string data_dir = ".";
    std::string active_data_dir = ".";
    std::string active_csv_filename = "dual.csv";
    std::string pending_csv_filename;
    bool csv_switch_pending = false;
    std::thread acquisition_thread;
    std::atomic<bool> acquisition_stop{false};
    std::atomic<bool> keep_pmt_power_after_stop{false};
    bool acquisition_running = false;
    bool pmt_power_on = false;
    int last_return_code = 0;
    std::string last_message = "idle";
};

static std::atomic<bool> g_stop{false};

static void on_signal(int) {
    g_stop = true;
}

static std::string upper_copy(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) {
        return static_cast<char>(std::toupper(c));
    });
    return s;
}

static std::string trim_copy(const std::string& s) {
    const auto first = s.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) {
        return "";
    }
    const auto last = s.find_last_not_of(" \t\r\n");
    return s.substr(first, last - first + 1);
}

static std::string strip_matching_quotes(std::string s) {
    s = trim_copy(s);
    if (s.size() >= 2 && s.front() == '"' && s.back() == '"') {
        return s.substr(1, s.size() - 2);
    }
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

static WORD choose_auto_points(double gate_s) {
    const double target_batch_s = 0.25;
    long n = static_cast<long>(std::floor(target_batch_s / gate_s + 0.5));
    if (n < 1) n = 1;
    if (n > 512) n = 512;
    return static_cast<WORD>(n);
}

static std::string build_csv_path(const std::string& data_dir, const Options& opt) {
    return (fs::path(data_dir) / opt.csv_filename).string();
}

static void print_usage() {
    std::cout
        << "Usage: c8855_dual_acquire.exe [options]\n"
        << "  --csv <path>            Output CSV path in batch mode (default: c8855_dual_data.csv)\n"
        << "  --csv-name <name>       Output filename in TCP server mode (default: dual.csv)\n"
        << "  --gate <50us|100us|...|10s>\n"
        << "  --points <1..512|auto>  Samples per ReadData batch (default: 100)\n"
        << "  --batches <n|-1>        Number of batches, -1 for continuous (default: 100)\n"
        << "  --duration <seconds>    Run for this measurement duration; overrides --batches\n"
        << "  --trigger <software|external>\n"
        << "  --edge <fall|rise>      External-trigger edge, used with --setupex\n"
        << "  --setupex               Use C8855SetupEx instead of C8855Setup\n"
        << "  --pmt-on                Enable PMT 5 V power on both devices (default)\n"
        << "  --pmt-off               Do not enable PMT 5 V power\n"
        << "  --poll-ms <n>           Sleep between batches (default: 0; usually keep 0)\n"
        << "  --dll <path>            Path to C8855-01api.dll (default: search next to EXE/PATH)\n"
        << "  --tcp-server            Run as a TCP command server\n"
        << "  --tcp-port <port>       TCP server port (default: 55000)\n"
        << "  --tcp-bind <ip>         TCP bind address (default: 127.0.0.1)\n"
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
        } else if (a == "--csv-name" && i + 1 < argc) {
            opt.csv_filename = argv[++i];
        } else if (a == "--gate" && i + 1 < argc) {
            if (!parse_gate_time(argv[++i], opt.gate_time)) {
                std::cerr << "Unknown gate time.\n";
                return false;
            }
        } else if (a == "--points" && i + 1 < argc) {
            std::string p = argv[++i];
            if (upper_copy(p) == "AUTO") {
                opt.points_auto = true;
            } else {
                int n = std::stoi(p);
                if (n < 1 || n > 512) {
                    std::cerr << "--points must be in [1, 512] or auto.\n";
                    return false;
                }
                opt.points_per_batch = static_cast<WORD>(n);
                opt.points_auto = false;
            }
        } else if (a == "--batches" && i + 1 < argc) {
            opt.batches = std::stoi(argv[++i]);
            if (opt.batches == 0 || opt.batches < -1) {
                std::cerr << "--batches must be positive or -1.\n";
                return false;
            }
        } else if (a == "--duration" && i + 1 < argc) {
            opt.duration_s = std::stod(argv[++i]);
            if (opt.duration_s <= 0.0) {
                std::cerr << "--duration must be positive seconds.\n";
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
        } else if (a == "--pmt-off") {
            opt.pmt_on = false;
        } else if (a == "--poll-ms" && i + 1 < argc) {
            opt.poll_ms = std::stoi(argv[++i]);
            if (opt.poll_ms < 0) opt.poll_ms = 0;
        } else if (a == "--dll" && i + 1 < argc) {
            opt.dll_path = argv[++i];
        } else if (a == "--tcp-server") {
            opt.tcp_server = true;
        } else if (a == "--tcp-port" && i + 1 < argc) {
            const int port = std::stoi(argv[++i]);
            if (port < 1 || port > 65535) {
                std::cerr << "--tcp-port must be in [1, 65535].\n";
                return false;
            }
            opt.tcp_port = static_cast<unsigned short>(port);
        } else if (a == "--tcp-bind" && i + 1 < argc) {
            opt.tcp_bind = argv[++i];
        } else {
            std::cerr << "Unknown argument: " << a << "\n";
            return false;
        }
    }

    if (opt.points_auto) {
        opt.points_per_batch = choose_auto_points(gate_time_seconds(opt.gate_time));
    }
    return true;
}

static void close_all_valid(C8855Api& api, HANDLE h[16]) {
    for (int i = 0; i < 16; ++i) {
        if (h[i] != INVALID_HANDLE_VALUE) {
            api.Close(h[i]);
            h[i] = INVALID_HANDLE_VALUE;
        }
    }
}

static bool is_valid_handle(HANDLE h) {
    return h != INVALID_HANDLE_VALUE && h != nullptr;
}

static void close_if_valid(C8855Api& api, HANDLE& h) {
    if (is_valid_handle(h)) {
        api.Close(h);
        h = INVALID_HANDLE_VALUE;
    }
}

static bool read_id_with_retry(C8855Api& api, HANDLE h, BYTE& id) {
    for (int attempt = 1; attempt <= 3; ++attempt) {
        id = 255;
        if (api.ReadId(h, &id) == TRUE) {
            return true;
        }
        std::cerr << "  C8855ReadId attempt " << attempt << " failed; trying reset/retry...\n";
        api.Reset(h);
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }
    return false;
}

static bool open_two_devices_by_id(C8855Api& api, DevicePair& pair) {
    HANDLE h[16];
    for (auto& x : h) {
        x = INVALID_HANDLE_VALUE;
    }

    if (!api.MOpen(16,
                   &h[0], &h[1], &h[2], &h[3], &h[4], &h[5], &h[6], &h[7],
                   &h[8], &h[9], &h[10], &h[11], &h[12], &h[13], &h[14], &h[15])) {
        std::cerr << "C8855MOpen failed. If LabVIEW/MATLAB is still connected, close it and try again.\n";
        return false;
    }

    int found = 0;
    for (int i = 0; i < 16; ++i) {
        if (!is_valid_handle(h[i])) {
            continue;
        }
        ++found;
        BYTE id = 255;
        if (!read_id_with_retry(api, h[i], id)) {
            std::cerr << "C8855ReadId failed for handle index " << i << " after retries.\n";
            continue;
        }
        std::cout << "Detected handle[" << i << "] with device ID " << static_cast<int>(id) << "\n";
        if (id == 0) {
            pair.id0 = h[i];
            h[i] = INVALID_HANDLE_VALUE;
        } else if (id == 1) {
            pair.id1 = h[i];
            h[i] = INVALID_HANDLE_VALUE;
        }
    }

    close_all_valid(api, h);

    if (found < 2) {
        std::cerr << "Expected at least 2 connected devices, found " << found << ".\n";
        return false;
    }
    if (!is_valid_handle(pair.id0) || !is_valid_handle(pair.id1)) {
        std::cerr << "Could not map both device IDs 0 and 1.\n";
        std::cerr << "Suggested recovery: close LabVIEW/MATLAB, press RESET on both C8855 units, or unplug/replug USB+power, then retry.\n";
        return false;
    }
    return true;
}

static bool reset_and_configure(C8855Api& api, HANDLE h, const Options& opt, const char* name) {
    if (!api.Reset(h)) {
        std::cerr << "C8855Reset failed for " << name << ".\n";
        return false;
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(100));

    BOOL ok;
    if (opt.use_setup_ex) {
        ok = api.SetupEx(h, opt.gate_time, C8855_BLOCK_TRANSFER, opt.points_per_batch, opt.trigger_edge);
    } else {
        ok = api.Setup(h, opt.gate_time, C8855_BLOCK_TRANSFER, opt.points_per_batch);
    }
    if (!ok) {
        std::cerr << "C8855Setup/SetupEx failed for " << name << ".\n";
        return false;
    }

    if (opt.pmt_on) {
        if (!api.SetPmtPower(h, C8855_PMT_POWER_ON)) {
            std::cerr << "Warning: C8855SetPmtPower(ON) failed for " << name << ".\n";
        }
    } else {
        api.SetPmtPower(h, C8855_PMT_POWER_OFF);
    }
    api.WritePort(h, 0);
    return true;
}

static bool read_both_parallel(C8855Api& api,
                               HANDLE h0,
                               HANDLE h1,
                               WORD n,
                               std::vector<DWORD>& d0,
                               std::vector<DWORD>& d1,
                               BYTE& r0,
                               BYTE& r1) {
    d0.assign(n, 0);
    d1.assign(n, 0);
    ReadResult rr0, rr1;

    std::thread t0([&]() { rr0.ok = api.ReadData(h0, d0.data(), &rr0.result); });
    std::thread t1([&]() { rr1.ok = api.ReadData(h1, d1.data(), &rr1.result); });
    t0.join();
    t1.join();

    r0 = rr0.result;
    r1 = rr1.result;
    if (rr0.ok != TRUE || rr1.ok != TRUE) {
        std::cerr << "ReadData failed. ok0=" << (rr0.ok == TRUE)
                  << " ok1=" << (rr1.ok == TRUE)
                  << " result0=" << static_cast<int>(r0)
                  << " result1=" << static_cast<int>(r1) << "\n";
        return false;
    }
    if (r0 == C8855_ERROR_TRANSFER || r1 == C8855_ERROR_TRANSFER) {
        std::cerr << "Transfer error reported by device. result0=" << static_cast<int>(r0)
                  << " result1=" << static_cast<int>(r1) << "\n";
        return false;
    }
    return true;
}

static int run_acquisition_session(const Options& opt,
                                   const std::string& csv_path,
                                   const std::atomic<bool>* stop_flag,
                                   const std::atomic<bool>* keep_pmt_power_after_stop = nullptr,
                                   ServerState* server_state = nullptr,
                                   const std::string& data_dir = std::string()) {
    C8855Api api;
    if (!api.load(opt.dll_path)) {
        return 10;
    }

    DevicePair pair;
    if (!open_two_devices_by_id(api, pair)) {
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        return 2;
    }

    if (!reset_and_configure(api, pair.id0, opt, "ID0") ||
        !reset_and_configure(api, pair.id1, opt, "ID1")) {
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        return 3;
    }

    std::ofstream csv(csv_path, std::ios::out | std::ios::trunc);
    if (!csv) {
        std::cerr << "Failed to open CSV file: " << csv_path << "\n";
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        return 4;
    }
    csv << "batch,index,time_s,ch0_count,ch1_count\n";
    csv.flush();
    std::string current_csv_path = csv_path;

    const double dt = gate_time_seconds(opt.gate_time);
    const long long requested_samples = (opt.duration_s > 0.0)
        ? static_cast<long long>(std::floor(opt.duration_s / dt + 0.5))
        : -1LL;

    std::cout << "Mapped device IDs 0 and 1 successfully. Writing to " << csv_path << "\n";
    std::cout << "Gate time = " << dt << " s, points/batch = " << opt.points_per_batch
              << (opt.points_auto ? " (auto)" : "") << "\n";
    if (opt.duration_s > 0.0) {
        std::cout << "Duration target = " << opt.duration_s
                  << " s, requested samples/channel = " << requested_samples << "\n";
    }
    std::cout << "PMT 5 V power: " << (opt.pmt_on ? "ON" : "OFF") << "\n";

    bool started0 = false;
    bool started1 = false;
    int return_code = 0;

    if (api.CountStart(pair.id0, opt.trigger_mode) != TRUE) {
        std::cerr << "C8855CountStart failed for ID0.\n";
        return_code = 5;
    } else {
        started0 = true;
        if (api.CountStart(pair.id1, opt.trigger_mode) != TRUE) {
            std::cerr << "C8855CountStart failed for ID1.\n";
            return_code = 5;
        } else {
            started1 = true;
        }
    }

    if (return_code == 0) {
        long long total_written = 0;
        long long file_written = 0;
        int batch = 0;
        int file_batch = 0;
        const bool continuous = (opt.batches < 0) && (opt.duration_s <= 0.0);

        while (!g_stop.load()) {
            if (stop_flag && stop_flag->load()) {
                break;
            }
            if (opt.duration_s > 0.0 && total_written >= requested_samples) {
                break;
            }
            if (opt.duration_s <= 0.0 && !continuous && batch >= opt.batches) {
                break;
            }

            if (server_state) {
                std::string requested_csv_filename;
                {
                    std::lock_guard<std::mutex> lock(server_state->mutex);
                    if (server_state->csv_switch_pending) {
                        requested_csv_filename = server_state->pending_csv_filename;
                        server_state->pending_csv_filename.clear();
                        server_state->csv_switch_pending = false;
                        server_state->active_csv_filename = requested_csv_filename;
                        server_state->last_message = "csv_switched";
                    }
                }

                if (!requested_csv_filename.empty()) {
                    const fs::path next_path = fs::path(data_dir) / requested_csv_filename;
                    std::ofstream next_csv(next_path.string(), std::ios::out | std::ios::trunc);
                    if (!next_csv) {
                        std::cerr << "Failed to open switched CSV file: " << next_path.string() << "\n";
                        return_code = 7;
                        break;
                    }

                    csv.close();
                    csv = std::move(next_csv);
                    csv << "batch,index,time_s,ch0_count,ch1_count\n";
                    csv.flush();
                    current_csv_path = next_path.string();
                    file_written = 0;
                    file_batch = 0;
                    std::cout << "Switched output CSV to " << current_csv_path << "\n";
                }
            }

            std::vector<DWORD> d0, d1;
            BYTE r0 = 255;
            BYTE r1 = 255;
            if (!read_both_parallel(api, pair.id0, pair.id1, opt.points_per_batch, d0, d1, r0, r1)) {
                std::cerr << "Acquisition failed on batch " << batch << ".\n";
                return_code = 6;
                break;
            }

            WORD n_to_write = opt.points_per_batch;
            if (opt.duration_s > 0.0) {
                long long remaining = requested_samples - total_written;
                if (remaining <= 0) {
                    break;
                }
                if (remaining < n_to_write) {
                    n_to_write = static_cast<WORD>(remaining);
                }
            }

            for (WORD i = 0; i < n_to_write; ++i) {
                const double t = (static_cast<double>(file_written) + i) * dt;
                csv << file_batch << ',' << i << ',' << std::fixed << std::setprecision(9)
                    << t << ',' << d0[i] << ',' << d1[i] << '\n';
            }
            csv.flush();

            std::cout << "Batch " << file_batch
                      << " complete. first[ch0,ch1]=[" << d0.front() << ',' << d1.front()
                      << "] last_written[ch0,ch1]=[" << d0[n_to_write - 1] << ','
                      << d1[n_to_write - 1]
                      << "] result[ch0,ch1]=[" << static_cast<int>(r0) << ','
                      << static_cast<int>(r1) << "]\n";

            total_written += n_to_write;
            file_written += n_to_write;
            ++batch;
            ++file_batch;
            if (opt.poll_ms > 0) {
                std::this_thread::sleep_for(std::chrono::milliseconds(opt.poll_ms));
            }
        }
    }

    if (started0 && api.CountStop(pair.id0) != TRUE) {
        std::cerr << "Warning: C8855CountStop failed for ID0.\n";
    }
    if (started1 && api.CountStop(pair.id1) != TRUE) {
        std::cerr << "Warning: C8855CountStop failed for ID1.\n";
    }
    const bool keep_pmt_power_on = keep_pmt_power_after_stop && keep_pmt_power_after_stop->load();
    if (opt.pmt_on && !keep_pmt_power_on) {
        api.SetPmtPower(pair.id0, C8855_PMT_POWER_OFF);
        api.SetPmtPower(pair.id1, C8855_PMT_POWER_OFF);
    } else if (opt.pmt_on && keep_pmt_power_on) {
        std::cout << "PMT 5 V power: kept ON after stop.\n";
    }
    api.WritePort(pair.id0, 0);
    api.WritePort(pair.id1, 0);
    close_if_valid(api, pair.id0);
    close_if_valid(api, pair.id1);
    std::cout << "Finished.\n";
    return return_code;
}

static bool set_manual_pmt_power(const Options& opt, bool power_on, std::string& message) {
    C8855Api api;
    if (!api.load(opt.dll_path)) {
        message = "failed to load C8855 API DLL";
        return false;
    }

    DevicePair pair;
    if (!open_two_devices_by_id(api, pair)) {
        close_if_valid(api, pair.id0);
        close_if_valid(api, pair.id1);
        message = "failed to open both C8855 devices";
        return false;
    }

    const BYTE desired_state = power_on ? C8855_PMT_POWER_ON : C8855_PMT_POWER_OFF;
    bool ok = true;
    if (!api.SetPmtPower(pair.id0, desired_state)) {
        ok = false;
        std::cerr << "C8855SetPmtPower failed for ID0.\n";
    }
    if (!api.SetPmtPower(pair.id1, desired_state)) {
        ok = false;
        std::cerr << "C8855SetPmtPower failed for ID1.\n";
    }
    api.WritePort(pair.id0, 0);
    api.WritePort(pair.id1, 0);
    close_if_valid(api, pair.id0);
    close_if_valid(api, pair.id1);

    if (!ok) {
        message = power_on ? "failed to turn PMTs on" : "failed to turn PMTs off";
        return false;
    }

    message = power_on ? "PMTs turned on" : "PMTs turned off";
    return true;
}

static bool send_line(SOCKET socket_fd, const std::string& line) {
    std::string payload = line;
    payload.push_back('\n');
    const char* data = payload.c_str();
    int remaining = static_cast<int>(payload.size());
    while (remaining > 0) {
        const int sent = send(socket_fd, data, remaining, 0);
        if (sent == SOCKET_ERROR) {
            return false;
        }
        data += sent;
        remaining -= sent;
    }
    return true;
}

static bool recv_line(SOCKET socket_fd, std::string& buffer, std::string& line) {
    line.clear();
    while (true) {
        const auto newline_pos = buffer.find('\n');
        if (newline_pos != std::string::npos) {
            line = buffer.substr(0, newline_pos);
            buffer.erase(0, newline_pos + 1);
            if (!line.empty() && line.back() == '\r') {
                line.pop_back();
            }
            return true;
        }

        char chunk[512];
        const int received = recv(socket_fd, chunk, sizeof(chunk), 0);
        if (received == 0) {
            return false;
        }
        if (received == SOCKET_ERROR) {
            const int err = WSAGetLastError();
            if (err == WSAETIMEDOUT) {
                if (g_stop.load()) {
                    return false;
                }
                continue;
            }
            return false;
        }
        buffer.append(chunk, chunk + received);
    }
}

static void reap_finished_acquisition(ServerState& state) {
    std::thread worker;
    {
        std::lock_guard<std::mutex> lock(state.mutex);
        if (!state.acquisition_running && state.acquisition_thread.joinable()) {
            worker = std::move(state.acquisition_thread);
        }
    }
    if (worker.joinable()) {
        worker.join();
    }
}

static bool start_acquisition(ServerState& state, std::string& message) {
    reap_finished_acquisition(state);

    Options run_options;
    std::string csv_path;
    std::string data_dir;
    {
        std::lock_guard<std::mutex> lock(state.mutex);
        if (state.acquisition_running) {
            message = "acquisition is already running";
            return false;
        }

        fs::path data_dir_path = fs::path(state.data_dir);
        std::error_code ec;
        if (!fs::exists(data_dir_path, ec)) {
            fs::create_directories(data_dir_path, ec);
        }
        if (ec) {
            message = "failed to create data directory: " + state.data_dir;
            return false;
        }

        state.acquisition_stop = false;
        state.keep_pmt_power_after_stop = false;
        state.acquisition_running = true;
        state.last_return_code = 0;
        state.last_message = "running";
        state.csv_switch_pending = false;
        state.pending_csv_filename.clear();

        run_options = state.base_options;
        run_options.duration_s = -1.0;
        run_options.batches = -1;
        data_dir = state.data_dir;
        state.active_data_dir = data_dir;
        state.active_csv_filename = run_options.csv_filename;
        csv_path = build_csv_path(data_dir, run_options);
    }

    state.acquisition_thread = std::thread([&state, run_options, csv_path, data_dir]() {
        const int rc = run_acquisition_session(run_options, csv_path, &state.acquisition_stop,
                                               &state.keep_pmt_power_after_stop, &state, data_dir);
        const bool keep_power = state.keep_pmt_power_after_stop.load();
        std::lock_guard<std::mutex> lock(state.mutex);
        state.acquisition_running = false;
        state.pmt_power_on = keep_power && run_options.pmt_on;
        state.keep_pmt_power_after_stop = false;
        state.csv_switch_pending = false;
        state.pending_csv_filename.clear();
        state.last_return_code = rc;
        if (rc != 0) {
            state.last_message = "error";
        } else if (state.acquisition_stop.load()) {
            state.last_message = "stopped";
        } else {
            state.last_message = "completed";
        }
    });

    message = "started acquisition: " + csv_path;
    return true;
}

static bool stop_acquisition(ServerState& state, bool keep_pmt_power_on, std::string& message) {
    reap_finished_acquisition(state);

    bool was_running = false;
    std::thread worker;
    {
        std::lock_guard<std::mutex> lock(state.mutex);
        was_running = state.acquisition_running;
        if (was_running) {
            state.keep_pmt_power_after_stop = keep_pmt_power_on;
            state.acquisition_stop = true;
        }
        if (state.acquisition_thread.joinable()) {
            worker = std::move(state.acquisition_thread);
        }
    }

    if (worker.joinable()) {
        worker.join();
    }

    {
        std::lock_guard<std::mutex> lock(state.mutex);
        state.acquisition_running = false;
        if (was_running && state.last_return_code == 0) {
            state.last_message = keep_pmt_power_on ? "stopped_pmt_on" : "stopped";
        }
    }

    if (was_running && keep_pmt_power_on) {
        message = "acquisition stopped; PMT power kept on";
    } else {
        message = was_running ? "acquisition stopped" : "acquisition already idle";
    }
    return true;
}

static std::string format_status(ServerState& state) {
    reap_finished_acquisition(state);

    std::lock_guard<std::mutex> lock(state.mutex);
    std::ostringstream oss;
    oss << (state.acquisition_running ? "RUNNING" : "IDLE")
        << " pmt=" << (state.pmt_power_on ? "ON" : "OFF")
        << " data_dir=" << state.data_dir
        << " csv=" << build_csv_path(state.data_dir, state.base_options)
        << " active_csv=" << (fs::path(state.active_data_dir) / state.active_csv_filename).string()
        << " pending_csv=" << (state.csv_switch_pending ? state.pending_csv_filename : "")
        << " last=" << state.last_message
        << " rc=" << state.last_return_code;
    return oss.str();
}

static std::string process_command(ServerState& state,
                                   const std::string& raw_line,
                                   bool& shutdown_requested) {
    const std::string line = trim_copy(raw_line);
    if (line.empty()) {
        return "ERR empty command";
    }

    std::istringstream iss(line);
    std::string command;
    iss >> command;
    const std::string upper_command = upper_copy(command);
    std::string remainder;
    std::getline(iss, remainder);
    remainder = strip_matching_quotes(remainder);

    if (upper_command == "PING") {
        return "OK PONG";
    }
    if (upper_command == "STATUS") {
        return "OK " + format_status(state);
    }
    if (upper_command == "START") {
        std::string message;
        if (start_acquisition(state, message)) {
            std::lock_guard<std::mutex> lock(state.mutex);
            state.pmt_power_on = state.base_options.pmt_on;
            return "OK " + message;
        }
        return "ERR " + message;
    }
    if (upper_command == "STOP") {
        std::string message;
        stop_acquisition(state, false, message);
        {
            std::lock_guard<std::mutex> lock(state.mutex);
            state.pmt_power_on = false;
        }
        return "OK " + message;
    }
    if (upper_command == "STOP_KEEP_PMT_ON") {
        std::string message;
        stop_acquisition(state, true, message);
        return "OK " + message;
    }
    if (upper_command == "PMT_ON" || upper_command == "PMT_OFF") {
        const bool power_on = (upper_command == "PMT_ON");

        reap_finished_acquisition(state);

        Options idle_options;
        {
            std::lock_guard<std::mutex> lock(state.mutex);
            if (state.acquisition_running) {
                return "ERR cannot change PMT power while acquisition is running";
            }
            idle_options = state.base_options;
        }

        std::string message;
        if (!set_manual_pmt_power(idle_options, power_on, message)) {
            return "ERR " + message;
        }

        {
            std::lock_guard<std::mutex> lock(state.mutex);
            state.pmt_power_on = power_on;
            state.last_message = power_on ? "pmt_on" : "pmt_off";
            state.last_return_code = 0;
        }
        return "OK " + message;
    }
    if (upper_command == "SETDATADIR") {
        if (remainder.empty()) {
            return "ERR SETDATADIR requires a directory path";
        }

        reap_finished_acquisition(state);

        std::lock_guard<std::mutex> lock(state.mutex);
        if (state.acquisition_running) {
            return "ERR cannot change data directory while acquisition is running";
        }
        state.data_dir = remainder;
        state.last_message = "data_dir_updated";
        return "OK data directory set to " + state.data_dir;
    }
    if (upper_command == "SETCSVNAME") {
        if (remainder.empty()) {
            return "ERR SETCSVNAME requires a CSV filename";
        }

        reap_finished_acquisition(state);

        fs::path requested_path = fs::path(remainder).filename();
        const std::string requested_name = requested_path.string();
        if (requested_name.empty() || requested_name == "." || requested_name == "..") {
            return "ERR invalid CSV filename";
        }

        std::lock_guard<std::mutex> lock(state.mutex);
        state.base_options.csv_filename = requested_name;
        if (state.acquisition_running) {
            state.pending_csv_filename = requested_name;
            state.csv_switch_pending = true;
            state.last_message = "csv_switch_pending";
            return "OK CSV switch queued to " + requested_name;
        }
        state.last_message = "csv_name_updated";
        return "OK csv filename set to " + state.base_options.csv_filename;
    }
    if (upper_command == "SHUTDOWN") {
        std::string message;
        stop_acquisition(state, false, message);
        {
            std::lock_guard<std::mutex> lock(state.mutex);
            state.pmt_power_on = false;
        }
        shutdown_requested = true;
        return "OK server shutting down";
    }

    return "ERR unknown command";
}

static int run_tcp_server(const Options& opt) {
    WSADATA wsa_data{};
    if (WSAStartup(MAKEWORD(2, 2), &wsa_data) != 0) {
        std::cerr << "WSAStartup failed.\n";
        return 20;
    }

    SOCKET listen_socket = INVALID_SOCKET;
    int return_code = 0;

    addrinfo hints{};
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    hints.ai_flags = AI_PASSIVE;

    const std::string port_text = std::to_string(opt.tcp_port);
    addrinfo* bind_info = nullptr;
    if (getaddrinfo(opt.tcp_bind.c_str(), port_text.c_str(), &hints, &bind_info) != 0) {
        std::cerr << "getaddrinfo failed for " << opt.tcp_bind << ":" << opt.tcp_port << "\n";
        WSACleanup();
        return 21;
    }

    listen_socket = socket(bind_info->ai_family, bind_info->ai_socktype, bind_info->ai_protocol);
    if (listen_socket == INVALID_SOCKET) {
        std::cerr << "socket() failed.\n";
        freeaddrinfo(bind_info);
        WSACleanup();
        return 22;
    }

    BOOL reuse_addr = TRUE;
    setsockopt(listen_socket, SOL_SOCKET, SO_REUSEADDR, reinterpret_cast<const char*>(&reuse_addr), sizeof(reuse_addr));

    if (bind(listen_socket, bind_info->ai_addr, static_cast<int>(bind_info->ai_addrlen)) == SOCKET_ERROR) {
        std::cerr << "bind() failed on " << opt.tcp_bind << ":" << opt.tcp_port << "\n";
        closesocket(listen_socket);
        freeaddrinfo(bind_info);
        WSACleanup();
        return 23;
    }
    freeaddrinfo(bind_info);

    if (listen(listen_socket, 4) == SOCKET_ERROR) {
        std::cerr << "listen() failed.\n";
        closesocket(listen_socket);
        WSACleanup();
        return 24;
    }

    ServerState state;
    state.base_options = opt;
    state.base_options.tcp_server = false;
    state.base_options.duration_s = -1.0;
    state.base_options.batches = -1;
    if (state.base_options.points_auto) {
        state.base_options.points_per_batch = choose_auto_points(gate_time_seconds(state.base_options.gate_time));
    }
    state.data_dir = fs::current_path().string();

    std::cout << "C8855 TCP server listening on " << opt.tcp_bind << ":" << opt.tcp_port << "\n";
    std::cout << "Current output file: " << build_csv_path(state.data_dir, state.base_options) << "\n";

    bool shutdown_requested = false;
    while (!g_stop.load() && !shutdown_requested) {
        fd_set read_set;
        FD_ZERO(&read_set);
        FD_SET(listen_socket, &read_set);

        timeval timeout{};
        timeout.tv_sec = 0;
        timeout.tv_usec = 250000;

        const int select_result = select(0, &read_set, nullptr, nullptr, &timeout);
        if (select_result == SOCKET_ERROR) {
            std::cerr << "select() failed while waiting for clients.\n";
            return_code = 25;
            break;
        }
        if (select_result == 0) {
            continue;
        }

        SOCKET client_socket = accept(listen_socket, nullptr, nullptr);
        if (client_socket == INVALID_SOCKET) {
            if (!g_stop.load()) {
                std::cerr << "accept() failed.\n";
                return_code = 26;
            }
            break;
        }

        DWORD recv_timeout_ms = 500;
        setsockopt(client_socket, SOL_SOCKET, SO_RCVTIMEO,
                   reinterpret_cast<const char*>(&recv_timeout_ms), sizeof(recv_timeout_ms));

        std::string buffer;
        std::string line;
        while (!g_stop.load() && !shutdown_requested && recv_line(client_socket, buffer, line)) {
            const std::string response = process_command(state, line, shutdown_requested);
            if (!send_line(client_socket, response)) {
                break;
            }
        }

        closesocket(client_socket);
    }

    std::string stop_message;
    stop_acquisition(state, false, stop_message);
    reap_finished_acquisition(state);

    if (listen_socket != INVALID_SOCKET) {
        closesocket(listen_socket);
    }
    WSACleanup();
    std::cout << "C8855 TCP server stopped.\n";
    return return_code;
}

int main(int argc, char** argv) {
    std::signal(SIGINT, on_signal);

    Options opt;
    if (!parse_args(argc, argv, opt)) {
        return 1;
    }

    if (opt.tcp_server) {
        return run_tcp_server(opt);
    }

    return run_acquisition_session(opt, opt.csv_path, nullptr);
}
