format ELF64 executable

SYS_write = 1
SYS_close = 3
SYS_socket = 41
SYS_accept = 43
SYS_bind = 49
SYS_listen = 50
SYS_exit = 60

STD_out  = 1
STD_error = 2

EXIT_FAILURE = 0
EXIT_SUCCESS = 1

AF_INET = 2 
SOCK_STREAM = 1
INADDR_ANY = 0
MAX_CONNECTIONS = 5

macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a,b 
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b ,c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}

macro write fd, buf, count
{
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro exit code 
{
    mov rax, SYS_exit
    mov rdi, code
    syscall
}

macro socket  domain , type , protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

macro bind fd, addr, addrlen
{
    syscall3 SYS_bind, fd, addr, addrlen
}

macro listen fd, backlog
{
    syscall2 SYS_listen, fd, backlog
}

macro accept fd, addr, addrlen
{
    syscall3 SYS_accept, fd, addr, addrlen
}


macro close fd 
{
    syscall1 SYS_close, fd

}

segment readable executable
entry main

main:
    write STD_out, msg, msg_len
    write STD_out, socket_log, socket_log_len
    socket AF_INET, SOCK_STREAM, 0
    cmp rax, 0
    jl error
    mov qword [sockfd], rax

    mov word [serveraddr.sin_family], AF_INET
    mov word [serveraddr.sin_port], 14619
    mov dword [serveraddr.sin_addr], INADDR_ANY

    write STD_out, socket_bind_log, socket_bind_log_len
    bind [sockfd], serveraddr.sin_family, serveraddr_size
    cmp rax, 0
    jl error

    write STD_out,listen_log, listen_log_len
    listen [sockfd], MAX_CONNECTIONS
    cmp rax, 0
    jl error

next_request:    
    write STD_out,accept_tracing, accept_log_len
    accept [sockfd], clientaddr.sin_family, clientaddr_len
    cmp rax, 0
    jl error
    mov qword [connfd], rax
    
    write [connfd], response, response_len
    jmp next_request
    
    write STD_out, ok_log, ok_log_len

    close [connfd]
    close [sockfd]
    exit EXIT_SUCCESS

error:
    write STD_error, error_msg, error_msg_len 
    close [connfd]
    close [sockfd]
    exit EXIT_FAILURE

segment readable writable

struc serveraddr_in 
{
    .sin_family dw 0
    .sin_port dw 0
    .sin_addr dd 0
    .sin_zero dq 0  
}

sockfd dq -1
connfd dq -1

serveraddr serveraddr_in 
clientaddr serveraddr_in

serveraddr_size = $ - serveraddr.sin_family
clientaddr_len dd serveraddr_size


response db 'HTTP/1.1 200 OK',13 , 10
         db 'Content-type: text/html; charset=utf-8', 13, 10
         db 'Connection: close', 13, 10
         db 13,10
         db '<h1> Web server made entirely in assembly, using FASM assembler</h1>', 10

response_len = $ - response

msg db 'INFO: Web server starting!!!', 10, 0 
msg_len = $ - msg
socket_log db 'INFO: Openning socket...', 10, 0 
socket_log_len = $ - socket_log
socket_bind_log db 'INFO: Binding Socket...', 10, 0 
socket_bind_log_len = $ - socket_bind_log
listen_log db 'INFO: Listenning socket...', 10, 0 
listen_log_len = $ -  listen_log
hello db 'Hello from Flat Assembler Web Server', 10, 0 
hello_len = $ -  hello
accept_tracing db 'INFO: Waiting to client to connect...', 10, 0 
accept_log_len = $ -  accept_tracing
error_msg  db 'INFO: Error!', 10
error_msg_len = $ - error_msg
ok_log db 'INFO: OK!', 10,0
ok_log_len = $ - ok_log
