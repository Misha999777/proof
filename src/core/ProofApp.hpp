#pragma once

#include <memory>
#include <string>
#include <Windows.h>
#include <saucer/app.hpp>

#include "ui/ProofWindow.hpp"
#include "ui/TrayIcon.hpp"
#include "system/HotkeyManager.hpp"

class ProofApp {
public:
    ProofApp();
    ~ProofApp();

    int run(const std::wstring& cmdLine);

    void toggleWindow();
    void showWindowWithText(const std::wstring& text);
    void handleHotkey(int hotkeyId);
    void quit();

    saucer::application* getApp() { return m_app; }

private:
    bool enforceSingleInstance();

    saucer::application* m_app = nullptr;
    std::unique_ptr<TrayIcon> m_trayIcon;
    std::unique_ptr<ProofWindow> m_proofWindow;
    std::unique_ptr<HotkeyManager> m_hotkeyManager;
    HANDLE m_hMutex;
};
