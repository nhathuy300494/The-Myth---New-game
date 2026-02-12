# **I. CHỐT EXP CURVE CHO PASSIVE (ÁP DỤNG CHUNG)**

## **🎯 Mục tiêu thiết kế**

* Một người chơi trung bình:

  * 40–50% thời gian di chuyển/quest

  * 30% combat

  * 20% tu hành

* Tổng ngày dùng cho tu hành thực tế ≈ 1500–2200 ngày

* Không thể max toàn bộ 10 passive Legendary

---

# **1️⃣ EXP YÊU CẦU THEO LEVEL (BASE CURVE)**

Công thức chung:

`Exp to next level = Base × (Level^2) × Rarity Multiplier`

### **Chọn Base \= 20**

---

## **2️⃣ Rarity Multiplier EXP**

| Rarity | Exp Multiplier |
| ----- | ----- |
| Common | x1 |
| Good | x1.5 |
| Rare | x2 |
| Legendary | x3 |

---

## **3️⃣ Ví dụ EXP cho 1 Passive**

### **Common (Max 3\)**

Level 1 → 2:  
 20 × (1²) × 1 \= 20

Level 2 → 3:  
 20 × (2²) × 1 \= 80

Tổng ≈ 100 exp

---

### **Good (Max 5\)**

1→2: 30  
 2→3: 120  
 3→4: 270  
 4→5: 480

Tổng ≈ 900 exp

---

### **Rare (Max 7\)**

Tổng ≈ 20 × (1²+…+6²) × 2  
 \= 20 × 91 × 2  
 \= 3640 exp

---

### **Legendary (Max 9\)**

Tổng ≈ 20 × (1²+…+8²) × 3  
 \= 20 × 204 × 3  
 \= 12,240 exp

---

# **4️⃣ EXP NHẬN ĐƯỢC**

## **🧘 Tu hành**

* 1 ngày tu hành \= 5 exp cơ bản

* Rank cao hơn tăng hiệu suất 10–30%

Ví dụ:

* 20 ngày tu hành \= 100 exp

* 30 ngày \= 150 exp

---

## **⚔ Battle Reward**

* Rank enemy thấp hơn: 20 exp

* Bằng rank: 40 exp

* Cao hơn rank: 60–80 exp

---

## **🧪 Dược vật**

* Trắng: \+50 exp

* Xanh: \+150 exp

* Lam: \+400 exp

* Cam: \+1000 exp

---

# **5️⃣ Phân tích 7300 ngày**

Nếu:

* 2000 ngày dùng tu hành

* Trung bình 20 ngày/lần

* ≈ 100 lần tu hành

* ≈ 100 × 100 exp \= 10,000 exp

Cộng thêm battle \+ dược vật → khoảng 20,000–25,000 exp tổng

Điều này cho phép:

* Max 2–3 Legendary

* 3–4 Rare

* Còn lại Good/Common

Không thể max toàn bộ → build quan trọng.

Power curve hợp lý.

---

# **II. HỆ THỐNG DODGE (ĐƯA VÀO GDD)**

---

# **🎯 Triết lý Dodge**

* Không có Accuracy

* Không có miss theo attacker

* Chỉ có Dodge từ defender

* Check sau cùng

* Thành công \= Damage \= 0

---

# **1️⃣ Conversion**

Đã có:

`1 DEX = 0.2% Dodge`

---

# **2️⃣ Dodge Formula**

`Dodge% = DEX × 0.2`

Giới hạn:

`Dodge% = min(DEX × 0.2, 70%)`

Ví dụ:

* 100 DEX \= 20%

* 250 DEX \= 50%

* 350 DEX \= 70% (cap)

---

# **3️⃣ Dodge Check Position**

Damage pipeline mới:

1. Raw damage

2. Ki Layer

3. DEF reduction

4. Net damage

5. **Dodge roll**

   * Nếu roll ≤ Dodge% → damage \= 0

   * Nếu fail → nhận damage

---

# **4️⃣ Lưu ý quan trọng**

* DOT không thể dodge

* Burn tick không dodge

* Poison tick không dodge

* Bleed không dodge

Chỉ hit trực tiếp mới check dodge.

---

# **III. CẬP NHẬT DAMAGE PIPELINE CHÍNH THỨC**

`Raw = (Stat + Skill) × Rank`  
`→ Ki Layer`  
`→ DEF reduction`  
`→ Final Damage`  
`→ Dodge roll`  
`→ Apply damage`  
