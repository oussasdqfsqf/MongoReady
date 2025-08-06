# 🚀 MongoReady

<p align="center">
  
<img width="486" height="160" alt="Screenshot 2025-08-06 at 12 36 29 PM" src="https://github.com/user-attachments/assets/e41b03f7-5c9d-4391-b2ee-ef1d369b3d01" />

</p>

**MongoReady** is a one-click, cross-platform, hassle-free MongoDB + Mongoose installer for developers.

This script automatically detects your OS, installs MongoDB, sets up Mongoose, fixes common port issues, applies the latest patches, and gets you production-ready in seconds – all with a single command.

🔧 Whether you're on Ubuntu, Debian, macOS, or another supported system – MongoReady ensures your environment is... ready.


---

## ✨ Features

- 🧠 Auto-detects OS (`Ubuntu`, `Debian`, `RHEL`, `CentOS`, `Rocky`, `AlmaLinux`)
- ⚙️ Installs latest MongoDB (Community Edition 8.0+)
- 📦 Installs Node.js (LTS) and Mongoose (latest)
- 🩹 Auto-fixes:
  - Missing log/data directories
  - Port 27017 conflicts
  - MongoDB socket issues
  - Stale `mongod.lock` files
  - Low `ulimit` warning
- 🔒 SELinux warning if blocking MongoDB
- 🧪 Verifies service status with logs on failure

---

Here's the updated **Installation** section for your `README.md` that includes **both cloning and one-liner methods** to run `mongoready.sh`:

---

## 🛠️ Installation

You can install MongoDB + Mongoose easily using one of the following methods:

### 🚀 Method 1: One-liner (No Cloning Required)

Run this command directly in your terminal:

```bash
bash <(curl -sL https://raw.githubusercontent.com/BlackHatDevX/MongoReady/main/mongoready.sh)
````

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/BlackHatDevX/MongoReady/main/mongoready.sh | bash
```

---

### 📥 Method 2: Clone and Run Manually

```bash
git clone https://github.com/BlackHatDevX/MongoReady.git
cd MongoReady
chmod +x mongoready.sh
sudo ./mongoready.sh
```

> 🔒 **Note:** `sudo` may be required for installing system packages and fixing port permissions.


---

## 🧩 Requirements

* Linux-based OS (Ubuntu/Debian/CentOS/RHEL/Rocky/Alma)
* `sudo` access
* Internet connection (downloads MongoDB, Node, Mongoose)

---

## 📂 What it sets up

| Component | Version | How                           |
| --------- | ------- | ----------------------------- |
| MongoDB   | 8.0+    | Official MongoDB repo         |
| Node.js   | LTS     | NodeSource installer          |
| Mongoose  | latest  | via `npm install -g mongoose` |

---

## 📝 Output example

```bash
Detected OS: Ubuntu 22.04
Installing MongoDB 8.0...
Fixing MongoDB log directory permissions...
MongoDB is running on port 27017.
Installing Node.js...
Installing latest mongoose via npm...
✅ Installation complete.
```

---

## 💡 Notes

* If you’re deploying in a production environment, secure your MongoDB server (bind IP, enable auth, use TLS).
* You can modify `/etc/mongod.conf` after installation for custom settings.

---

## 🧑‍💻 Contributing

Pull requests are welcome! If you find a bug or have an idea for an improvement, [open an issue](https://github.com/BlackHatDevX/MongoReady/issues).

---

## 📄 License

[MIT](LICENSE)

---

