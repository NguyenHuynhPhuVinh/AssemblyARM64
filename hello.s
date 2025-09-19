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