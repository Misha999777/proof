#include "utils/Utils.hpp"

namespace Utils {
    bool isWindowsDarkMode() {
        DWORD value = 1;
        DWORD size = sizeof(value);
        RegGetValueW(HKEY_CURRENT_USER,
            L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
            L"AppsUseLightTheme", RRF_RT_REG_DWORD, nullptr, &value, &size);
        return value == 0;
    }
}
