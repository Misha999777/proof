#include "system/HotkeyManager.hpp"

#include <UIAutomation.h>

HotkeyManager::HotkeyManager(HWND hwnd, int hotkeyId) 
    : m_hwnd(hwnd), m_hotkeyId(hotkeyId) 
{
    RegisterHotKey(m_hwnd, m_hotkeyId, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, 'P');
}

HotkeyManager::~HotkeyManager() {
    UnregisterHotKey(m_hwnd, m_hotkeyId);
}

std::wstring HotkeyManager::getSelectedTextViaUIA() {
    IUIAutomation* automation = nullptr;
    HRESULT hr = CoCreateInstance(__uuidof(CUIAutomation), NULL, CLSCTX_INPROC_SERVER, __uuidof(IUIAutomation), (void**)&automation);
    if (FAILED(hr) || !automation) {
        return L"";
    }

    IUIAutomationElement* focused = nullptr;
    hr = automation->GetFocusedElement(&focused);
    if (FAILED(hr) || !focused) {
        automation->Release();
        return L"";
    }

    std::wstring result = L"";
    IUIAutomationTextPattern* textPattern = nullptr;
    hr = focused->GetCurrentPatternAs(UIA_TextPatternId, __uuidof(IUIAutomationTextPattern), (void**)&textPattern);
    
    if (SUCCEEDED(hr) && textPattern) {
        IUIAutomationTextRangeArray* selection = nullptr;
        hr = textPattern->GetSelection(&selection);
        if (SUCCEEDED(hr) && selection) {
            int length = 0;
            selection->get_Length(&length);
            if (length > 0) {
                IUIAutomationTextRange* range = nullptr;
                hr = selection->GetElement(0, &range);
                if (SUCCEEDED(hr) && range) {
                    BSTR text = nullptr;
                    hr = range->GetText(-1, &text);
                    if (SUCCEEDED(hr) && text) {
                        result = text;
                        SysFreeString(text);
                    }
                    range->Release();
                }
            }
            selection->Release();
        }
        textPattern->Release();
    }
    
    focused->Release();
    automation->Release();
    return result;
}
