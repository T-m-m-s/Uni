#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>
#include "config_manager.h"
#include "display_driver.h"

class SerialProtocol {
public:
    void sendExec(int btnId, const char* cmd) {
        JsonDocument doc;
        doc["event"] = "exec";
        doc["btn_id"] = btnId;
        doc["cmd"] = cmd;
        serializeJson(doc, Serial);
        Serial.println();
    }

    void sendKnobDelta(int knobId, int delta) {
        JsonDocument doc;
        doc["event"] = "knob";
        doc["id"] = knobId;
        doc["delta"] = delta;
        serializeJson(doc, Serial);
        Serial.println();
    }

    void sendKnobBtn(int knobId) {
        JsonDocument doc;
        doc["event"] = "knob_btn";
        doc["id"] = knobId;
        serializeJson(doc, Serial);
        Serial.println();
    }

    void sendProfileChanged(const char* profId) {
        JsonDocument doc;
        doc["event"] = "profile_changed";
        doc["active_profile"] = profId;
        serializeJson(doc, Serial);
        Serial.println();
    }

    void sendConfigDump() {
        Serial.print("{\"action\":\"config_data\",");
        String cfg = configMgr.getConfigString();
        // Skip leading '{'
        if (cfg.startsWith("{")) {
            Serial.print(cfg.substring(1));
        } else {
            Serial.print("\"data\":");
            Serial.print(cfg);
            Serial.print("}");
        }
        Serial.println();
    }

    void handleIncoming(const String& line) {
        if (line.length() < 2) return;

        JsonDocument doc;
        DeserializationError err = deserializeJson(doc, line);
        if (err) return;

        const char* action = doc["action"] | "";

        if (strcmp(action, "get_config") == 0) {
            sendConfigDump();
        } else if (strcmp(action, "reinit_display") == 0) {
            Serial.println("{\"log\":\"[DISPLAY] Host requested display re-initialization...\"}");
            initDisplay();
            const char* labels[6];
            for (int i = 0; i < 6; i++) {
                labels[i] = configMgr.getKeyLabel(i);
            }
            drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
            Serial.println("{\"log\":\"[DISPLAY] Display re-initialized and redrawn successfully.\"}");
        } else if (strcmp(action, "telemetry") == 0) {
            int cpu = doc["cpu"] | 0;
            int ram = doc["ram"] | 0;
            updateTelemetryUI(cpu, ram);
        } else if (strcmp(action, "save_config") == 0) {
            JsonObject newCfg = doc["config"].as<JsonObject>();
            String serialized;
            serializeJson(newCfg, serialized);
            bool ok = configMgr.saveNewConfig(serialized);
            if (ok) {
                Serial.println("{\"status\":\"saved_ok\"}");
                const char* labels[6];
                for (int i = 0; i < 6; i++) {
                    labels[i] = configMgr.getKeyLabel(i);
                }
                drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
            } else {
                Serial.println("{\"status\":\"error_saving\"}");
            }
        } else if (strcmp(action, "next_profile") == 0) {
            configMgr.nextProfile();
            const char* labels[6];
            for (int i = 0; i < 6; i++) {
                labels[i] = configMgr.getKeyLabel(i);
            }
            drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
            sendProfileChanged(configMgr.getProfileId());
        } else if (strcmp(action, "prev_profile") == 0) {
            configMgr.prevProfile();
            const char* labels[6];
            for (int i = 0; i < 6; i++) {
                labels[i] = configMgr.getKeyLabel(i);
            }
            drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
            sendProfileChanged(configMgr.getProfileId());
        } else if (strcmp(action, "set_profile") == 0) {
            bool changed = false;
            if (doc["target"].is<int>()) {
                changed = configMgr.setProfileIndex(doc["target"].as<int>());
            } else if (doc["target"].is<const char*>()) {
                changed = configMgr.setProfileByIdOrName(doc["target"].as<const char*>());
            }
            if (changed) {
                const char* labels[6];
                for (int i = 0; i < 6; i++) {
                    labels[i] = configMgr.getKeyLabel(i);
                }
                drawFullDeckUI(configMgr.getProfileName(), configMgr.getProfileColor(), labels);
                sendProfileChanged(configMgr.getProfileId());
            } else {
                Serial.println("{\"status\":\"profile_not_found\"}");
            }
        }
    }
};

extern SerialProtocol protocol;
