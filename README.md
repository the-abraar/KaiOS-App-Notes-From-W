
# KaiOS-App-Notes-From-W

Trying KaiOS development with Nokia 8000 4g.

## 📱 Demo

Here is what the app looks like -

![App Screenshot](screenshot.jpg)

### Video Preview

<video src="demo/screenrecording.mov" width="240" controls>
  Your browser does not support the video tag.
</video>

*(If the video player above doesn't load, [click here to watch the demo video](demo/screenrecording.mov))*

---

## 🚀 How to Install (macOS M1-4)

Since modern browsers dropped support for legacy Firefox OS tools, we use **Waterfox Classic** and **ADB**.

### 1. Prerequisites

* **Device:** Nokia 8000 4G (KaiOS 2.5.4)
* **Software:**
  * [Waterfox Classic](https://classic.waterfox.net/)
  * Android Platform Tools (`brew install android-platform-tools`)

### 2. Connect the Phone

1. Connect the phone to your Mac via USB.
2. Type `*#*#33284#*#*` (like typing debug) on the phone keypad to enable the Debug bug icon.
3. Open Terminal and run the port forwarder:

    ```bash
        adb forward tcp:6000 localfilesystem:/data/local/debugger-socket
    ```

### 3. Install via WebIDE

1. Open **Waterfox Classic**.
2. Press `Shift + F8` (or Tools > Web Developer > WebIDE).
3. Click **Remote Runtime** on the right (ensure it is set to `localhost:6000`).
4. Accept the connection prompt on your phone screen.
5. Click **Open Packaged App** and select this project folder.
6. Click the **Play (Triangle)** button to install and launch.

---

## 🎮 Controls

* **Center Key (Enter):** Load a new random Waifu picture and quote.
* **End Call Key:** Exit the app.
* **Others:** I can detect other keys too, but I'm not using them rn.

## 🛠 Project Structure

* `img/`: Contains the 240x320 wallpapers.
* `app.js`: Logic for randomizing content.
* `manifest.webapp`: KaiOS app configuration.
