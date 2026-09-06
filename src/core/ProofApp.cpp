#include "core/ProofApp.hpp"

ProofApp::ProofApp() : m_hMutex(NULL) {}

ProofApp::~ProofApp() {
    if (m_hMutex) {
        CloseHandle(m_hMutex);
    }
}

bool ProofApp::enforceSingleInstance() {
    m_hMutex = CreateMutexW(NULL, TRUE, L"ProofAppSingleInstanceMutex");
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        HWND existing = FindWindowW(L"ProofTrayWindow", L"ProofTrayWindow");
        if (existing) {
            PostMessageW(existing, WM_USER + 2, 0, 0);
        }
        return false;
    }
    return true;
}

int ProofApp::run(const std::wstring& cmdLine) {
    if (!enforceSingleInstance()) {
        return 0;
    }

    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);

    bool hiddenLaunch = cmdLine.find(L"--autostart") != std::wstring::npos;
    bool devMode = (cmdLine.find(L"--dev") != std::wstring::npos);
    auto app_result = saucer::application::create({.id = "proof-app", .quit_on_last_window_closed = false});
    if (!app_result) {
        return 1;
    }
    auto appInstance = std::move(app_result.value());

    auto start_coro = [this, hiddenLaunch, devMode](saucer::application *app) -> coco::stray {
        m_app = app;

        m_trayIcon = std::make_unique<TrayIcon>(this);
        m_hotkeyManager = std::make_unique<HotkeyManager>(m_trayIcon->getHwnd(), 1);
        m_proofWindow = std::make_unique<ProofWindow>(app, this, devMode);

        if (!hiddenLaunch) {
            m_proofWindow->show();
        }
        co_await app->finish();
        m_proofWindow.reset();
        m_hotkeyManager.reset();
        m_trayIcon.reset();
        m_app = nullptr;
    };

    return appInstance.run(start_coro);
}

void ProofApp::toggleWindow() {
    if (!m_app) return;
    m_app->post([this]() {
        if (m_proofWindow) {
            m_proofWindow->show();
            m_proofWindow->focus();
        }
    });
}

void ProofApp::showWindowWithText(const std::wstring& text) {
    if (!m_app) return;
    m_app->post([this, text]() {
        if (m_proofWindow) {
            if (!text.empty()) {
                m_proofWindow->sendText(text);
            }
            m_proofWindow->show();
            m_proofWindow->focus();
        }
    });
}

void ProofApp::handleHotkey(int hotkeyId) {
    if (hotkeyId == 1 && m_hotkeyManager) {
        std::wstring text = m_hotkeyManager->getSelectedTextViaUIA();
        if (!text.empty()) {
            showWindowWithText(text);
        }
    }
}

void ProofApp::quit() {
    if (!m_app) return;
    m_app->post([this]() {
        m_app->quit();
    });
}
