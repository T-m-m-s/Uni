#pragma once

#include <Arduino.h>
#include <ArduinoJson.h>
#include <LittleFS.h>
#include <Preferences.h>

#define CONFIG_FILE_PATH "/config.json"

struct KeyConfig {
    int id;
    String name;
    String cmd;
};

struct KnobConfig {
    String rotate_action;
    String click_cmd;
};

struct ProfileConfig {
    String id;
    String name;
    String theme_color;
    KeyConfig keys[6];
    KnobConfig knob0;
    KnobConfig knob1;
};

class ConfigManager {
public:
    JsonDocument doc;
    Preferences prefs;
    int active_profile_index = 0;
    int profile_count = 0;

    bool begin() {
        prefs.begin("ctl_hub", false);
        active_profile_index = prefs.getInt("active_prof", 0);

        if (!LittleFS.begin(true)) {
            Serial.println("{\"log\":\"LittleFS Mount Failed, using in-memory fallback\"}");
            loadFallback();
            return false;
        }

        if (!loadFromFile(CONFIG_FILE_PATH)) {
            Serial.println("{\"log\":\"config.json missing or invalid, loading fallback and saving\"}");
            loadFallback();
            saveToFile(CONFIG_FILE_PATH);
        }

        sanitizeProfileIndex();
        return true;
    }

    void sanitizeProfileIndex() {
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        profile_count = profiles.size();
        if (profile_count == 0) {
            loadFallback();
            profiles = doc["profiles"].as<JsonArray>();
            profile_count = profiles.size();
        }
        if (active_profile_index < 0 || active_profile_index >= profile_count) {
            active_profile_index = 0;
        }
    }

    bool loadFromFile(const char* path) {
        if (!LittleFS.exists(path)) return false;
        File file = LittleFS.open(path, "r");
        if (!file) return false;

        DeserializationError error = deserializeJson(doc, file);
        file.close();
        if (error) {
            Serial.print("{\"log\":\"deserializeJson failed: ");
            Serial.print(error.c_str());
            Serial.println("\"}");
            return false;
        }
        return true;
    }

    bool saveToFile(const char* path) {
        File file = LittleFS.open(path, "w");
        if (!file) return false;
        serializeJson(doc, file);
        file.close();
        return true;
    }

    bool saveNewConfig(const String& newJson) {
        JsonDocument newDoc;
        DeserializationError err = deserializeJson(newDoc, newJson);
        if (err) return false;

        doc = newDoc;
        sanitizeProfileIndex();
        bool ok = saveToFile(CONFIG_FILE_PATH);
        return ok;
    }

    String getConfigString() {
        String output;
        serializeJson(doc, output);
        return output;
    }

    JsonObject getCurrentProfile() {
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        if (active_profile_index >= 0 && active_profile_index < (int)profiles.size()) {
            return profiles[active_profile_index];
        }
        return profiles[0];
    }

    const char* getProfileId() {
        JsonObject prof = getCurrentProfile();
        return prof["id"] | "general";
    }

    const char* getProfileName() {
        JsonObject prof = getCurrentProfile();
        return prof["name"] | "Generale";
    }

    const char* getProfileColor() {
        JsonObject prof = getCurrentProfile();
        return prof["theme_color"] | "#1976D2";
    }

    const char* getKeyCmd(int keyId) {
        JsonObject prof = getCurrentProfile();
        JsonArray keys = prof["keys"].as<JsonArray>();
        for (JsonObject k : keys) {
            if ((k["id"] | -1) == keyId) {
                return k["cmd"] | "";
            }
        }
        return "";
    }

    const char* getKeyLabel(int keyId) {
        JsonObject prof = getCurrentProfile();
        JsonArray keys = prof["keys"].as<JsonArray>();
        for (JsonObject k : keys) {
            if ((k["id"] | -1) == keyId) {
                return k["name"] | "";
            }
        }
        return "";
    }

    const char* getKnobClickCmd(int knobId) {
        JsonObject prof = getCurrentProfile();
        JsonObject knobs = prof["knobs"].as<JsonObject>();
        if (knobId == 0) {
            return knobs["knob_0"]["click_cmd"] | "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        } else {
            return knobs["knob_1"]["click_cmd"] | "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        }
    }

    void nextProfile() {
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        if (profiles.size() == 0) return;
        active_profile_index = (active_profile_index + 1) % profiles.size();
        prefs.putInt("active_prof", active_profile_index);
    }

    void prevProfile() {
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        if (profiles.size() == 0) return;
        active_profile_index = (active_profile_index - 1 + profiles.size()) % profiles.size();
        prefs.putInt("active_prof", active_profile_index);
    }

    bool setProfileIndex(int index) {
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        if (index >= 0 && index < (int)profiles.size()) {
            active_profile_index = index;
            prefs.putInt("active_prof", active_profile_index);
            return true;
        }
        return false;
    }

    bool setProfileByIdOrName(const char* query) {
        if (!query || strlen(query) == 0) return false;
        JsonArray profiles = doc["profiles"].as<JsonArray>();
        for (size_t i = 0; i < profiles.size(); i++) {
            const char* id = profiles[i]["id"] | "";
            const char* name = profiles[i]["name"] | "";
            if (strcasecmp(id, query) == 0 || strcasecmp(name, query) == 0) {
                active_profile_index = (int)i;
                prefs.putInt("active_prof", active_profile_index);
                return true;
            }
        }
        return false;
    }

    void loadFallback() {
        doc.clear();
        doc["version"] = 1;
        doc["active_profile"] = "general";
        JsonArray profiles = doc["profiles"].to<JsonArray>();

        JsonObject p1 = profiles.add<JsonObject>();
        p1["id"] = "general";
        p1["name"] = "🌐 Generale";
        p1["theme_color"] = "#1976D2";
        JsonArray k1 = p1["keys"].to<JsonArray>();
        addKey(k1, 0, "Browser", "xdg-open https://google.com || sensible-browser");
        addKey(k1, 1, "Discord", "vesktop || discord || flatpak run com.discordapp.Discord");
        addKey(k1, 2, "Terminale", "$TERMINAL || foot || x-terminal-emulator");
        addKey(k1, 3, "Mute Audio", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
        addKey(k1, 4, "Mute Mic", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
        addKey(k1, 5, "Screenshot", "grim -g \"$(slurp)\" - | wl-copy || flameshot gui");
        JsonObject knobs1 = p1["knobs"].to<JsonObject>();
        knobs1["knob_0"]["rotate_action"] = "volume_out";
        knobs1["knob_0"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        knobs1["knob_1"]["rotate_action"] = "volume_mic";
        knobs1["knob_1"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        JsonObject p2 = profiles.add<JsonObject>();
        p2["id"] = "coding";
        p2["name"] = "💻 Dev & Uni";
        p2["theme_color"] = "#388E3C";
        JsonArray k2 = p2["keys"].to<JsonArray>();
        addKey(k2, 0, "Neovim", "$TERMINAL -e nvim || code || $EDITOR");
        addKey(k2, 1, "Git Status", "$TERMINAL -e git status");
        addKey(k2, 2, "Terminale Dev", "$TERMINAL || foot || x-terminal-emulator");
        addKey(k2, 3, "GitHub Repo", "xdg-open https://github.com/T-m-m-s/Uni");
        addKey(k2, 4, "Mute Mic", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
        addKey(k2, 5, "Screenshot", "grim -g \"$(slurp)\" - | wl-copy || flameshot gui");
        JsonObject knobs2 = p2["knobs"].to<JsonObject>();
        knobs2["knob_0"]["rotate_action"] = "volume_out";
        knobs2["knob_0"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        knobs2["knob_1"]["rotate_action"] = "volume_mic";
        knobs2["knob_1"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        JsonObject p3 = profiles.add<JsonObject>();
        p3["id"] = "media";
        p3["name"] = "🎵 Media & Stream";
        p3["theme_color"] = "#7B1FA2";
        JsonArray k3 = p3["keys"].to<JsonArray>();
        addKey(k3, 0, "Play / Pausa", "playerctl play-pause || spotify");
        addKey(k3, 1, "Traccia Succ.", "playerctl next");
        addKey(k3, 2, "Traccia Prec.", "playerctl previous");
        addKey(k3, 3, "Mute Audio", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
        addKey(k3, 4, "Mute Mic", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
        addKey(k3, 5, "OBS Studio", "obs || flatpak run com.obsproject.Studio");
        JsonObject knobs3 = p3["knobs"].to<JsonObject>();
        knobs3["knob_0"]["rotate_action"] = "volume_out";
        knobs3["knob_0"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        knobs3["knob_1"]["rotate_action"] = "volume_mic";
        knobs3["knob_1"]["click_cmd"] = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    }

private:
    void addKey(JsonArray arr, int id, const char* name, const char* cmd) {
        JsonObject k = arr.add<JsonObject>();
        k["id"] = id;
        k["name"] = name;
        k["cmd"] = cmd;
    }
};

extern ConfigManager configMgr;
