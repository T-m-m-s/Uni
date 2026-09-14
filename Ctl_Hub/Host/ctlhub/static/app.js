let configData = null;
let currentProfileIdx = 0;
let selectedType = 'key';
let selectedId = 0;

const PIN_INFO = {
  0: "GPIO 4 (Left Top)",
  1: "GPIO 5 (Left Mid)",
  2: "GPIO 6 (Left Bot)",
  3: "GPIO 7 (Right Top)",
  4: "GPIO 15 (Right Mid)",
  5: "GPIO 16 (Right Bot)"
};

const PRESETS = {
  terminal: "$TERMINAL || foot || x-terminal-emulator || alacritty || xterm",
  browser: "xdg-open https://google.com || sensible-browser",
  discord: "vesktop || discord || flatpak run com.discordapp.Discord",
  editor: "$TERMINAL -e nvim || code || $EDITOR",
  git: "$TERMINAL -e git status",
  mute_sink: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || pactl set-sink-mute @DEFAULT_SINK@ toggle",
  mute_source: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || pactl set-source-mute @DEFAULT_SOURCE@ toggle",
  screenshot: "grim -g \"$(slurp)\" - | wl-copy || flameshot gui || spectacle -r",
  play_pause: "playerctl play-pause || spotify",
  next_track: "playerctl next",
  prev_track: "playerctl previous",
  obs: "obs || flatpak run com.obsproject.Studio"
};

async function init() {
  await loadConfig();
  await checkStatus();
  setInterval(checkStatus, 4000);
  selectKey(0);
}

async function loadConfig() {
  try {
    const res = await fetch('/api/config');
    configData = await res.json();
    renderProfileList();
    renderActiveProfile();
  } catch (err) {
    showToast(`Errore durante il caricamento della configurazione: ${err}`);
  }
}

async function checkStatus() {
  try {
    const res = await fetch('/api/status');
    const data = await res.json();
    const dot = document.getElementById('hwStatusDot');
    const text = document.getElementById('hwStatusText');
    if (data.connected) {
      dot.className = 'status-dot connected';
      text.textContent = `ESP32 Connesso (${data.port})`;
    } else {
      dot.className = 'status-dot';
      text.textContent = 'ESP32 Non Rilevato (Collega USB-C)';
    }
  } catch (e) {
    // Network retry on failure
  }
}

function renderProfileList() {
  const sel = document.getElementById('profileSelector');
  sel.innerHTML = '';
  configData.profiles.forEach((p, idx) => {
    const opt = document.createElement('option');
    opt.value = idx;
    opt.textContent = p.name;
    sel.appendChild(opt);
  });
  sel.value = currentProfileIdx;
}

function renderActiveProfile() {
  const prof = configData.profiles[currentProfileIdx];
  document.getElementById('profileNameInput').value = prof.name;
  document.getElementById('profileColorInput').value = prof.theme_color || '#1976D2';

  const header = document.getElementById('screenHeader');
  header.textContent = prof.name;
  header.style.backgroundColor = prof.theme_color;

  for (let i = 0; i < 6; i++) {
    const key = prof.keys.find(k => k.id === i) || { id: i, name: `Tasto ${i+1}`, cmd: "" };
    document.getElementById(`lbl_${i}`).textContent = key.name || `K${i+1}`;
    document.getElementById(`card_${i}`).textContent = key.name || `K${i+1}`;
    document.getElementById(`badge_${i}`).style.backgroundColor = prof.theme_color;
  }

  if (selectedType === 'key') {
    selectKey(selectedId);
  } else {
    selectKnob(selectedId);
  }
}

function selectKey(id) {
  selectedType = 'key';
  selectedId = id;
  document.querySelectorAll('.hw-button, .hw-knob').forEach(el => el.classList.remove('active'));
  document.getElementById(`btn_${id}`).classList.add('active');

  document.getElementById('keyForm').style.display = 'block';
  document.getElementById('knobForm').style.display = 'none';

  document.getElementById('inspectorTitle').textContent = `Tasto K${id + 1}`;
  document.getElementById('inspectorPin').textContent = PIN_INFO[id] || "";

  const prof = configData.profiles[currentProfileIdx];
  let key = prof.keys.find(k => k.id === id);
  if (!key) {
    key = { id: id, name: `K${id + 1}`, cmd: "" };
    prof.keys.push(key);
  }
  document.getElementById('keyLabelInput').value = key.name || "";
  document.getElementById('keyCmdInput').value = key.cmd || "";
  document.getElementById('presetSelect').value = "";
}

function selectKnob(id) {
  selectedType = 'knob';
  selectedId = id;
  document.querySelectorAll('.hw-button, .hw-knob').forEach(el => el.classList.remove('active'));
  document.getElementById(`knob_${id}`).classList.add('active');

  document.getElementById('keyForm').style.display = 'none';
  document.getElementById('knobForm').style.display = 'block';

  document.getElementById('inspectorTitle').textContent = id === 0 ? "Knob 0 (Sinistro - Audio)" : "Knob 1 (Destro - Mic)";
  document.getElementById('inspectorPin').textContent = id === 0 ? "GPIO 17, 18, 8" : "GPIO 9, 10, 11";

  const prof = configData.profiles[currentProfileIdx];
  const knobObj = prof.knobs ? prof.knobs[`knob_${id}`] : null;
  if (knobObj) {
    document.getElementById('knobRotateSelect').value = knobObj.rotate_action || (id === 0 ? 'volume_out' : 'volume_mic');
    document.getElementById('knobClickCmd').value = knobObj.click_cmd || "";
  }
}

function onProfileChange() {
  currentProfileIdx = parseInt(document.getElementById('profileSelector').value, 10);
  renderActiveProfile();
}

function onProfileNameInput(val) {
  configData.profiles[currentProfileIdx].name = val;
  document.getElementById('screenHeader').textContent = val;
  document.getElementById('profileSelector').options[currentProfileIdx].text = val;
}

function onProfileColorInput(val) {
  configData.profiles[currentProfileIdx].theme_color = val;
  document.getElementById('screenHeader').style.backgroundColor = val;
  for (let i = 0; i < 6; i++) {
    document.getElementById(`badge_${i}`).style.backgroundColor = val;
  }
}

function onKeyLabelChange(val) {
  const prof = configData.profiles[currentProfileIdx];
  let key = prof.keys.find(k => k.id === selectedId);
  if (key) {
    key.name = val;
    document.getElementById(`lbl_${selectedId}`).textContent = val || `K${selectedId + 1}`;
    document.getElementById(`card_${selectedId}`).textContent = val || `K${selectedId + 1}`;
  }
}

function onKeyCmdChange(val) {
  const prof = configData.profiles[currentProfileIdx];
  let key = prof.keys.find(k => k.id === selectedId);
  if (key) key.cmd = val;
}

function applyPreset(presetKey) {
  if (!presetKey || !PRESETS[presetKey]) return;
  const cmd = PRESETS[presetKey];
  document.getElementById('keyCmdInput').value = cmd;
  onKeyCmdChange(cmd);
}

function onKnobRotateChange(val) {
  const prof = configData.profiles[currentProfileIdx];
  if (!prof.knobs) prof.knobs = {};
  const kKey = `knob_${selectedId}`;
  if (!prof.knobs[kKey]) prof.knobs[kKey] = {};
  prof.knobs[kKey].rotate_action = val;
}

function onKnobClickCmdChange(val) {
  const prof = configData.profiles[currentProfileIdx];
  if (!prof.knobs) prof.knobs = {};
  const kKey = `knob_${selectedId}`;
  if (!prof.knobs[kKey]) prof.knobs[kKey] = {};
  prof.knobs[kKey].click_cmd = val;
}

function addNewProfile() {
  const id = "profile_" + Date.now();
  const newProf = {
    id: id,
    name: "✨ Nuovo Profilo",
    theme_color: "#E53935",
    keys: [
      { id: 0, name: "Tasto 1", cmd: "" },
      { id: 1, name: "Tasto 2", cmd: "" },
      { id: 2, name: "Tasto 3", cmd: "" },
      { id: 3, name: "Tasto 4", cmd: "" },
      { id: 4, name: "Tasto 5", cmd: "" },
      { id: 5, name: "Tasto 6", cmd: "" }
    ],
    knobs: {
      knob_0: { rotate_action: "volume_out", click_cmd: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
      knob_1: { rotate_action: "volume_mic", click_cmd: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" }
    }
  };
  configData.profiles.push(newProf);
  currentProfileIdx = configData.profiles.length - 1;
  renderProfileList();
  renderActiveProfile();
  showToast("Nuovo profilo creato!");
}

function deleteCurrentProfile() {
  if (configData.profiles.length <= 1) {
    showToast("Devi mantenere almeno un profilo attivo.");
    return;
  }
  if (!confirm("Sei sicuro di voler eliminare questo profilo?")) return;
  configData.profiles.splice(currentProfileIdx, 1);
  currentProfileIdx = 0;
  renderProfileList();
  renderActiveProfile();
  showToast("Profilo eliminato.");
}

async function saveToFile(andSync) {
  try {
    const res = await fetch('/api/config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(configData)
    });
    if (!res.ok) throw new Error("Errore durante il salvataggio");

    if (andSync) {
      showToast("Salvataggio su file completato... sincronizzazione con ESP32 in corso...");
      const syncRes = await fetch('/api/sync', { method: 'POST' });
      const syncData = await syncRes.json();
      if (syncData.success) {
        showToast("Configurazione salvata e sincronizzata con successo sull'ESP32.");
      } else {
        showToast(`Salvataggio completato, sincronizzazione ESP32 non riuscita: ${syncData.error}`);
      }
    } else {
      showToast("Configurazione salvata con successo su file.");
    }
  } catch (err) {
    showToast(`Errore: ${err.message}`);
  }
}

function showToast(msg) {
  const toast = document.getElementById('toast');
  toast.textContent = msg;
  toast.style.display = 'block';
  setTimeout(() => { toast.style.display = 'none'; }, 4000);
}

window.onload = init;
