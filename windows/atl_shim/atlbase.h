#pragma once
#include <windows.h>
#include <string>

class CW2A {
public:
    CW2A(LPCWSTR wstr, UINT codePage = CP_THREAD_ACP) {
        if (!wstr) return;
        int len = WideCharToMultiByte(codePage, 0, wstr, -1, nullptr, 0, nullptr, nullptr);
        if (len > 1) {
            str.resize(len - 1);
            WideCharToMultiByte(codePage, 0, wstr, -1, &str[0], len, nullptr, nullptr);
        }
    }
    operator const char*() const { return str.c_str(); }
private:
    std::string str;
};
