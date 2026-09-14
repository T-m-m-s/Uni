#include <Arduino.h>
#include "pinout.h"
#include "config_manager.h"
#include "protocol.h"
#include "display_driver.h"

ConfigManager configMgr;
SerialProtocol protocol;

static bool keyLastState[6] = {HIGH, HIGH, HIGH, HIGH, HIGH, HIGH};
static uint32_t keyLastChange[6] = {0};

// Quadrature decoding state table
static const int8_t ROTARY_STEPS[] = {
    0, -1,  1,  0,
    1,  0,  0, -1,
   -1,  0,  0,  1,
    0,  1, -1,  0
};

struct EncoderState {
    uint8_t pinClk;
    uint8_t pinDt;
    uint8_t pinSw;
    uint8_t prevCode;
    int8_t  accum;
    bool    swStableState;
    bool    swLastReading;
    uint32_t swDebounceTime;
    uint32_t swPressStart;
    bool    longPressTriggered;
};

static EncoderState encoders[2] = {
    {PIN_KNOB0_CLK, PIN_KNOB0_DT, PIN_KNOB0_SW, 0, 0, HIGH, HIGH, 0, 0, false},
    {PIN_KNOB1_CLK, PIN_KNOB1_DT, PIN_KNOB1_SW, 0, 0, HIGH, HIGH, 0, 0, false}
};

static void refreshScreenFromConfig() {
    const char* labels[6];
    for (int i = 0; i < 6; i++) {
        labels[i] = configMgr.getKeyLabel(i);
    }
    drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
}

void setup() {
    Serial.begin(115200);
    delay(200);

    for (int i = 0; i < 6; i++) {
        pinMode(KEY_PINS[i], INPUT_PULLUP);
    }

    for (int i = 0; i < 2; i++) {
        pinMode(encoders[i].pinClk, INPUT_PULLUP);
        pinMode(encoders[i].pinDt, INPUT_PULLUP);
        pinMode(encoders[i].pinSw, INPUT_PULLUP);

        uint8_t clk = digitalRead(encoders[i].pinClk);
        uint8_t dt  = digitalRead(encoders[i].pinDt);
        encoders[i].prevCode = (clk << 1) | dt;
        encoders[i].swStableState = digitalRead(encoders[i].pinSw);
        encoders[i].swLastReading = encoders[i].swStableState;
        encoders[i].swDebounceTime = millis();
    }

    Serial.println("{\"log\":\"[SYSTEM] Ctl_Hub firmware starting...\"}");
    configMgr.begin();
    initDisplay();
    refreshScreenFromConfig();
    Serial.println("{\"log\":\"[SYSTEM] Display, keys and encoders ready.\"}");

    protocol.sendProfileChanged(configMgr.getProfileId());
}

void loop() {
    const uint32_t now = millis();

    // Process serial packets from host
    if (Serial.available()) {
        String line = Serial.readStringUntil('\n');
        line.trim();
        if (line.length() > 0) {
            protocol.handleIncoming(line);
        }
    }

    // Debounced mechanical key matrix scan
    for (int i = 0; i < 6; i++) {
        const bool reading = digitalRead(KEY_PINS[i]);
        if (reading != keyLastState[i]) {
            if ((now - keyLastChange[i]) > DEBOUNCE_MS) {
                keyLastState[i] = reading;
                keyLastChange[i] = now;

                if (reading == LOW) {
                    highlightKey(i, true);
                    protocol.sendExec(i, configMgr.getKeyCmd(i));
                } else {
                    highlightKey(i, false);
                }
            }
        }
    }

    // Rotary encoder quadrature decoding and switch detection
    for (int i = 0; i < 2; i++) {
        const uint8_t clk = digitalRead(encoders[i].pinClk);
        const uint8_t dt  = digitalRead(encoders[i].pinDt);
        const uint8_t currCode = (clk << 1) | dt;

        if (currCode != encoders[i].prevCode) {
            const uint8_t index = (encoders[i].prevCode << 2) | currCode;
            encoders[i].accum += ROTARY_STEPS[index & 0x0F];
            encoders[i].prevCode = currCode;

            // Four quadrature state transitions per mechanical detent
            if (encoders[i].accum >= 4) {
                protocol.sendKnobDelta(i, +1);
                encoders[i].accum = 0;
            } else if (encoders[i].accum <= -4) {
                protocol.sendKnobDelta(i, -1);
                encoders[i].accum = 0;
            }
        }

        // Debounced encoder switch detection with crosstalk spike rejection
        const bool swRaw = digitalRead(encoders[i].pinSw);

        if (swRaw != encoders[i].swLastReading) {
            encoders[i].swLastReading = swRaw;
            encoders[i].swDebounceTime = now;
        }

        if ((now - encoders[i].swDebounceTime) >= KNOB_DEBOUNCE_MS) {
            if (swRaw != encoders[i].swStableState) {
                encoders[i].swStableState = swRaw;

                if (encoders[i].swStableState == LOW) {
                    encoders[i].swPressStart = now;
                    encoders[i].longPressTriggered = false;
                } else {
                    const uint32_t pressDuration = now - encoders[i].swPressStart;
                    // Require at least 45ms of stable press to filter rotation crosstalk spikes
                    if (!encoders[i].longPressTriggered && pressDuration >= 45 && pressDuration < LONG_PRESS_MS) {
                        protocol.sendKnobBtn(i);
                    }
                }
            }
        }

        if (encoders[i].swStableState == LOW && !encoders[i].longPressTriggered) {
            if ((now - encoders[i].swPressStart) >= LONG_PRESS_MS) {
                encoders[i].longPressTriggered = true;
                if (i == 0) {
                    configMgr.nextProfile();
                    refreshScreenFromConfig();
                    protocol.sendProfileChanged(configMgr.getProfileId());
                } else if (i == 1) {
                    Serial.println("{\"log\":\"[DISPLAY] Hardware re-init triggered by Knob 1 long-press...\"}");
                    initDisplay();
                    refreshScreenFromConfig();
                    Serial.println("{\"log\":\"[DISPLAY] Hardware re-init completed.\"}");
                }
            }
        }
    }
}
