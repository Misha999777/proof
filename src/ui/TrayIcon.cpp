#include "ui/TrayIcon.hpp"

#include "core/ProofReaderApp.hpp"
#include "utils/Utils.hpp"
#include "resources/resource.hpp"

#define WM_TRAYICON (WM_USER + 1)
#define WM_SINGLE_INSTANCE (WM_USER + 2)
#define HOTKEY_ID 1

typedef int (WINAPI *fnSetPreferredAppMode)(int mode);
typedef void (WINAPI *fnFlushMenuThemes)();

static fnSetPreferredAppMode pSetPreferredAppMode = nullptr;
static fnFlushMenuThemes pFlushMenuThemes = nullptr;

static void applyMenuTheme() {
    if (pSetPreferredAppMode) {
        pSetPreferredAppMode(Utils::isWindowsDarkMode() ? 2 : 0);
    }
    if (pFlushMenuThemes) {
        pFlushMenuThemes();
    }
}

static void initDarkModeMenuSupport() {
    HMODULE hUxtheme = LoadLibraryExW(L"uxtheme.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (hUxtheme) {
        pSetPreferredAppMode = (fnSetPreferredAppMode)GetProcAddress(hUxtheme, MAKEINTRESOURCEA(135));
        pFlushMenuThemes = (fnFlushMenuThemes)GetProcAddress(hUxtheme, MAKEINTRESOURCEA(136));
        applyMenuTheme();
    }
}

TrayIcon::TrayIcon(ProofReaderApp* app) : m_app(app) {
    initDarkModeMenuSupport();

    HINSTANCE hInstance = GetModuleHandleW(NULL);
    WNDCLASSW wc = {};
    wc.lpfnWndProc = TrayIcon::windowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = L"ProofReaderTrayWindow";
    RegisterClassW(&wc);

    m_hwnd = CreateWindowW(L"ProofReaderTrayWindow", L"ProofReaderTrayWindow", 0, 0, 0, 0, 0, NULL, NULL, hInstance, this);

    SetWindowLongPtr(m_hwnd, GWLP_USERDATA, (LONG_PTR)this);

    m_nid = {};
    m_nid.cbSize = sizeof(NOTIFYICONDATAW);
    m_nid.hWnd = m_hwnd;
    m_nid.uID = 1;
    m_nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
    m_nid.uCallbackMessage = WM_TRAYICON;
    m_nid.hIcon = LoadIconW(hInstance, MAKEINTRESOURCEW(IDI_APP_ICON));
    wcscpy_s(m_nid.szTip, L"ProofReader");
    Shell_NotifyIconW(NIM_ADD, &m_nid);
}

TrayIcon::~TrayIcon() {
    Shell_NotifyIconW(NIM_DELETE, &m_nid);
    DestroyWindow(m_hwnd);
}

LRESULT CALLBACK TrayIcon::windowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    TrayIcon* pThis = (TrayIcon*)GetWindowLongPtr(hwnd, GWLP_USERDATA);

    switch (msg) {
        case WM_TRAYICON: {
            if (LOWORD(lParam) == WM_LBUTTONUP) {
                if (pThis && pThis->m_app) {
                    pThis->m_app->toggleWindow();
                }
            } else if (LOWORD(lParam) == WM_RBUTTONUP) {
                POINT pt;
                GetCursorPos(&pt);
                HMENU hMenu = CreatePopupMenu();
                InsertMenuW(hMenu, 0, MF_BYPOSITION | MF_STRING, 1, L"Show");
                InsertMenuW(hMenu, 1, MF_BYPOSITION | MF_SEPARATOR, 0, NULL);
                InsertMenuW(hMenu, 2, MF_BYPOSITION | MF_STRING, 2, L"Exit");
                SetForegroundWindow(hwnd);
                int cmd = TrackPopupMenu(hMenu, TPM_RETURNCMD | TPM_NONOTIFY, pt.x, pt.y, 0, hwnd, NULL);
                DestroyMenu(hMenu);
                
                if (cmd == 1) {
                    if (pThis && pThis->m_app) {
                        pThis->m_app->toggleWindow();
                    }
                } else if (cmd == 2) {
                    if (pThis && pThis->m_app) {
                        pThis->m_app->quit();
                    }
                }
            }
            break;
        }
        case WM_HOTKEY: {
            if (pThis && pThis->m_app) {
                pThis->m_app->handleHotkey(wParam);
            }
            break;
        }
        case WM_SINGLE_INSTANCE: {
            if (pThis && pThis->m_app) {
                pThis->m_app->showWindowWithText(L"");
            }
            break;
        }
        case WM_SETTINGCHANGE: {
            if (lParam != 0) {
                const wchar_t* setting = reinterpret_cast<const wchar_t*>(lParam);
                if (wcscmp(setting, L"ImmersiveColorSet") == 0) {
                    applyMenuTheme();
                }
            }
            break;
        }
        case WM_CLOSE: {
            if (pThis && pThis->m_app) {
                pThis->m_app->quit(); 
            } else {
                DestroyWindow(hwnd);
            }
            return 0;
        }
        case WM_DESTROY: {
            PostQuitMessage(0); 
            return 0;
        }
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}
