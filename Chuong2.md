Tuyệt vời! Chúng ta hãy cùng nhau phân tích "Chương 2: Các Kiểu Dữ Liệu và Thanh Ghi".

Đây là một chương cực kỳ quan trọng vì nó giới thiệu về "bộ não" và "bàn tay" của CPU: các **thanh ghi (registers)**. Mọi phép tính, mọi thao tác đều diễn ra ở đây.

---

### **Bài học Chương 2: Các Kiểu Dữ Liệu và Thanh Ghi**

#### **1. Các Kiểu Dữ Liệu (Data Types)**

Giống như các ngôn ngữ lập trình cấp cao, Assembly cũng cần làm việc với các loại dữ liệu có kích thước khác nhau.

*   **Byte:** 8 bit
*   **Half-word (Nửa từ):** 16 bit (2 byte)
*   **Word (Từ):** 32 bit (4 byte)
*   **(Trên AArch64 còn có) Double Word:** 64 bit (8 byte)

**Signed vs. Unsigned (Có dấu vs. Không dấu):**
*   **Unsigned:** Chỉ biểu diễn số dương (và số 0). Ví dụ, một byte không dấu có thể lưu giá trị từ 0 đến 255.
*   **Signed:** Biểu diễn cả số âm, 0, và số dương. Ví dụ, một byte có dấu lưu giá trị từ -128 đến 127.

Khi bạn thấy các lệnh như `ldrb`, `ldrh`, `strb`,... hậu tố phía sau cho biết kích thước dữ liệu đang được thao tác:
*   `b` = Byte (8-bit)
*   `h` = Half-word (16-bit)
*   (không có gì) = Word (32-bit trên ARMv7, nhưng trên AArch64 thường ngụ ý là 64-bit hoặc 32-bit tùy vào thanh ghi `x` hay `w`)
*   `s` đứng trước (ví dụ `ldrsh`) có nghĩa là "signed" - khi tải một giá trị nhỏ hơn vào một thanh ghi lớn hơn, nó sẽ mở rộng dấu (sign-extend) để giữ nguyên giá trị âm.

#### **2. Endianness - Cách Byte Được Sắp Xếp**

Đây là một khái niệm quan trọng khi bạn phân tích dữ liệu trong bộ nhớ. Nó quy định thứ tự các byte của một số nhiều-byte (như Word hay Half-word) được lưu trữ trong RAM.

Hãy tưởng tượng bạn có số `0x12345678` (4 byte) và muốn lưu nó vào địa chỉ `0x100`.

*   **Little-Endian (LE):** "Đuôi nhỏ đi trước". Byte có giá trị nhỏ nhất (least-significant byte - LSB) được lưu ở địa chỉ thấp nhất.
    *   Địa chỉ `0x100`: lưu `0x78`
    *   Địa chỉ `0x101`: lưu `0x56`
    *   Địa chỉ `0x102`: lưu `0x34`
    *   Địa chỉ `0x103`: lưu `0x12`
    *   **Hầu hết mọi thứ bạn gặp (Intel x86, Android trên ARM) đều là Little-Endian.**

*   **Big-Endian (BE):** "Đầu to đi trước". Byte có giá trị lớn nhất (most-significant byte - MSB) được lưu ở địa chỉ thấp nhất.
    *   Địa chỉ `0x100`: lưu `0x12`
    *   Địa chỉ `0x101`: lưu `0x34`
    *   Địa chỉ `0x102`: lưu `0x56`
    *   Địa chỉ `0x103`: lưu `0x78`
    *   (Thường thấy trong các giao thức mạng và các hệ thống cũ).

=> **Kết luận:** Khi bạn mod game Android, gần như 100% bạn sẽ làm việc với môi trường **Little-Endian**.

#### **3. Thanh Ghi ARM (ARM Registers) - Trái Tim Của CPU**

Đây là phần cốt lõi của chương. Thanh ghi là những vùng nhớ siêu nhỏ, siêu nhanh nằm ngay bên trong CPU, được dùng để lưu trữ dữ liệu tạm thời cho các phép tính.

**LƯU Ý CỰC KỲ QUAN TRỌNG:**
Bài viết của Azeria tập trung vào **ARM 32-bit (ARMv7)**. Môi trường chúng ta đang thực hành là **ARM 64-bit (AArch64, ARMv8)**. Có sự khác biệt, nhưng các khái niệm cốt lõi thì tương tự. Tôi sẽ lập một bảng đối chiếu để bạn dễ theo dõi.

| Khái niệm | ARM 32-bit (Bài viết Azeria) | **ARM 64-bit (Chúng ta đang học)** | Ghi chú |
| :--- | :--- | :--- | :--- |
| Tên thanh ghi GPR | `r0`, `r1`, ... `r15` | `x0`, `x1`, ... `x30` | `x` là 64-bit. `w0` là 32-bit dưới của `x0`. |
| Số lượng GPR | 16 | 31 (`x30` là Link Register) | 64-bit có nhiều thanh ghi hơn. |
| Thanh ghi Syscall | `r7` | **`x8`** | **Rất quan trọng!** |
| Program Counter | `r15` (PC) | `PC` (thanh ghi riêng) | Trên AArch64 không thể truy cập trực tiếp PC. |
| Stack Pointer | `r13` (SP) | `SP` | Giống nhau. |
| Link Register | `r14` (LR) | `x30` (LR) | Giống nhau về chức năng. |
| Thanh ghi cờ | `CPSR` | `PSTATE` | Giống nhau về chức năng. |

Bây giờ, hãy đi vào chi tiết các thanh ghi quan trọng dựa theo bài viết:

*   **Thanh ghi đa dụng (General Purpose Registers - GPRs): `r0-r12` (tương đương `x0-x28` của chúng ta)**
    *   Đây là các "công nhân" chính, dùng để chứa giá trị, địa chỉ con trỏ, và kết quả tính toán.
    *   Theo quy ước, `r0-r3` (tương đương `x0-x7` của chúng ta) được dùng để truyền 4 (hoặc 8) tham số đầu tiên cho một hàm. Thanh ghi `r0` (hoặc `x0`) cũng thường được dùng để chứa giá trị trả về của hàm.

*   **Thanh ghi Syscall Number: `r7` (tương đương `x8` của chúng ta)**
    *   Khi bạn muốn yêu cầu hệ điều hành làm gì đó (syscall), bạn phải đặt số hiệu của syscall vào thanh ghi này.
    *   **Ví dụ "Hello, World!" của chúng ta:**
        ```assembly
        mov x8, #64  // 64 là số hiệu của syscall 'write'
        mov x8, #93  // 93 là số hiệu của syscall 'exit'
        ```
        Đây chính là lý do tại sao chúng ta dùng `x8`!

*   **SP (Stack Pointer - Con trỏ ngăn xếp): `r13` hoặc `sp`**
    *   Luôn trỏ tới "đỉnh" của stack. Stack là một vùng nhớ đặc biệt dùng để lưu biến cục bộ của hàm, các tham số, và địa chỉ trả về. Chúng ta sẽ tìm hiểu kỹ về nó trong các chương sau.

*   **LR (Link Register - Thanh ghi liên kết): `r14` hoặc `x30`**
    *   Khi chương trình gọi một hàm con (ví dụ: `call my_function`), CPU sẽ tự động lưu địa chỉ của lệnh *ngay sau* lệnh gọi vào thanh ghi `LR`.
    *   Khi hàm con thực hiện xong, nó chỉ cần "nhảy" tới địa chỉ trong `LR` là có thể quay về đúng nơi đã gọi nó. **Cực kỳ quan trọng cho việc thực thi hàm.**

*   **PC (Program Counter - Bộ đếm chương trình)**
    *   Luôn trỏ tới địa chỉ của lệnh **tiếp theo** sẽ được thực thi. CPU đọc giá trị của PC, tìm đến lệnh ở địa chỉ đó, thực thi nó, và PC tự động tăng lên để trỏ tới lệnh kế tiếp.

#### **4. CPSR - Thanh Ghi Trạng Thái Chương Trình (Flags)**

`CPSR` (trên AArch64 gọi là `PSTATE`) không chứa dữ liệu thông thường. Thay vào đó, mỗi bit của nó là một "cờ" (flag) bật/tắt để ghi lại trạng thái của kết quả phép tính vừa thực hiện. Bốn cờ quan trọng nhất là:

*   **N (Negative):** Bật lên `1` nếu kết quả của phép tính là một số âm.
*   **Z (Zero):** Bật lên `1` nếu kết quả của phép tính là **bằng 0**. Cờ này cực kỳ quan trọng, được dùng trong hầu hết các vòng lặp và câu lệnh `if`.
*   **C (Carry):** Bật lên `1` nếu một phép cộng bị "tràn số" (unsigned overflow), hoặc một phép trừ không cần "mượn".
*   **V (Overflow):** Bật lên `1` nếu một phép cộng/trừ số có dấu (signed) cho ra kết quả sai (ví dụ: cộng 2 số dương lớn ra số âm).

Các cờ này sẽ là nền tảng cho "Thực thi có điều kiện và rẽ nhánh" ở Chương 6.

---

### **Tóm tắt những gì cần nhớ từ Chương 2**

1.  **Kiến trúc Load/Store:** Nhắc lại từ chương 1, ARM chỉ tính toán trên các thanh ghi.
2.  **Thanh ghi là cốt lõi:** `x0-x7` dùng để truyền tham số, `x0` để trả về giá trị, `x8` cho syscall.
3.  **Bộ ba điều hướng chương trình:**
    *   **PC** quyết định lệnh nào được chạy tiếp theo.
    *   **LR** (`x30`) giúp quay về sau khi gọi hàm.
    *   **SP** quản lý vùng nhớ tạm thời (stack).
4.  **Cờ (Flags) N, Z, C, V:** Ghi lại "tính chất" của kết quả (âm, bằng không, tràn số...), làm cơ sở cho các lệnh rẽ nhánh.
5.  **Ghi nhớ sự khác biệt:** Bài viết dùng chuẩn 32-bit (`rX`), chúng ta sẽ áp dụng các khái niệm đó cho chuẩn 64-bit (`xX`) mà mình đang thực hành.

Chương này khá nặng về lý thuyết, nhưng việc hiểu rõ vai trò của từng thanh ghi là chìa khóa để có thể đọc hiểu bất kỳ đoạn mã Assembly nào. Bạn đã nắm được những khái niệm này chưa?