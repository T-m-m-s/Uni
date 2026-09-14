#pragma once

#include <LovyanGFX.hpp>
#include "pinout.h"

// ==============================================================================
// LovyanGFX Configuration for 3.2" SPI Display (Default: ILI9341 320x240)
// To change controller, replace Panel_ILI9341 with Panel_ST7789 or Panel_ILI9488
// ==============================================================================
class LGFX_CtlHub : public lgfx::LGFX_Device {
    // 3.2" SPI Display driver (ILI9341 standard 320x240)
    lgfx::Panel_ILI9341 _panel_instance;
    lgfx::Bus_SPI       _bus_instance;
    lgfx::Light_PWM     _light_instance;

public:
    LGFX_CtlHub() {
        {
            auto cfg = _bus_instance.config();
            cfg.spi_host = SPI2_HOST;
            cfg.spi_mode = 0;
            cfg.freq_write = 20000000;
            cfg.freq_read  = 16000000;
            cfg.pin_sclk = PIN_TFT_SCK;
            cfg.pin_mosi = PIN_TFT_MOSI;
            cfg.pin_miso = -1;
            cfg.pin_dc   = PIN_TFT_DC;
            _bus_instance.config(cfg);
            _panel_instance.setBus(&_bus_instance);
        }
        {
            auto cfg = _panel_instance.config();
            cfg.pin_cs           = PIN_TFT_CS;
            cfg.pin_rst          = PIN_TFT_RST;
            cfg.pin_busy         = -1;
            cfg.panel_width      = 240;
            cfg.panel_height     = 320;
            cfg.offset_x         = 0;
            cfg.offset_y         = 0;
            cfg.offset_rotation  = 0; // Base orientation (0 = portrait, 1 = landscape)
            cfg.dummy_read_pixel = 8;
            cfg.dummy_read_bits  = 1;
            cfg.readable         = false;
            cfg.invert           = false;
            cfg.rgb_order        = false;
            cfg.dlen_16bit       = false;
            cfg.bus_shared       = false;
            _panel_instance.config(cfg);
        }
        {
            auto cfg = _light_instance.config();
            cfg.pin_bl = -1;
            _light_instance.config(cfg);
            _panel_instance.setLight(&_light_instance);
        }
        setPanel(&_panel_instance);
    }
};

extern LGFX_CtlHub tft;
extern bool display_enabled;

// Convert Hex string "#RRGGBB" to uint16_t RGB565 color
inline uint16_t parseHexColor(const char* hexStr) {
    if (!hexStr || hexStr[0] != '#' || strlen(hexStr) < 7) return 0x1976;
    long number = strtol(&hexStr[1], NULL, 16);
    uint8_t r = (number >> 16) & 0xFF;
    uint8_t g = (number >> 8) & 0xFF;
    uint8_t b = number & 0xFF;
    return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3);
}

// Forward declarations for drawing UI
void initDisplay();
void drawFullDeckUI(const char* profileName, const char* hexColor, const char* keyLabels[6]);
void updateTelemetryUI(int cpu, int ram);
void highlightKey(int keyId, bool pressed);
