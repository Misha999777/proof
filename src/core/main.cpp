#include "core/ProofApp.hpp"

#include <string>
#include <Windows.h>

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow) {
    ProofApp app;
    return app.run(pCmdLine);
}
