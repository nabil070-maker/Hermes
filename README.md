# Hermes Portable

> A self-contained Windows portable environment for running **Hermes Agent** from a local folder or USB drive — without requiring a system-wide Python, Node.js, Git, or uv installation.

**Hermes Portable** packages the runtime components and launch environment needed to run [NousResearch/Hermes Agent](https://github.com/NousResearch/hermes-agent) in a portable Windows setup.

The project is designed around a simple principle:

**Download once → configure locally → run anywhere on Windows.**

---

## ✨ Features

* 🪟 **Windows 10 / Windows 11**
* 💾 Designed for **USB and portable storage**
* 🐍 Portable **Python 3.11.16**
* 🟢 Portable **Node.js 26.8.2**
* 🔧 Portable **Git 2.55.0.5**
* ⚡ Portable **uv 0.12.13**
* 🔎 Portable **ripgrep 15.2.0**
* 📦 Hermes environment created and managed through **uv**
* 🔒 Avoids relying on the host system's Python environment
* 🔄 Drive-letter independent
* 🧹 Temporary download cache is cleaned after setup
* 🎨 Includes a lightweight interactive PowerShell launcher
* 🛠️ Built-in setup, reset, diagnostics, and advanced controls
* 🚫 No system-wide dependency installation required

---

## 🧠 About Hermes Agent

This project is a **portable packaging and launcher layer** for the Hermes Agent project maintained by **NousResearch**.

The underlying AI agent is not reimplemented here. Hermes Portable provides the surrounding Windows runtime and portability layer needed to make Hermes easier to carry between machines.

Original project:

**NousResearch / Hermes Agent**
https://github.com/NousResearch/hermes-agent

Please refer to the upstream Hermes Agent project for its features, documentation, configuration, supported providers, and development information.

---

## 📁 Project Structure

After the first successful setup, the directory will look approximately like this:

```text
Hermes\
│
├── launch.bat
│
├── scripts\
│   ├── setup.ps1
│   ├── reset.ps1
│   └── shell.ps1
│
├── runtime\
│   ├── python\
│   ├── node\
│   ├── git\
│   ├── uv\
│   └── ripgrep\
│
├── hermes-agent\
│   ├── .venv\
│   │   └── Scripts\
│   │       └── hermes.exe
│   ├── pyproject.toml
│   ├── uv.lock
│   └── ...
│
├── data\
│
└── cache\
```

The `runtime` directory contains the portable tools used by the project.

The `hermes-agent` directory contains the upstream Hermes Agent source and its `uv`-managed Python environment.

---

## 🚀 Quick Start

### 1. Download the project

Copy or clone this repository to a location of your choice.

For example:

```text
D:\Hermes\
```

or directly onto a USB drive:

```text
E:\Hermes\
```

### 2. Launch

Run:

```text
launch.bat
```

The launcher automatically checks whether Hermes has already been installed.

On the first run, it starts the portable setup process.

After setup is complete, the Hermes Portable shell starts automatically.

---

## ⚙️ First-Time Setup

The setup process automatically prepares:

1. Portable Python
2. Portable Git
3. Portable Node.js
4. Portable uv
5. Portable ripgrep
6. Hermes Agent source
7. Hermes Agent's Python environment

The project does **not** depend on the Python, Git, Node.js, or uv installations already present on the host computer.

---

## 🐍 Python Environment

Hermes Portable uses a standalone Python 3.11 runtime.

The Python runtime is stored inside:

```text
runtime\python\
```

The Hermes environment itself is created inside:

```text
hermes-agent\.venv\
```

The final Hermes executable is:

```text
hermes-agent\.venv\Scripts\hermes.exe
```

The portable Python runtime is explicitly provided to `uv` so that the host computer's Python installation is not accidentally used.

---

## ⚡ Dependency Management

Python dependencies are handled by **uv**.

The setup uses:

```powershell
uv sync
```

This allows `uv` to create and synchronize the Hermes project's virtual environment from the project's configuration and lockfile.

The project intentionally does **not** use:

```powershell
pip install
```

or:

```powershell
python -m venv
```

The Hermes environment is therefore created and maintained through the project's `uv` workflow.

---

## 🧰 Portable Runtime Components

The project bundles the following tools:

| Component |  Version | Purpose                                    |
| --------- | -------: | ------------------------------------------ |
| Python    |  3.11.16 | Hermes Python runtime                      |
| Node.js   |   26.8.2 | Node-based tooling                         |
| Git       | 2.55.0.5 | Source management                          |
| uv        |  0.12.13 | Python environment & dependency management |
| ripgrep   |   15.2.0 | Fast file/text searching                   |

These components live under:

```text
runtime\
```

and are added to the process environment when Hermes Portable starts.

---

## 🖥️ Portable Shell

The included PowerShell shell provides a simple interface for working with Hermes.

### Main menu

```text
[1] Start Hermes
[2] Hermes TUI
[3] Advanced
[4] Home Folder
[5] Clear Screen
[0] Exit
```

The shell uses the installed Hermes executable directly from the portable environment.

### Hermes TUI

Hermes exposes its TUI through the `--tui` option:

```powershell
hermes --tui
```

It is **not** a `tui` subcommand.

---

## 🛠️ Advanced Tools

The Advanced menu provides additional maintenance options, including:

* Hermes Doctor
* Hermes Setup
* Hermes Update
* Reset Hermes
* Open Hermes directory
* Open data directory
* Open a portable PowerShell environment

The portable PowerShell environment includes the project's runtime paths, allowing commands such as:

```powershell
hermes
```

```powershell
hermes --version
```

```powershell
hermes doctor
```

```powershell
uv --version
```

```powershell
python --version
```

```powershell
node --version
```

```powershell
rg --version
```

to work without requiring those tools to be installed globally.

---

## 🔄 Reset

If the Hermes Python environment becomes damaged or needs to be rebuilt, use:

```text
Advanced → Reset Hermes
```

The reset process removes:

```text
hermes-agent\.venv\
```

and recreates the environment using:

```powershell
uv sync
```

Portable runtime components are not removed.

---

## 💾 USB Portability

Hermes Portable is designed so the entire directory can be moved between drive letters.

For example:

```text
E:\Hermes\
```

can become:

```text
D:\Hermes\
```

without requiring the paths to be manually edited.

The launcher and PowerShell scripts calculate their paths relative to the project directory.

This makes the project suitable for:

* USB flash drives
* External SSDs
* Portable development environments
* Secondary drives
* Temporary Windows environments

---

## 🔐 Host Environment Isolation

The launcher clears the host `VIRTUAL_ENV` variable before starting the Hermes environment.

This prevents an already-active Python virtual environment on the host computer from interfering with Hermes Portable.

The project also sets:

```text
PYTHONNOUSERSITE=1
```

to reduce accidental use of Python packages installed in the host user's profile.

---

## 🧹 Cache Cleanup

Downloaded setup archives are temporarily stored in:

```text
cache\
```

The cache is cleaned after a successful installation.

The portable runtime and Hermes environment remain untouched.

This keeps the final portable installation smaller and avoids unnecessarily carrying installation archives around.

---

## 📦 Installation Philosophy

Hermes Portable intentionally keeps the architecture straightforward:

```text
Portable runtimes
       ↓
Portable environment
       ↓
uv sync
       ↓
Hermes .venv
       ↓
Hermes Agent
       ↓
Portable shell
```

There is no system-wide installer and no requirement to modify the Windows installation.

---

## ⚠️ Important Notes

### Hermes Agent

Hermes Portable is not the upstream Hermes Agent project.

It is a portability layer built around the project maintained by **NousResearch**.

For Hermes-specific functionality, configuration, providers, models, skills, and upstream development, consult the official Hermes Agent repository.

### Windows PowerShell

The included scripts are designed for:

```text
Windows PowerShell 5.1
```

They are not dependent on PowerShell 7 / `pwsh`.

### Storage Performance

Portable applications running directly from inexpensive USB flash drives can experience slower startup and file-access performance than installations on internal SSDs or fast external SSDs.

For the best experience, use a fast USB 3.x drive or external SSD.

---

## 📜 License

This repository's licensing applies to the portable launcher/scripts and project-specific code contained here.

Hermes Agent and its dependencies remain subject to their respective upstream licenses.

See the **NousResearch/Hermes Agent** repository for the license and terms applicable to Hermes itself.

---

## 🙏 Credits

Special thanks to:

* **[NousResearch](https://github.com/NousResearch)** — creators and maintainers of Hermes Agent
* **Astral** — `uv` and Python tooling
* **Git for Windows** — portable Git tooling
* **Node.js** — Node.js runtime
* **BurntSushi** — ripgrep

This project would not exist without the upstream open-source work that makes Hermes and its supporting ecosystem possible.

---

## 📌 Project Status

**Status: Stable / Working**

The portable environment has been designed and tested around the current project structure and provides:

* Portable runtimes
* Automatic setup
* `uv`-managed Hermes environment
* Portable launcher
* Interactive shell
* Advanced maintenance tools
* Reset functionality
* Drive-letter-independent paths

The project is intended to remain simple, portable, and easy to move between Windows machines.

---

## ⭐ If You Find This Useful

If Hermes Portable helps you run Hermes Agent conveniently from a USB drive or portable storage, consider starring the repository and supporting the upstream **NousResearch Hermes Agent** project as well.
