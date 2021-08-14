	.cpu cortex-m0
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.code	16
	.file	"testcalls.c"
	.comm	gl,4,4
	.text
	.align	2
	.global	f
	.code	16
	.thumb_func
	.type	f, %function
f:
	push	{r7, lr}
	add	r7, sp, #0
	mov	r8, r8
	mov	sp, r7
	@ sp needed for prologue
	pop	{r7, pc}
	.size	f, .-f
	.align	2
	.global	g
	.code	16
	.thumb_func
	.type	g, %function
g:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	lsl	r3, r3, #1
	add	r3, r3, #9
	mov	r0, r3
	mov	sp, r7
	add	sp, sp, #8
	@ sp needed for prologue
	pop	{r7, pc}
	.size	g, .-g
	.align	2
	.global	h
	.code	16
	.thumb_func
	.type	h, %function
h:
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	str	r0, [r7, #4]
	mov	r2, r1
	add	r3, r7, #3
	strb	r2, [r3]
	add	r3, r7, #3
	ldrb	r3, [r3]
	lsl	r2, r3, #1
	ldr	r3, [r7, #4]
	add	r3, r2, r3
	mov	r0, r3
	mov	sp, r7
	add	sp, sp, #8
	@ sp needed for prologue
	pop	{r7, pc}
	.size	h, .-h
	.align	2
	.global	i
	.code	16
	.thumb_func
	.type	i, %function
i:
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #12]
	str	r1, [r7, #8]
	str	r2, [r7, #4]
	str	r3, [r7]
	ldr	r3, [r7, #8]
	lsl	r2, r3, #1
	ldr	r3, [r7, #12]
	add	r1, r2, r3
	ldr	r2, [r7, #4]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	add	r2, r1, r3
	ldr	r3, [r7]
	lsl	r3, r3, #2
	add	r1, r2, r3
	ldr	r2, [r7, #32]
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	add	r1, r1, r3
	ldr	r2, [r7, #36]
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	lsl	r3, r3, #1
	add	r3, r1, r3
	str	r3, [r7, #20]
	ldr	r3, .L9
	ldr	r2, [r7, #20]
	str	r2, [r3]
	ldr	r3, .L9
	ldr	r3, [r3]
	mov	r0, r3
	mov	sp, r7
	add	sp, sp, #24
	@ sp needed for prologue
	pop	{r7, pc}
.L10:
	.align	2
.L9:
	.word	gl
	.size	i, .-i
	.align	2
	.global	main
	.code	16
	.thumb_func
	.type	main, %function
main:
	push	{r7, lr}
	sub	sp, sp, #24
	add	r7, sp, #8
	mov	r3, #0
	str	r3, [r7, #12]
	mov	r3, #1
	str	r3, [r7, #8]
	add	r3, r7, #7
	mov	r2, #97
	strb	r2, [r3]
	bl	f
	ldr	r3, [r7, #12]
	mov	r0, r3
	bl	g
	mov	r3, r0
	str	r3, [r7, #12]
	ldr	r2, [r7, #8]
	add	r3, r7, #7
	ldrb	r3, [r3]
	mov	r0, r2
	mov	r1, r3
	bl	h
	mov	r3, r0
	str	r3, [r7, #12]
	mov	r3, #5
	str	r3, [sp]
	mov	r3, #6
	str	r3, [sp, #4]
	mov	r0, #1
	mov	r1, #2
	mov	r2, #3
	mov	r3, #4
	bl	i
	mov	r3, r0
	str	r3, [r7, #12]
	mov	r3, #0
	mov	r0, r3
	mov	sp, r7
	add	sp, sp, #16
	@ sp needed for prologue
	pop	{r7, pc}
	.size	main, .-main
	.ident	"GCC: (GNU Tools for ARM Embedded Processors) 4.7.4 20130613 (release) [ARM/embedded-4_7-branch revision 200083]"
