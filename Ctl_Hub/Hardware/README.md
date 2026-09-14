# Ctl_Hub - Hardware & Mechanical Design

This directory contains the physical enclosure designs, CAD source files, and component specifications for the **Ctl_Hub** hardware console.

---

## 1. Bill of Materials (BOM)

| Component | Quantity | Specification / Notes |
| :--- | :---: | :--- |
| **Microcontroller** | 1 | ESP32-S3 DevKitC-1 N16R8 (16MB Flash, 8MB Octal PSRAM, USB-C) |
| **Display** | 1 | 3.2" (or 3.5") SPI TFT LCD ILI9341 controller (320x240 resolution) |
| **Mechanical Switches** | 6 | Cherry MX (Brown tactile recommended) or compatible mechanical keyboard switches |
| **Rotary Encoders** | 2 | EC11 incremental rotary encoders with integrated push switch (e.g. KY-040 module or bare) |
| **Knob Caps** | 2 | Aluminum or 3D-printed D-shaft / knurled encoder knobs |
| **Fasteners** | 4-8 | M3 screws (6mm to 10mm length) and brass heat-set inserts |
| **Wiring** | - | 28-30 AWG stranded wire or ribbon cable (or custom perfboard) |

---

## 2. 3D CAD Files (`3dDesign/`)

The 3D models are fully parametric and authored in [OpenSCAD](https://openscad.org/):

* **[`3dDesign/StreamDeck_45Deg_3.2Display.scad`](3dDesign/StreamDeck_45Deg_3.2Display.scad):** Primary 45-degree angled desktop console specifically engineered for 3.2" SPI TFT displays (MSP3218), 6 mechanical switches, 2 rotary encoders, and 9x7 cm perfboard mounting.
* **[`3dDesign/StreamDeck_Rectangular_Stand.scad`](3dDesign/StreamDeck_Rectangular_Stand.scad):** Low-profile 20-degree tilt desktop stand variant for 3.2" displays and 5x7 cm perfboards.

---

## 3. 3D Printing Recommendations

* **Material:** PLA, PETG, or ABS/ASA.
* **Layer Height:** 0.20 mm (0.16 mm recommended for faceplate text and fine bevels).
* **Infill:** 15% - 25% (Gyroid or Grid pattern).
* **Wall / Perimeters:** At least 3 perimeters (approx. 1.2 mm wall thickness).
* **Supports:** Needed only for overhangs around the display bezel and USB-C port cutout.

---

## 4. Electrical Pinout Reference

For complete pin-to-pin breadboard and PCB wiring diagrams, see:
* **[docs/PINOUT_AND_WIRING.md](../docs/PINOUT_AND_WIRING.md)**
