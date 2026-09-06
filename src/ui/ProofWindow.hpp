#pragma once

#include <optional>
#include <saucer/smartview.hpp>

class ProofApp;

class ProofWindow {
public:
    ProofWindow(saucer::application* app, ProofApp* parentApp, bool devMode = false);
    ~ProofWindow();

    void show();
    void hide();
    void focus();
    void sendText(const std::wstring& text);

private:
    static std::string utf16_to_utf8(const std::wstring& wstr);

    std::shared_ptr<saucer::window> m_window;
    std::optional<saucer::smartview> m_webview;
    ProofApp* m_parentApp;
};
