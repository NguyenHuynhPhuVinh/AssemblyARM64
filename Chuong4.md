Đúng vậy, đây chính là chương giải thích khái niệm cốt lõi nhất của kiến trúc RISC. Chúng ta cùng phân tích "Chương 4: Lệnh Bộ Nhớ: Load và Store".

---

### **Bài học Chương 4: Các Lệnh Bộ Nhớ: Load và Store**

#### **1. Ôn lại khái niệm Load-Store**

*   Bài viết nhắc lại một lần nữa: ARM là kiến trúc **load-store**.
*   Các lệnh tính toán (`ADD`, `SUB`, `MUL`, `AND`...) **KHÔNG** thể làm việc trực tiếp với bộ nhớ (RAM).
*   Để thao tác dữ liệu trong RAM, bạn **BẮT BUỘC** phải tuân theo quy trình 3 bước:
    1.  **`LDR` (Load):** Tải dữ liệu từ một địa chỉ trong RAM vào một thanh ghi.
    2.  **Thao tác:** Thực hiện tính toán trên thanh ghi đó.
    3.  **`STR` (Store):** Lưu kết quả từ thanh ghi trở lại RAM.

Đây là sự khác biệt cơ bản nhất so với x86 (CISC), nơi một lệnh duy nhất có thể làm cả 3 việc trên.

#### **2. Các Chế độ Địa chỉ (Addressing Modes)**

Phần này giải thích cách lệnh `LDR` và `STR` tính toán ra địa chỉ bộ nhớ cuối cùng mà chúng cần truy cập. Đây là cú pháp chung:

`LDR Rd, [Rn, offset]`
`STR Rt, [Rn, offset]`

*   `Rd`/`Rt`: Thanh ghi đích (cho LDR) hoặc thanh ghi nguồn (cho STR).
*   `Rn`: Thanh ghi cơ sở (base register). Nó chứa địa chỉ nền.
*   `offset`: Độ dời. Là một giá trị được cộng (hoặc trừ) vào thanh ghi cơ sở để ra được địa chỉ cuối cùng.

Cái hay của ARM là `offset` này có thể ở nhiều dạng khác nhau.

**A. Dạng Offset (Offset Form):**

*   **Offset là một hằng số (Immediate):** `LDR x0, [x1, #8]`
    *   Ý nghĩa: `x0 = memory[x1 + 8]`. Tải giá trị từ địa chỉ (giá trị trong x1 cộng thêm 8) vào x0.
*   **Offset là một thanh ghi (Register):** `LDR x0, [x1, x2]`
    *   Ý nghĩa: `x0 = memory[x1 + x2]`. Tải giá trị từ địa chỉ (giá trị trong x1 cộng giá trị trong x2) vào x0. Rất hữu ích khi truy cập mảng.
*   **Offset là một thanh ghi đã được scale (Scaled Register):** `LDR x0, [x1, x2, LSL #2]`
    *   Ý nghĩa: `x0 = memory[x1 + (x2 << 2)]`. Tải giá trị từ địa chỉ (giá trị x1 cộng với giá trị x2 đã nhân 4) vào x0. Cực kỳ hiệu quả để truy cập mảng các số 32-bit (word). Ví dụ, `x2` là chỉ số (index) của mảng, `LSL #2` (nhân 4) để biến chỉ số thành byte offset.

**B. Các Chế độ Ghi nhận (Indexing Modes):**

Đây là phần hơi phức tạp hơn, nó quy định xem thanh ghi cơ sở `Rn` có bị thay đổi sau khi lệnh được thực thi hay không.

1.  **Offset Addressing:** (Không có `!` và `[]` bao quanh `Rn`)
    *   Cú pháp: `LDR x0, [x1, #8]`
    *   Hành động: Địa chỉ cuối cùng được tính là `x1 + 8`. Giá trị của **`x1` không thay đổi** sau lệnh. Đây là chế độ phổ biến nhất.

2.  **Pre-indexed Addressing:** (Có dấu `!` ở cuối)
    *   Cú pháp: `LDR x0, [x1, #8]!`
    *   Hành động: Có 2 việc xảy ra:
        1.  Địa chỉ cuối cùng được tính là `x1 + 8`.
        2.  **`x1` được cập nhật** với địa chỉ mới này: `x1 = x1 + 8`.
    *   "Pre" có nghĩa là "trước": tính offset **trước**, rồi cập nhật thanh ghi cơ sở. Rất hữu ích khi duyệt một cấu trúc dữ liệu hoặc một mảng theo tuần tự.

3.  **Post-indexed Addressing:** (Dấu `[]` chỉ bao quanh `Rn`)
    *   Cú pháp: `LDR x0, [x1], #8`
    *   Hành động: Cũng có 2 việc xảy ra, nhưng theo thứ tự khác:
        1.  Địa chỉ được dùng để tải dữ liệu là địa chỉ **hiện tại** trong `x1`.
        2.  Sau khi tải xong, **`x1` mới được cập nhật**: `x1 = x1 + 8`.
    *   "Post" có nghĩa là "sau": dùng giá trị hiện tại **trước**, rồi mới cập nhật thanh ghi cơ sở **sau**.

**Tóm tắt các chế độ ghi nhận:**
| Chế độ | Cú pháp AArch64 | `x1` có thay đổi không? | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Offset** | `LDR x0, [x1, #8]` | **Không** | Phổ biến nhất. |
| **Pre-indexed** | `LDR x0, [x1, #8]!` | **Có** (Update trước) | `x1` trỏ đến phần tử tiếp theo. |
| **Post-indexed** | `LDR x0, [x1], #8` | **Có** (Update sau) | Tải phần tử hiện tại, rồi `x1` mới trỏ đến phần tử tiếp theo. |

#### **3. Pseudo-instruction: LDR Rd, =value (Lệnh giả)**

Phần cuối của bài viết đề cập đến một cú pháp rất quan trọng mà bạn sẽ thấy ở khắp mọi nơi: `LDR r1, =0x68DB00AD`.

*   **Vấn đề:** Lệnh `MOV` trong ARM (đặc biệt là 32-bit) có giới hạn về hằng số mà nó có thể tải trực tiếp. Nó không thể tải một số 32-bit bất kỳ. (Lệnh `MOV` trên AArch64 linh hoạt hơn nhiều, nhưng vẫn có giới hạn).
*   **Giải pháp:** Assembler cung cấp một **lệnh giả (pseudo-instruction)** là `LDR Rd, =value`. Đây không phải là một lệnh ARM thực sự.
*   **Cách hoạt động:** Khi assembler thấy lệnh này, nó sẽ làm một trong hai việc:
    1.  **Nếu `value` là một hằng số hợp lệ cho `MOV`:** Nó sẽ tự động chuyển `LDR Rd, =value` thành `MOV Rd, #value`.
    2.  **Nếu `value` quá lớn hoặc phức tạp cho `MOV`:** Nó sẽ làm một mẹo rất thông minh:
        *   Lưu giá trị `value` đó vào một vùng nhớ gần đó gọi là **"literal pool"** (nằm ngay trong section code).
        *   Chuyển lệnh `LDR Rd, =value` thành một lệnh `LDR` thực sự, dùng chế độ địa chỉ tương đối với PC (PC-relative addressing) để tải giá trị từ literal pool vào `Rd`. Ví dụ: `LDR x0, [pc, #offset_to_pool]`.

=> **Kết luận:** Khi bạn cần tải một địa chỉ đầy đủ hoặc một hằng số lớn vào một thanh ghi, hãy dùng `LDR Rd, =value`. Assembler sẽ tự động chọn cách tối ưu nhất để thực hiện nó. Trong ví dụ của Azeria `ldr r0, adr_var1`, assembler cũng đã chuyển nó thành một lệnh LDR tương đối với PC.

---

### **Tóm tắt những gì cần nhớ từ Chương 4**

1.  **LDR/STR là cổng duy nhất** để giao tiếp với bộ nhớ RAM.
2.  Nắm vững 3 **dạng offset**: hằng số, thanh ghi, và thanh ghi được scale (rất quan trọng cho mảng).
3.  Hiểu sự khác biệt giữa 3 **chế độ ghi nhận**: **Offset** (không đổi base), **Pre-indexed** (`!`, cập nhật trước), và **Post-indexed** (cập nhật sau).
4.  Khi thấy cú pháp `LDR Rd, =value`, hãy hiểu rằng đó là một **lệnh giả** tiện lợi để tải các hằng số hoặc địa chỉ lớn, và assembler sẽ tự động biến nó thành một lệnh `MOV` hoặc một lệnh `LDR` tương đối với PC.

Đây là một chương rất thực tế, các chế độ địa chỉ này xuất hiện liên tục trong code đã được biên dịch. Hiểu rõ chúng là một kỹ năng thiết yếu để đọc và phân tích mã máy.