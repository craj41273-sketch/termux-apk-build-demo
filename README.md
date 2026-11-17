# Termux APK Build Demo

A minimal, original Android app built **entirely on-device in Termux** using a toolchain whose parts were recovered during a static REA inspection of two app-builder APKs: **Sketchware Pro** and **HopWeb**.

This is *not* a clone of either app. It is a working demonstration that the same classes of tools those apps bundle in `assets/` can be used directly from a Termux shell to produce a valid, signed APK.

## The app

A single `Activity` with two buttons that describe what each inspected app ships inside its `assets/`:

- **Sketchware Pro** — `aapt2` for four ABIs, `android.jar`, 16 multidex DEX files, pre-dexed dependencies, a test signing key, and project templates.
- **HopWeb** — an APK packaging template (`android.jar` + manifest variants + DEX stubs) and a native PHP runtime with SQLite, cURL and OpenSSL.

## Toolchain

| Component | Origin |
| --- | --- |
| `javac` / JDK 21 | `pkg install openjdk-21` |
| `aapt2` (arm64) | `assets/aapt/aapt2-arm64-v8a` from Sketchware Pro v7.0.0 |
| `android.jar` | `assets/libs/android.jar.zip` from Sketchware Pro v7.0.0 |
| D8 → `classes.dex` | [R8](https://dl.google.com/dl/android/maven2/com/android/tools/r8/) 9.5.32 from Google Maven |
| Signing | [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) 1.3.0 (v1/v2/v3) |

`zipalign` is intentionally skipped: the signer's bundled copy is a glibc Linux binary that cannot run on Android, and this APK contains no native libraries so alignment is not required.

## Requirements

- Termux on Android (tested on arm64)
- `pkg install openjdk-21`
- A `tools/` directory containing `aapt2`, `android.jar`, `r8.jar`, and `uber-apk-signer.jar`, or set `TOOLS_DIR` to its location.

Download the jars with:

```sh
curl -fL -o tools/r8.jar \
  https://dl.google.com/dl/android/maven2/com/android/tools/r8/9.5.32/r8-9.5.32.jar
curl -fL -o tools/uber-apk-signer.jar \
  https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
```

`aapt2` and `android.jar` can be pulled from a Sketchware Pro release APK:

```sh
unzip -p sketchware-pro.apk assets/aapt/aapt2-arm64-v8a > tools/aapt2
unzip -p sketchware-pro.apk assets/libs/android.jar.zip > tools/android.jar.zip
unzip -o tools/android.jar.zip -d tools/
```

## Build

```sh
./build.sh
```

Output: `dist/termux-rebuild-demo.apk` (debug-signed, v1 + v2 + v3).

## Verify

```sh
aapt2 dump badging dist/termux-rebuild-demo.apk
rea inspect-apk-signature dist/termux-rebuild-demo.apk
```

## Install

The Termux shell cannot install APKs from its private data directory. Copy the APK to shared storage (grant Termux storage permission) or pull it with `adb`, then open it in a file manager.
