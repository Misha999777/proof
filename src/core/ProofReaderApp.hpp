#pragma once

#include <memory>
#include <string>
#include <Windows.h>
#include <saucer/app.hpp>

#include "ui/ProofReaderWindow.hpp"
#include "ui/TrayIcon.hpp"
#include "system/HotkeyManager.hpp"

class ProofReaderApp {
public:
    ProofReaderApp();
    ~ProofReaderApp();

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
    std::unique_ptr<ProofReaderWindow> m_proofReaderWindow;
    std::unique_ptr<HotkeyManager> m_hotkeyManager;
    HANDLE m_hMutex;
};
