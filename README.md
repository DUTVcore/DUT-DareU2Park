# 🛵 D.U.T: Dare U To Park
> *A 2D top-down tactical bike parking survival game.*

This game simulates the challenging experience of parking a bike on a university campus: avoiding potholes and speed bumps, weaving through narrow 15 cm gaps, folding mirrors, and successfully parking before 07:00 AM.

---

## 🎮 Core Gameplay & Features

- **2D bike physics:** Flexible steering at low speed, losing balance when turning sharply.
- **Hazardous terrain:** Pothole system, puddles that disguise steering wobble and camera shake (Screen Shake).
- **Rear-view mirror forest:** Detailed collision hitboxes (fenders, mirrors, kickstands). Collisions reduce vehicle durability (HP).
- **Parking mechanic:** Align the parking angle and press the kickstand key to complete the level.
- **Time limit:** Arriving at the lot after 07:00 AM means being marked absent.

---

## 🕹️ Controls

| Key | Action |
| :--- | :--- |
| `W` / `↑` | Accelerate (Forward) |
| `S` / `↓` | Reverse / Brake |
| `A` / `D` or `←` / `→` | Steer left / right |
| `Space` | Deploy kickstand (Confirm parking) |

---

## 🛠️ Development Technology

- **Engine:** Godot Engine 4.x
- **Language:** GDScript
- **View:** Top-down 2D
- **Target Platform:** Web (HTML5) & Desktop (Windows/Linux)

---

## 🚀 Installation & Local Run

1. Install [Godot Engine 4.x](https://godotengine.org/).
2. Clone the repository to your machine:
   ```bash
   git clone https://github.com/DUTVcore/D.U.T-Dare-U-To-Park.git