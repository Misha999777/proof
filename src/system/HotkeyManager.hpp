#pragma once

#include <string>
#include <Windows.h>

class HotkeyManager {
public:
    HotkeyManager(HWND hwnd, int hotkeyId);
    ~HotkeyManager();

    std::wstring getSelectedTextViaUIA();

private:
    HWND m_hwnd;
    int m_hotkeyId;
};
