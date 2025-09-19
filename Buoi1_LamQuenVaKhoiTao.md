### **Hướng dẫn chi tiết: Sử dụng WSL (Lựa chọn được khuyến nghị)**

Phương pháp này kết hợp sự tiện lợi của Windows (với các editor như VS Code) và sức mạnh của toolchain Linux.

#### **Bước 1: Cài đặt WSL và một bản phân phối Linux (Ubuntu)**

Nếu bạn chưa cài WSL, hãy làm theo các bước sau. Nó cực kỳ đơn giản trên Windows 10/11.

1.  Mở **PowerShell** với quyền **Administrator**.
2.  Chạy lệnh sau để cài đặt WSL và bản Ubuntu mặc định:
    ```powershell
    wsl --install
    ```
3.  Khởi động lại máy tính của bạn khi được yêu cầu.
4.  Sau khi khởi động lại, Ubuntu sẽ tự động được cài đặt. Bạn sẽ cần tạo một tài khoản người dùng và mật khẩu cho Linux. Hãy ghi nhớ nó.

Bây giờ bạn đã có một terminal Ubuntu đầy đủ chạy trên Windows. Bạn có thể mở nó từ Start Menu.

#### **Bước 2: Cài đặt Cross-Compiler Toolchain trên Ubuntu (trong WSL)**

Bây giờ, hãy làm theo các bước giống như trên môi trường Linux thật.

1.  Mở terminal Ubuntu của bạn.
2.  Cập nhật danh sách gói và cài đặt toolchain biên dịch chéo cho AArch64:
    ```bash
    sudo apt update
    sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
    ```
    *   `gcc-aarch64-linux-gnu`: Trình biên dịch C/C++ và assembler.
    *   `binutils-aarch64-linux-gnu`: Chứa các công cụ khác như linker (`ld`), trình xem thông tin file ELF (`readelf`),...

#### **Bước 3: Tích hợp với Visual Studio Code (Để có trải nghiệm tốt nhất)**

1.  Cài đặt **Visual Studio Code** trên Windows nếu bạn chưa có.
2.  Trong VS Code, vào phần **Extensions** (biểu tượng ô vuông bên trái).
3.  Tìm và cài đặt extension có tên **"WSL"** của Microsoft.
4.  Sau khi cài xong, vào trong wsl ghi lệnh `code .` để khởi động cửa sổ vs code cho wsl.
5.  Một cửa sổ VS Code mới sẽ mở ra, nhưng cửa sổ này đang chạy "bên trong" môi trường WSL. Bạn có thể mở terminal tích hợp (`Ctrl + `` `) và nó sẽ là terminal Ubuntu.

### Môi trường chuẩn bị

*   Windows đã cài WSL và Ubuntu.
*   Đã cài đặt cross-compiler toolchain trong Ubuntu: `sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu`
*   (Khuyến nghị) VS Code đã cài extension "WSL".

---

### **Bước 1: Viết mã Assembly (`hello.s`)**

Hãy tạo một chương trình Assembly đơn giản. Chương trình sẽ làm 2 việc:
1.  **Syscall `write` (viết):** Yêu cầu kernel ghi chuỗi "Hello, ARM64!\n" ra màn hình (standard output).
2.  **Syscall `exit` (thoát):** Yêu cầu kernel kết thúc chương trình.

Theo quy ước syscall trên ARM64 Linux:
*   Thanh ghi `x8` chứa số hiệu của syscall.
*   Thanh ghi `x0`, `x1`, `x2`... chứa các tham số cho syscall đó.

Các syscall chúng ta cần:
*   `write`: số hiệu là **64**. Tham số:
    *   `x0`: file descriptor (1 cho standard output).
    *   `x1`: địa chỉ của chuỗi cần ghi.
    *   `x2`: độ dài của chuỗi.
*   `exit`: số hiệu là **93**. Tham số:
    *   `x0`: mã thoát (0 là thành công).

**Bắt đầu viết code:**

1.  Mở VS Code và kết nối với WSL (`New WSL Window`).
2.  Mở Terminal tích hợp (`Ctrl + `` `).
3.  Tạo một thư mục mới và di chuyển vào đó:
    ```bash
    mkdir arm_hello
    cd arm_hello
    ```
4.  Tạo một file mới tên là `hello.s`:
    ```bash
    touch hello.s
    ```
5.  Mở file `hello.s` trong editor và dán đoạn code sau vào:

```assembly
/* hello.s - Chương trình Hello World bằng Assembly cho AArch64 Linux */

// Phần .data chứa dữ liệu không thay đổi (hằng số)
.data
hello_msg:
    .ascii "Hello, ARM64 from WSL!\n" // Chuỗi ký tự của chúng ta
msg_len = . - hello_msg              // Tự động tính độ dài chuỗi

// Phần .text chứa mã lệnh thực thi
.text
.global _start                       // Đánh dấu _start là điểm vào của chương trình

_start:
    // --- Gọi syscall WRITE ---
    // Chuẩn bị tham số
    mov x0, #1                       // tham số 1: file descriptor (1 = stdout)
    ldr x1, =hello_msg               // tham số 2: địa chỉ của chuỗi
    mov x2, #msg_len                 // tham số 3: độ dài của chuỗi

    // Chuẩn bị số hiệu syscall
    mov x8, #64                      // Số hiệu syscall 'write' cho ARM64
    svc #0                           // Thực hiện lời gọi hệ thống (system call)

    // --- Gọi syscall EXIT ---
    // Chuẩn bị tham số
    mov x0, #0                       // tham số 1: mã thoát (0 = thành công)

    // Chuẩn bị số hiệu syscall
    mov x8, #93                      // Số hiệu syscall 'exit' cho ARM64
    svc #0                           // Thực hiện lời gọi hệ thống
```

**Giải thích code:**
*   `.data`: Khai báo vùng dữ liệu.
*   `hello_msg:`: Một nhãn (label) để đánh dấu địa chỉ bắt đầu của chuỗi.
*   `.ascii`: Chỉ thị cho assembler tạo ra một chuỗi ký tự.
*   `msg_len = . - hello_msg`: Một mẹo của assembler để tự động tính toán độ dài. `.` đại diện cho địa chỉ hiện tại.
*   `.text`: Khai báo vùng mã lệnh.
*   `.global _start`: Giống như `main` trong C, đây là điểm mà linker sẽ tìm để bắt đầu chương trình.
*   `mov x0, #1`: Lệnh `MOV` (move) để đưa giá trị số `1` vào thanh ghi `x0`.
*   `ldr x1, =hello_msg`: Lệnh `LDR` (load register) đặc biệt. Nó không tải nội dung, mà là tải **địa chỉ** của `hello_msg` vào `x1`.
*   `svc #0`: Lệnh "Supervisor Call", đây chính là lệnh thực hiện syscall để "gọi" kernel.

---

### **Bước 2: Biên dịch (Assemble và Link)**

Bây giờ, chúng ta sẽ dùng toolchain đã cài để biến file `hello.s` thành một file thực thi.

1.  **Assembling (Dịch Assembly ra mã máy):**
    Lệnh này đọc file `hello.s` và tạo ra một file object (`hello.o`) chứa mã máy nhưng chưa phải là file thực thi hoàn chỉnh.
    ```bash
    aarch64-linux-gnu-as hello.s -o hello.o
    ```

2.  **Linking (Liên kết):**
    Lệnh này lấy file object (`hello.o`) và liên kết các phần lại với nhau để tạo ra một file thực thi ELF cuối cùng (`hello`).
    ```bash
    aarch64-linux-gnu-ld hello.o -o hello
    ```

Sau khi chạy xong 2 lệnh này, nếu không có lỗi, bạn sẽ thấy file `hello` và `hello.o` trong thư mục.

### **Bước 3: Kiểm tra file thực thi**

Trước khi chạy, hãy kiểm tra xem file đã được tạo đúng cho kiến trúc ARM64 chưa.

```bash
file hello
```

Bạn sẽ thấy một output tương tự như sau:
`hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, not stripped`

*   **ELF 64-bit:** Đúng định dạng.
*   **ARM aarch64:** Đúng kiến trúc.
*   **statically linked:** Được liên kết tĩnh (vì chúng ta không dùng thư viện ngoài).

Vậy là bạn đã thành công tạo ra một chương trình ARM64 đầu tiên trên môi trường Windows!

---

### **Bước 4: Chạy thử (Cần một môi trường ARM64)**

Vì máy tính của bạn là x86_64, bạn không thể chạy trực tiếp file `hello`. Chúng ta cần một trình giả lập hoặc một thiết bị thật.

1.  **Cài đặt QEMU (Trình giả lập):** Đây là cách nhanh nhất để chạy thử ngay trên WSL.
    ```bash
    sudo apt install qemu-user-static
    ```
    `qemu-user-static` cho phép bạn chạy các file thực thi của kiến trúc khác một cách trong suốt.

2.  **Chạy chương trình:**
    Bây giờ, bạn chỉ cần gõ lệnh như bình thường:
    ```bash
    ./hello
    ```

**Kết quả mong đợi:**
Terminal sẽ in ra dòng chữ:
`Hello, ARM64 from WSL!`

Nếu bạn thấy dòng chữ này, xin chúc mừng! Bạn đã hoàn thành toàn bộ chu trình: **viết code Assembly -> biên dịch chéo -> chạy trên môi trường giả lập ARM64**, tất cả đều nằm trong Windows.