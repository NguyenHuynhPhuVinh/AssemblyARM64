Được rồi! Chúng ta cùng đi vào "Chương 3: Tập lệnh ARM". Chương này sẽ giải thích "ngữ pháp" của ngôn ngữ Assembly và giới thiệu những "động từ" (lệnh) mà chúng ta sẽ sử dụng.

---

### **Bài học Chương 3: Tập lệnh ARM (ARM Instruction Set)**

#### **1. Hai Chế độ Hoạt động: ARM và THUMB**

Đây là một khái niệm đặc thù của kiến trúc ARM 32-bit (AArch32).

*   **Chế độ ARM:**
    *   Tất cả các lệnh đều có độ dài cố định là **32-bit (4 byte)**.
    *   Mạnh mẽ, đầy đủ tính năng (ví dụ: thực thi có điều kiện trên mọi lệnh, barrel shifter linh hoạt).
    *   Nhược điểm: Mã nguồn có thể lớn hơn.

*   **Chế độ THUMB:**
    *   Các lệnh có độ dài **16-bit (2 byte)**.
    *   Đây là một tập lệnh con, được nén lại của chế độ ARM.
    *   Ưu điểm: **Mật độ mã cao hơn** (code density). Cùng một logic, code Thumb thường chiếm ít dung lượng hơn code ARM, giúp tiết kiệm bộ nhớ cache và bộ nhớ RAM. Điều này rất quan trọng trên các thiết bị nhúng có tài nguyên hạn chế.
    *   Nhược điểm: Một số lệnh phức tạp cần 2 lệnh Thumb 16-bit để thực hiện, và ít tính năng hơn so với chế độ ARM.

*   **THUMB-2:** Là một bản mở rộng sau này, cho phép lẫn lộn cả lệnh 16-bit và 32-bit trong chế độ Thumb, lấy được ưu điểm của cả hai.

*   **Làm thế nào CPU biết đang ở chế độ nào?**
    *   Dựa vào bit **T** trong thanh ghi trạng thái `CPSR`. Nếu bit T = 1, CPU đang ở chế độ Thumb.
    *   Khi thực hiện lệnh rẽ nhánh như `BX` (Branch and Exchange), bit cuối cùng (LSB) của địa chỉ đích sẽ quyết định chế độ. Nếu bit đó là `1`, CPU sẽ chuyển sang chế độ Thumb khi nhảy tới địa chỉ đó (và bỏ qua bit này khi tính toán địa chỉ thực).

**Liên hệ với ARM 64-bit (AArch64) của chúng ta:**
Khái niệm này **không còn tồn tại** trên AArch64. Trong AArch64, tất cả các lệnh đều có độ dài cố định là **32-bit (4 byte)**. Điều này làm cho kiến trúc 64-bit trở nên đơn giản và dễ dự đoán hơn. **Vì vậy, bạn không cần quá bận tâm về ARM/Thumb khi mod game Android hiện đại.**

#### **2. Cấu trúc của một lệnh ARM - "Ngữ pháp"**

Đây là phần cực kỳ quan trọng, nó áp dụng cho cả AArch32 và AArch64. Hầu hết các lệnh xử lý dữ liệu đều theo mẫu sau:

`MNEMONIC{S}{condition} {Rd}, Operand1, Operand2`

Hãy mổ xẻ nó:

*   **`MNEMONIC` (Gợi nhớ):** Tên của lệnh, là "động từ" cho biết CPU phải làm gì. Ví dụ: `MOV` (di chuyển), `ADD` (cộng), `SUB` (trừ).

*   **`{S}` (Suffix):** Một hậu tố tùy chọn. Nếu có chữ `S` (ví dụ `ADDS`, `SUBS`), nó ra lệnh cho CPU **cập nhật các cờ trạng thái (N, Z, C, V)** trong thanh ghi `CPSR`/`PSTATE` sau khi thực hiện lệnh. Nếu không có `S`, các cờ sẽ không thay đổi.
    *   **Ví dụ:** `ADD x0, x1, x2` chỉ đơn thuần thực hiện `x0 = x1 + x2`.
    *   `ADDS x0, x1, x2` sẽ thực hiện `x0 = x1 + x2` **VÀ** cập nhật cờ Z nếu `x0` bằng 0, cờ N nếu `x0` là số âm, v.v.

*   **`{condition}` (Điều kiện):** Hậu tố điều kiện. Đây là một tính năng rất mạnh của ARM. Bạn có thể ra lệnh cho một lệnh chỉ được thực thi **NẾU** một điều kiện nào đó (dựa trên các cờ) được thỏa mãn.
    *   Ví dụ: `MOVEQ x0, #1` có nghĩa là: "**MOV**e if **EQ**ual" (Di chuyển nếu bằng nhau). Lệnh này sẽ chỉ thực hiện `x0 = 1` **NẾU** cờ Z đang được bật (nghĩa là kết quả của phép tính trước đó bằng 0). Nếu cờ Z tắt, lệnh này sẽ bị bỏ qua (hoạt động như một lệnh `NOP` - No Operation).
    *   Chúng ta sẽ tìm hiểu sâu hơn về các mã điều kiện này ở Chương 6.

*   **`{Rd}` (Register Destination - Thanh ghi đích):** Thanh ghi sẽ nhận kết quả của phép tính.

*   **`Operand1` (Toán hạng 1):** Thường là một thanh ghi. Đây là toán hạng đầu tiên của phép tính.

*   **`Operand2` (Toán hạng 2):** Đây là "toán hạng linh hoạt" (flexible operand). Nó có thể là:
    1.  Một **giá trị tức thời (immediate value)**: một hằng số, ví dụ `#123`.
    2.  Một **thanh ghi**, ví dụ `x2`.
    3.  Một **thanh ghi với phép dịch chuyển (shift)**: Đây là một tính năng độc đáo khác gọi là **barrel shifter**. Bạn có thể xử lý toán hạng 2 trước khi thực hiện phép tính chính, tất cả chỉ trong một lệnh.
        *   `MOV x0, x1, LSL #2`: Di chuyển giá trị của `x1` **dịch trái 2 bit** (tương đương nhân 4) rồi mới lưu vào `x0`. Điều này kết hợp 2 lệnh (nhân và di chuyển) thành một, giúp code hiệu quả hơn.

#### **3. Giới thiệu một số lệnh phổ biến**

Bảng cuối cùng của bài viết liệt kê những lệnh cơ bản nhất mà bạn sẽ gặp thường xuyên:

*   **Lệnh Di chuyển Dữ liệu:**
    *   `MOV`: `MOV Rd, Operand2` -> `Rd = Operand2`. Dùng để gán giá trị hoặc sao chép giữa các thanh ghi.
    *   `MVN`: `MVN Rd, Operand2` -> `Rd = NOT Operand2`. Di chuyển giá trị đảo bit (Move Not).

*   **Lệnh Số học:**
    *   `ADD`: Cộng (`Rd = Op1 + Op2`).
    *   `SUB`: Trừ (`Rd = Op1 - Op2`).
    *   `MUL`: Nhân (`Rd = Op1 * Op2`).

*   **Lệnh Logic và Dịch chuyển Bit:**
    *   `AND`, `ORR`, `EOR`: Các phép toán logic AND, OR, XOR trên bit.
    *   `LSL`, `LSR`: Dịch trái/phải logic (Logical Shift Left/Right).
    *   `ASR`: Dịch phải số học (Arithmetic Shift Right - giữ lại bit dấu).
    *   `ROR`: Xoay phải (Rotate Right).

*   **Lệnh So sánh:**
    *   `CMP`: `CMP Operand1, Operand2`. Lệnh này thực hiện phép trừ `Operand1 - Operand2` nhưng **không lưu kết quả**. Nó chỉ dùng để **cập nhật các cờ N, Z, C, V**. Đây là lệnh quan trọng nhất để chuẩn bị cho các lệnh rẽ nhánh có điều kiện.

*   **Lệnh Tải/Lưu trữ Bộ nhớ (Load/Store):**
    *   `LDR`: Load Register - Tải dữ liệu **từ RAM** vào một thanh ghi.
    *   `STR`: Store Register - Lưu dữ liệu **từ một thanh ghi** vào RAM.

*   **Lệnh Rẽ nhánh (Branch):**
    *   `B`: Branch - Nhảy vô điều kiện đến một địa chỉ (nhãn) khác. Giống như `goto`.
    *   `BL`: Branch with Link - Nhảy đến một hàm. Trước khi nhảy, nó lưu địa chỉ quay về vào thanh ghi `LR` (`x30`). Đây chính là lệnh **gọi hàm**.

*   **Lệnh Stack:**
    *   `PUSH`, `POP`: Đẩy/lấy dữ liệu từ stack (sẽ học kỹ ở chương sau).

*   **Lệnh Gọi Hệ thống:**
    *   `SWI`/`SVC`: Chính là lệnh `svc #0` mà chúng ta đã dùng để yêu cầu kernel thực hiện syscall.

---

### **Tóm tắt những gì cần nhớ từ Chương 3**

1.  **Cấu trúc lệnh:** Nắm vững cấu trúc `MNEMONIC{S}{cond} Rd, Op1, Op2`. Hiểu được vai trò của hậu tố `S` (cập nhật cờ) là rất quan trọng.
2.  **Toán hạng linh hoạt:** `Operand2` có thể là một số, một thanh ghi, hoặc một thanh ghi đã được dịch chuyển bit (barrel shifter).
3.  **Lệnh `CMP` là nền tảng:** Lệnh `CMP` không thay đổi giá trị thanh ghi, nó chỉ cập nhật các cờ trạng thái để các lệnh rẽ nhánh có điều kiện (`BEQ`, `BNE`,...) có thể hoạt động.
4.  **`B` vs `BL`:** `B` là `goto`, `BL` là **gọi hàm** (vì nó lưu địa chỉ quay về vào `LR`).
5.  **AArch64 đơn giản hơn:** Không cần lo về chế độ ARM/Thumb, mọi lệnh đều là 32-bit.

Chương này đã trang bị cho bạn "bảng chữ cái" và "ngữ pháp" cơ bản. Chương tiếp theo sẽ đi sâu vào các lệnh quan trọng nhất của kiến trúc RISC: Load và Store. Bạn có câu hỏi nào không?