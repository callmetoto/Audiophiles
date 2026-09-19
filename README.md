# Audiophile 24-bit FLAC to WAV Batch Toolkit v4.0 🎵🔊

A lightweight, native Windows interactive batch (`.bat`) script designed for audio enthusiasts who need to seamlessly convert high-resolution **24-bit FLAC** music archives into uncompressed **24-bit PCM WAV** formats with **zero downsampling or quality loss**. 

It features an integrated keyboard-navigable graphical directory browser and an automated structural format verification analysis tool.

---

## Project Roadmap & Ecosystem 🗺️

🚀 **This toolkit marks the official first project release under this repository.** 

This repository is designed to serve as an evolving, centralized ecosystem for premium, lightweight audiophile utility automation tools. Moving forward, **additional sub-projects will be introduced right here**, focusing on:
* Advanced multi-format media tag and metadata mapping tools.
* Automated sample-rate validation checkers and upsample detection utilities.
* Multi-threaded conversion blocks and deployment configurations.

Make sure to **Star** and **Watch** this space to stay updated as our toolkit lineup expands!

---

## Authors & Project Credits 👥

* **Project Lead / Main Author:** **Toto** (GitHub)
* **Development Assistant:** **Gemini** (AI Collaborator)

---

## Key Features ✨

* **Bit-Perfect 24-Bit Transcoding:** Explicitly targets the `pcm_s24le` encoder map to preserve master audio dynamics without compressing or downsampling to standard 16-bit.
* **Keyboard-Navigable Folder Browsing:** Implements an inline PowerShell wrapper allowing you to navigate drive paths completely via **Arrow keys, Tab, and Enter** instead of manually typing long folders.
* **Comprehensive Quality Auditing (Mode 2):** Scans *every single file* in a chosen directory and outputs an instant summary checking whether all tracks match identically in codec profile and sample rate.
* **Removes Path Formatting Noise:** Automatically handles trailing/leading quotation marks (`"C:\path"`) seamlessly behind the scenes if folders are manually dropped in.

---

## Prerequisites 🛠️

This script requires **FFmpeg** and **FFprobe** to be globally available in your system path environment variables:

1. Download the Windows pre-compiled distribution package from [gyan.dev](https://gyan.dev).
2. Extract the archive and copy the folder contents to `C:\ffmpeg`.
3. Add `C:\ffmpeg\bin` to your user profile environment **Path** variable settings.
4. Open a fresh Command Prompt and verify using: `ffmpeg -version`.

---

## How to Use 🚀

1. Download or clone `convert_audiophile_v4.bat` from this repository.
2. Double-click the file to open the toolkit console.
3. Select an operation profile configuration:
   * **Option `1`:** Select a source FLAC directory and destination path via the visual browser menu window to run conversions.
   * **Option `2`:** Run a quick quality analysis audit on any folder to verify track alignment (`pcm_s24le` @ `96000 Hz / 192000 Hz`).

---

## System Verification Blueprint 📋

When running the quality inspection sweep, a bit-perfect extraction will report:
* **Codec Profile:** `pcm_s24le`
* **Sample Format Resolution:** `s32 (24 bit)`
* **Sampling Metric Sample Rates:** `96000 Hz` / `192000 Hz` (Preserved source master frequencies)
* **High Bitrate Stream Allocation:** `~4608 kb/s`
