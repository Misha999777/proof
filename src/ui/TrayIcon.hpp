#pragma once

#include <Windows.h>

class ProofReaderApp;

class TrayIcon {
public:
    TrayIcon(ProofReaderApp* app);
    ~TrayIcon();

    HWND getHwnd() const { return m_hwnd; }

private:
    static LRESULT CALLBACK windowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

    ProofReaderApp* m_app;
    HWND m_hwnd;
    NOTIFYICONDATAW m_nid;
};
