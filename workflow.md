# Purrfect Emoji Forge — Workflow (v1.2)

A hand-in-paw process to craft our emoji language — **manual today, automated
tomorrow**.

---

## 🗂️ Folder Layout

```
emoji-forge/
  001/js/
    docs.md
    prompt.md
    metadata.json
    purr_js_hires.png
    purr_js_transparent.png
    purr_js.png
  registry.json
```

---

## ⚙️ Prerequisites

- **Node.js** v16+
- **ImageMagick** (`magick` preferred)
  - macOS: `brew install imagemagick`
  - Debian/Ubuntu: `sudo apt install imagemagick`

_First time only:_

```bash
chmod +x scripts/resize.sh scripts/check.sh
```

---

## 🔨 Step-by-Step

### 1️⃣ Forge a new emoji folder

```bash
yarn forge 001 js "JavaScript"
```

Generates:

- `docs.md`
- `prompt.md`
- `metadata.json`

---

### 2️⃣ Generate art in Gemini

1. Open the generated `prompt.md`
2. Render on **solid `#00FF43` chroma background**
3. Export as `purr_js_hires.png` (≥ 512 px)

---

### 3️⃣ Convert & resize

```bash
yarn resize -- 001/js
```

This:

- Creates `purr_js_transparent.png` (hi-res transparent)
- Creates `purr_js.png` (128×128 transparent Discord version)

---

### 4️⃣ Sanity check & registry update

```bash
yarn check
```

Runs:

- Structural + alpha checks
- Artifact cleanup validation
- Central registry sync test (`emoji-forge/registry.json`)

If anything’s missing, the check fails with actionable tips.

---

### 5️⃣ Commit

```bash
git add emoji-forge/001/js
git commit -m "Forge #001 :js: — chroma pipeline, hires + transparent + resized"
```

---

## 🧰 Command Reference

| Task           | Command                          |
| -------------- | -------------------------------- |
| Forge new      | `yarn forge 002 ts "TypeScript"` |
| Resize one     | `yarn resize -- 002/ts`          |
| Resize all     | `yarn resize`                    |
| Check all      | `yarn check`                     |
| Build registry | `yarn build:registry`            |

---

## 🧭 Conventions

- `purr_<slug>_hires.png` → `purr_<slug>_transparent.png` → `purr_<slug>.png`
- Flat/vector artwork, **disciplined asymmetry**, **1:1** canvas
- Exports must use **solid `#00FF43`** background — the pipeline removes it
- Each emoji folder must only contain the six expected files

---

## 🛠️ Roadmap

- **v1.3:** CI validation (GitHub Actions)
- **v1.4:** Auto-optimize PNGs + perceptual diff
- **v2.0:** AI agent batch generation + design-assist
