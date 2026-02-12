## **Project Technical Execution Rules**

Engine: Godot 4.5.x  
 Language: GDScript 2.0 (Godot 4 syntax only)

---

# **1\. PROJECT AUTHORITY**

* Project Leader có quyền quyết định cuối cùng.

* Codex chỉ thực hiện theo task được giao.

* Không tự refactor hệ thống khi chưa có yêu cầu.

* Không tự thêm tính năng ngoài GDD.

* Mọi task phải đọc lại GDD \+ Agents.md trước khi thực hiện.

* Khi thiếu thông tin → hỏi, không tự suy luận.

---

# **2\. ENGINE CONFIGURATION**

## **2.1 Version**

* Godot 4.5.x only

* Không dùng API Godot 3.x

* Không dùng deprecated features

## **2.2 Renderer**

* 2D project

* Forward+ mặc định

## **2.3 Physics**

* GodotPhysics 4

* Physics FPS \= 60

---

# **3\. PROJECT ARCHITECTURE**

## **3.1 Scene Structure**

`Main.tscn`  
 `├── WorldLayer`  
 `├── UILayer`  
 `├── Managers`

---

## **3.2 Autoload Singletons**

Bắt buộc:

* GameManager

* SceneManager

* CombatManager

* DataManager

* DialogueManager

* SaveManager

Không thêm singleton nếu không được duyệt.

---

# **4\. FOLDER STRUCTURE**

`/scenes`  
`/scenes/world`  
`/scenes/combat`  
`/scenes/ui`

`/scripts`  
`/scripts/managers`  
`/scripts/systems`  
`/scripts/data`

`/data`  
`/data/json`  
`/data/resources`

`/assets`  
`/tests`

---

# **5\. CODING STANDARD**

## **5.1 GDScript Rules**

* Strict typing bắt buộc

* Không dùng dynamic typing trừ khi cần

* Không dùng yield() → dùng await

* Dùng @onready

* Dùng @export

* Dùng class\_name khi cần global reference

* Comment mỗi function

---

## **5.2 Naming Convention**

* Scene: PascalCase

* Script: snake\_case.gd

* Signal: snake\_case

* Constant: UPPER\_CASE

---

# **6\. DATA-DRIVEN DESIGN**

Không hardcode dữ liệu gameplay.

## **6.1 JSON bắt buộc:**

* EnemyStat.json

* Quest.json

* Passive.json

* Skill.json

## **6.2 Resource (.tres)**

* Item.tres

* Equipment.tres

* PassiveResource.tres

---

# **7\. STATE MACHINE ARCHITECTURE**

Game sử dụng Global State Machine.

## **Core States:**

* MENU

* NARRATIVE

* WORLD

* HUB

* COMBAT

* CUTSCENE

* GAME\_OVER

Chuyển state qua GameManager.

Không đổi scene trực tiếp từ node con.

---

# **8\. COMBAT SYSTEM IMPLEMENTATION RULES**

Combat math phải theo pipeline sau, không được thay đổi thứ tự.

---

## **8.1 Damage Pipeline**

`1. Raw = (Stat + Skill) × Rank Multiplier`  
`2. Apply Ki Layer`  
`3. Apply DEF Reduction`  
`4. Net Damage`  
`5. Dodge Roll`  
`6. Apply HP reduction`

Không được thay đổi thứ tự.

---

## **8.2 Ki Layer Rules**

* Damage taken as Ki (max 35%)

* Damage convert to Ki (max 70%)

* Không áp dụng cho DOT

* Damage vào Ki trước

* Hồi Ki sau cùng

---

## **8.3 DEF Formula**

`DEF% = DEF / (DEF + 100)`  
`Cap = 70%`

---

## **8.4 Dodge Formula**

`Dodge% = min(DEX × 0.2, 70%)`

* Roll sau khi tính net damage

* DOT không roll dodge

---

## **8.5 DOT Handling**

* DOT tick đầu turn

* Không áp dụng Ki layer

* Không áp dụng Dodge

* Không stack ngoài giới hạn GDD

---

# **9\. STAT SYSTEM IMPLEMENTATION**

## **Main Stat**

* STR → Physical Damage \+ DEF

* INT → Spell Damage \+ Ki

* DEX → Speed \+ Dodge

* VIT → HP \+ MP

## **Conversion**

* 1 STR \= 1 dmg \+ 0.5 DEF

* 1 INT \= 1 dmg \+ 2 Ki

* 1 DEX \= 1 speed \+ 0.2% dodge

* 1 VIT \= 10 HP \+ 5 MP

Không được thay đổi conversion nếu không duyệt.

---

# **10\. EXP SYSTEM IMPLEMENTATION**

## **Level Up Formula**

`Exp = 20 × (Level²) × Rarity Multiplier`

## **Training**

* 1 day \= 5 exp

* Rank bonus 10–30%

Không thay đổi Base \= 20\.

---

# **11\. AI RULES**

AI logic cố định:

* Dùng skill theo thứ tự slot

* Nếu thiếu MP/Ki → dùng skill hồi khí

* Không dùng random AI

---

# **12\. SAVE SYSTEM**

* Save chỉ ở HUB và WORLD

* Không save trong COMBAT

* Dùng JSON serialization

* Không lưu scene tree trực tiếp

---

# **13\. PERFORMANCE RULES**

* Không tạo object trong \_process

* Dùng object pooling cho combat

* Không load JSON mỗi frame

* Preload static resources

---

# **14\. SIGNAL RULES**

* Không gọi node trực tiếp qua get\_node path dài

* Dùng signal để giao tiếp giữa scene

* Không emit signal trong \_init()

---

# **15\. TESTING REQUIREMENTS**

Trước khi hoàn thành module combat:

* Test DEF cap

* Test Dodge cap

* Test Ki convert cap

* Test DOT stacking

* Test Rank multiplier scaling

---

# **16\. ABSOLUTE PROHIBITIONS**

* Không dùng Godot 3.x syntax

* Không thay đổi damage pipeline

* Không thay đổi stat conversion

* Không thay đổi exp base

* Không thay đổi rank multiplier

* Không thêm hệ thống ngoài GDD

---

# **17\. VERSION CONTROL RULES**

* Mỗi task \= 1 feature branch

* Không commit file ngoài scope

* Không reformat toàn bộ project

---

# **18\. FUTURE EXTENSION SAFETY**

Nếu cần thêm tính năng:

* Không chỉnh sửa CombatManager trực tiếp

* Tạo extension layer

* Không sửa formula gốc

