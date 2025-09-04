# Project_DJ_Godot

---
**🔍 How To Use**

```bash
git clone https://github.com/Rliop913/Project_DJ_Godot.git
cd Project_DJ_Godot
cp Update_Project_DJ_Godot.bat ~/path/to/your/project/root
cp Update_Project_DJ_Godot.sh ~/path/to/your/project/root

cd  ~/path/to/your/project/root

bash ./Update_Project_DJ_Godot.sh


```

---


📦 **CI/CD Prebuilt Repository**  
This repository receives and stores prebuilt artifacts from [PDJE_Godot_Plugin](https://github.com/Rliop913/PDJE-Godot-Plugin) via automated GitHub Actions.

---


## 🔗 Related Projects
- 🪄 **Godot Wrapper**: [PDJE-Godot-Plugin](https://github.com/Rliop913/PDJE-Godot-Plugin)

- 🧱 **Core Library**: [Project-DJ-Engine](https://github.com/Rliop913/Project-DJ-Engine)

- 📚 **Documentation**: [PDJE DOCS](https://rliop913.github.io/Project-DJ-Engine)

---

## 🔁 CI/CD Call Graph

```mermaid
flowchart TD
Project_DJ_Engine --> PDJE_Godot_Plugin
PDJE_Godot_Plugin --> Project_DJ_Godot

origin_build_success --> Project_DJ_Engine
manual_release --> PDJE_Godot_Plugin
```
This is the CI/CD call graph for this project.
These three repositories are chained into one continuous automation flow using GitHub Actions.
