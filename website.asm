format ELF64 executable


SYS_socket = 41
SYS_exit = 60
SYS_write = 1

AF_INET = 2 
SOCK_STREAM = 1


macro write fd, buf, count
{
    mov rax, 1
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

;; int socket(int domain, int type, int protocal);
macro socket  domain , type , protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

segment readable executable
entry main

main:
    write 1,msg,msg_len
    socket AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl error
    mov dword [socketfd], eax     

    jmp exit

error:
   write 1,error_msg, error_msg_len 
   jl exit_erro


exit:
    mov rax, SYS_exit
    mov rdi, 0
    syscall

exit_erro:
    mov rax, SYS_exit
    mov rdi, 1
    syscall


;; db - 1 byte
;; dw - 2 bytes
;; dd - 4 bytes
;; dq - 8 bytes or 1 bit

segment readable writable
socketfd dd 0 
msg db 'Web server starting!!!', 10, 0 
msg_len = $ - msg

error_msg  db 'Error', 10
error_msg_len = len $ - error_msg