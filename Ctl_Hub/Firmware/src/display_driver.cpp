#include "display_driver.h"

LGFX_CtlHub tft;
bool display_enabled = false;

struct KeyBox {
    int x, y, w, h;
};

// 3.2" Screen (320x240 landscape) card geometry
// Left column (keys 0-2) mapped next to left switches K1-K3
// Right column (keys 3-5) mapped next to right switches K4-K6
static const KeyBox KEY_BOXES[6] = {
    {6,   36, 150, 48},  // K1 (Top Left)
    {6,   88, 150, 48},  // K2 (Mid Left)
    {6,  140, 150, 48},  // K3 (Bot Left)
    {164, 36, 150, 48},  // K4 (Top Right)
    {164, 88, 150, 48},  // K5 (Mid Right)
    {164, 140, 150, 48}  // K6 (Bot Right)
};

static uint16_t currentThemeColor = 0x1976;
static String currentLabels[6];

void initDisplay() {
    tft.init();
    tft.setRotation(1);
    display_enabled = true;
    tft.fillScreen(TFT_BLACK);
}

void drawFullDeckUI(const char* profileName, const char* hexColor, const char* keyLabels[6]) {
    if (!display_enabled) return;

    currentThemeColor = parseHexColor(hexColor);
    tft.startWrite();
    tft.fillScreen(0x1082);

    // Profile header
    tft.fillRoundRect(6, 4, 308, 28, 6, currentThemeColor);
    tft.drawRoundRect(6, 4, 308, 28, 6, TFT_WHITE);
    tft.setTextColor(TFT_WHITE, currentThemeColor);
    tft.setTextSize(1);
    tft.setTextDatum(MC_DATUM);
    tft.drawString(profileName, 160, 18);

    // Key cards
    for (int i = 0; i < 6; i++) {
        currentLabels[i] = (keyLabels && keyLabels[i]) ? keyLabels[i] : "";
        const KeyBox& kb = KEY_BOXES[i];

        tft.fillRoundRect(kb.x, kb.y, kb.w, kb.h, 4, 0x2124);
        tft.drawRoundRect(kb.x, kb.y, kb.w, kb.h, 4, 0x4A69);

        // Key badge
        tft.fillRoundRect(kb.x + 4, kb.y + 8, 30, 32, 3, currentThemeColor);
        tft.setTextColor(TFT_WHITE, currentThemeColor);
        tft.setTextSize(1);
        tft.setTextDatum(MC_DATUM);
        char badge[4];
        snprintf(badge, sizeof(badge), "K%d", i + 1);
        tft.drawString(badge, kb.x + 19, kb.y + 24);

        // Label
        tft.setTextColor(TFT_WHITE, 0x2124);
        tft.setTextDatum(ML_DATUM);
        tft.drawString(currentLabels[i].c_str(), kb.x + 40, kb.y + 24);
    }

    // Telemetry footer container
    tft.fillRoundRect(6, 196, 308, 38, 4, 0x18E3);
    tft.setTextColor(TFT_SILVER, 0x18E3);
    tft.setTextSize(1);
    tft.setTextDatum(ML_DATUM);
    tft.drawString("CPU: --%", 12, 215);
    tft.drawString("RAM: --%", 170, 215);

    tft.endWrite();
}

void updateTelemetryUI(int cpu, int ram) {
    if (!display_enabled) return;

    if (cpu < 0) cpu = 0;
    if (cpu > 100) cpu = 100;
    if (ram < 0) ram = 0;
    if (ram > 100) ram = 100;

    tft.startWrite();

    // CPU bar above Knob 0
    tft.fillRoundRect(70, 209, 80, 12, 3, 0x2965);
    const uint16_t cpuCol = (cpu > 80) ? TFT_RED : (cpu > 50) ? TFT_YELLOW : TFT_GREEN;
    const int cpuW = (80 * cpu) / 100;
    if (cpuW > 0) tft.fillRoundRect(70, 209, cpuW, 12, 3, cpuCol);

    char buf[16];
    tft.setTextSize(1);
    tft.setTextDatum(ML_DATUM);
    tft.setTextColor(TFT_WHITE, 0x18E3);
    snprintf(buf, sizeof(buf), "CPU:%2d%%", cpu);
    tft.drawString(buf, 12, 215);

    // RAM bar above Knob 1
    tft.fillRoundRect(228, 209, 80, 12, 3, 0x2965);
    const uint16_t ramCol = (ram > 80) ? TFT_RED : (ram > 50) ? TFT_YELLOW : TFT_CYAN;
    const int ramW = (80 * ram) / 100;
    if (ramW > 0) tft.fillRoundRect(228, 209, ramW, 12, 3, ramCol);

    snprintf(buf, sizeof(buf), "RAM:%2d%%", ram);
    tft.drawString(buf, 170, 215);

    tft.endWrite();
}

void highlightKey(int keyId, bool pressed) {
    if (!display_enabled || keyId < 0 || keyId >= 6) return;
    const KeyBox& kb = KEY_BOXES[keyId];

    tft.startWrite();
    if (pressed) {
        tft.fillRoundRect(kb.x, kb.y, kb.w, kb.h, 4, currentThemeColor);
        tft.drawRoundRect(kb.x, kb.y, kb.w, kb.h, 4, TFT_WHITE);
        tft.setTextColor(TFT_WHITE, currentThemeColor);
        tft.setTextSize(1);
        tft.setTextDatum(MC_DATUM);
        tft.drawString(currentLabels[keyId].c_str(), kb.x + (kb.w / 2), kb.y + 24);
    } else {
        tft.fillRoundRect(kb.x, kb.y, kb.w, kb.h, 4, 0x2124);
        tft.drawRoundRect(kb.x, kb.y, kb.w, kb.h, 4, 0x4A69);

        tft.fillRoundRect(kb.x + 4, kb.y + 8, 30, 32, 3, currentThemeColor);
        tft.setTextColor(TFT_WHITE, currentThemeColor);
        tft.setTextSize(1);
        tft.setTextDatum(MC_DATUM);
        char badge[4];
        snprintf(badge, sizeof(badge), "K%d", keyId + 1);
        tft.drawString(badge, kb.x + 19, kb.y + 24);

        tft.setTextColor(TFT_WHITE, 0x2124);
        tft.setTextDatum(ML_DATUM);
        tft.drawString(currentLabels[keyId].c_str(), kb.x + 40, kb.y + 24);
    }
    tft.endWrite();
}
