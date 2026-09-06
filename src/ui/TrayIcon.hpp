#pragma once

#include <Windows.h>

class ProofApp;

class TrayIcon {
public:
    TrayIcon(ProofApp* app);
    ~TrayIcon();

    HWND getHwnd() const { return m_hwnd; }

private:
    static LRESULT CALLBACK windowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

    ProofApp* m_app;
    HWND m_hwnd;
    NOTIFYICONDATAW m_nid;
};
