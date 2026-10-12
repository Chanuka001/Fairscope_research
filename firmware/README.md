# Firmware (IoT Sensor Probe)

Owned by **Member B**. Contains the microcontroller firmware, pinouts, and communication protocols for the handheld FairScope sensor probe.

## Hardware Components

- **Microcontroller:** ESP32 (Wi-Fi & Bluetooth Low Energy)
- **Skin Moisture Sensor:** Capacitive or contact bio-impedance hydration sensor
- **Spectral / Optical Sensor:** Multi-channel color or miniature spectral sensor (e.g., AS7262 or TCS34725)
- **Power:** Rechargeable LiPo battery with charging module

## Directory Structure

```text
firmware/
├── src/            # ESP32 C++/Arduino/ESP-IDF source code
└── README.md       # Hardware specification and wiring guides
```

## Data Transmission Protocol

The probe communicates with the FairScope Flutter application via BLE (Bluetooth Low Energy) using custom GATT characteristics or via local Wi-Fi UDP/HTTP sockets:

- **Service UUID:** Configured in `src/`
- **Data Payload:** JSON or binary struct with timestamp, moisture reading, and multi-wavelength spectral values.
