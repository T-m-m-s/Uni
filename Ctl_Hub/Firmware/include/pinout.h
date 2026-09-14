#pragma once

#include <Arduino.h>

// Left bank mechanical keys
#define PIN_KEY_0       4
#define PIN_KEY_1       5
#define PIN_KEY_2       6

// Right bank mechanical keys
#define PIN_KEY_3       7
#define PIN_KEY_4       15
#define PIN_KEY_5       16

const uint8_t KEY_PINS[6] = {
    PIN_KEY_0,
    PIN_KEY_1,
    PIN_KEY_2,
    PIN_KEY_3,
    PIN_KEY_4,
    PIN_KEY_5
};

// Left rotary encoder (Audio output / volume / mute / profile switch)
#define PIN_KNOB0_CLK   17
#define PIN_KNOB0_DT    18
#define PIN_KNOB0_SW    8

// Right rotary encoder (Microphone / mute)
#define PIN_KNOB1_CLK   9
#define PIN_KNOB1_DT    10
#define PIN_KNOB1_SW    11

// SPI TFT display bus (FSPI host)
#define PIN_TFT_MOSI    13
#define PIN_TFT_SCK     12
#define PIN_TFT_CS      14
#define PIN_TFT_DC      21
#define PIN_TFT_RST     38
#define PIN_TFT_BLK     48
#define PIN_TFT_MISO    1

#define DEBOUNCE_MS         35
#define KNOB_DEBOUNCE_MS    45
#define LONG_PRESS_MS       700
#define TELEMETRY_TIMEOUT   5000
