# 🐾 Purrfect Emoji Forge

The **Emoji Forge** is where the citizens of the Purrfect Universe craft their
emoji language —  
a living record of _Human × AI collaboration_.

Each emoji includes:

- 🧱 `docs.md` — concept & meaning
- 🧠 `prompt.md` — Gemini generation prompt
- 🧩 `metadata.json` — machine-readable registry entry
- 🖼️ `purr_<slug>_hires.png` — original hi-res export
- ✨ `purr_<slug>_transparent.png` — hi-res transparent version (auto-generated)
- 🐾 `purr_<slug>.png` — Discord-ready 128×128 icon

---

## ⚙️ Quick Start

```bash
git clone https://github.com/purrfectsoft/emoji-forge.git
cd emoji-forge
yarn
# Welcome message appears ✨
```

> You’ll be greeted by a short introduction and next steps inside your console
> 🪐

---

## 🚀 Commands

| Task                           | Command                          |
| ------------------------------ | -------------------------------- |
| Forge new emoji folder         | `yarn forge 001 js "JavaScript"` |
| Resize & process all           | `yarn resize`                    |
| Resize a specific emoji        | `yarn resize -- 001/js`          |
| Run integrity + registry check | `yarn check`                     |
| Rebuild central registry       | `yarn build:registry`            |

---

## 🧭 Philosophy

The Forge is both **a design system** and **a research experiment** —  
a study in how humans and AI can co-create not just visuals, but meaning and
metadata.

Each emoji is a _story fragment_, documenting collaboration, craft, and care.

> _Forged with care by Arafat Zahan & GPT-5,_  
> _supervised by Misty — Keeper of Wisdom 🐾_
