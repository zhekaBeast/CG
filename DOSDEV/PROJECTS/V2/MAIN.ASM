	.286p
	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "main.c"
	?debug	C E952B0315D066D61696E2E63
	?debug	C E936B6315D08636F6D6D6F6E2E68
	?debug	C E9AE95305D15633A5C42435C494E434C5544455C636F6E696F2E68
	?debug	C E9AF95305D15633A5C42435C494E434C5544455C5F646566732E68
	?debug	C E9AE95305D14633A5C42435C494E434C5544455C74696D652E68
	?debug	C E9AE95305D13633A5C42435C494E434C5544455C646F732E68
	?debug	C E9AE95305D14633A5C42435C494E434C5544455C6D6174682E68
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:MAIN_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
view_w	label	word
	db	64
	db	1
prev_view_w	label	word
	db	64
	db	1
view_h	label	word
	db	200
	db	0
prev_view_h	label	word
	db	64
	db	1
fps	label	word
	db	60
	db	0
_vram	label	dword
	db	0
	db	0
	db	0
	db	0
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
   ;	
   ;	static void triangle_init(Triangle *t, float dangle, float side)
   ;	
	assume	cs:MAIN_TEXT
triangle_init	proc	far
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	 t->dangle = dangle;
   ;	
	les	bx,dword ptr [bp+6]
	mov	ax,word ptr [bp+12]
	mov	dx,word ptr [bp+10]
	mov	word ptr es:[bx+6],ax
	mov	word ptr es:[bx+4],dx
   ;	
   ;	 t->side = side;
   ;	
	mov	ax,word ptr [bp+16]
	mov	dx,word ptr [bp+14]
	mov	word ptr es:[bx+10],ax
	mov	word ptr es:[bx+8],dx
   ;	
   ;	}
   ;	
	pop	bp
	ret	
triangle_init	endp
   ;	
   ;	static void line(int x0, int y0, int x1, int y1, unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
line	proc	far
	enter	12,0
	push	si
	push	di
	mov	dx,word ptr [bp+6]
	mov	cx,word ptr [bp+8]
	mov	si,word ptr [bp+10]
	mov	di,word ptr [bp+12]
   ;	
   ;	{
   ;	 int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
   ;	
	cmp	si,dx
	jle	short @2@86
	mov	ax,si
	sub	ax,dx
	jmp	short @2@114
@2@86:
	mov	ax,dx
	sub	ax,si
@2@114:
	mov	word ptr [bp-2],ax
   ;	
   ;	 int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
   ;	
	cmp	di,cx
	jle	short @2@170
	mov	ax,di
	sub	ax,cx
	jmp	short @2@198
@2@170:
	mov	ax,cx
	sub	ax,di
@2@198:
	mov	word ptr [bp-4],ax
   ;	
   ;	 int sx = (x0 < x1) ? 1 : -1;
   ;	
	cmp	dx,si
	jge	short @2@254
	mov	ax,1
	jmp	short @2@282
@2@254:
	mov	ax,-1
@2@282:
	mov	word ptr [bp-6],ax
   ;	
   ;	 int sy = (y0 < y1) ? 1 : -1;
   ;	
	cmp	cx,di
	jge	short @2@338
	mov	ax,1
	jmp	short @2@366
@2@338:
	mov	ax,-1
@2@366:
	mov	word ptr [bp-8],ax
   ;	
   ;	 int err = dx - dy;
   ;	
	mov	ax,word ptr [bp-2]
	sub	ax,word ptr [bp-4]
	mov	word ptr [bp-10],ax
@2@394:
   ;	
   ;	
   ;	 while (1)
   ;	 {
   ;	  pixel(x0, y0, color);
   ;	
	mov	bx,dx
	mov	word ptr [bp-12],cx
	cmp	bx,word ptr DGROUP:view_w
	jae	short @2@478
	mov	ax,word ptr [bp-12]
	cmp	ax,word ptr DGROUP:view_h
	jae	short @2@478
	imul	ax,ax,320
	add	ax,bx
	les	bx,dword ptr DGROUP:_vram
	add	bx,ax
	mov	al,byte ptr [bp+14]
	mov	byte ptr es:[bx],al
@2@478:
   ;	
   ;	  if (x0 == x1 && y0 == y1)
   ;	
	cmp	dx,si
	jne	short @2@534
	cmp	cx,di
	je	short @2@646
@2@534:
   ;	
   ;	   break;
   ;	  {
   ;	   int e2 = 2 * err;
   ;	
	mov	bx,word ptr [bp-10]
	shl	bx,1
   ;	
   ;	   if (e2 > -dy)
   ;	
	mov	ax,word ptr [bp-4]
	neg	ax
	cmp	ax,bx
	jge	short @2@590
   ;	
   ;	   {
   ;	    err -= dy;
   ;	
	mov	ax,word ptr [bp-4]
	sub	word ptr [bp-10],ax
   ;	
   ;	    x0 += sx;
   ;	
	add	dx,word ptr [bp-6]
@2@590:
   ;	
   ;	   }
   ;	   if (e2 < dx)
   ;	
	cmp	bx,word ptr [bp-2]
	jge	short @2@394
   ;	
   ;	   {
   ;	    err += dx;
   ;	
	mov	ax,word ptr [bp-2]
	add	word ptr [bp-10],ax
   ;	
   ;	    y0 += sy;
   ;	
	add	cx,word ptr [bp-8]
	jmp	short @2@394
@2@646:
   ;	
   ;	   }
   ;	  }
   ;	 }
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
line	endp
   ;	
   ;	static void fill_rect(int x0, int y0, int x1, int y1, unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
fill_rect	proc	far
	enter	8,0
	push	si
	push	di
	mov	si,word ptr [bp+6]
	mov	dx,word ptr [bp+8]
   ;	
   ;	{
   ;	    int x, y;
   ;	    if (x0 < 0) x0 = 0;
   ;	
	or	si,si
	jge	short @3@86
	xor	si,si
@3@86:
   ;	
   ;	    if (y0 < 0) y0 = 0;
   ;	
	or	dx,dx
	jge	short @3@142
	xor	dx,dx
@3@142:
   ;	
   ;	    if (x1 > SCREEN_W) x1 = SCREEN_W;
   ;	
	cmp	word ptr [bp+10],320
	jle	short @3@198
	mov	word ptr [bp+10],320
@3@198:
   ;	
   ;	    if (y1 > SCREEN_H) y1 = SCREEN_H;
   ;	
	cmp	word ptr [bp+12],200
	jle	short @3@254
	mov	word ptr [bp+12],200
@3@254:
   ;	
   ;	    for (y = y0; y < y1; y++)
   ;	
	mov	word ptr [bp-4],dx
	mov	ax,word ptr [bp-4]
	cmp	ax,word ptr [bp+12]
	jge	short @3@534
@3@310:
   ;	
   ;	    {
   ;	        unsigned char far *row = vram + (unsigned long)y * SCREEN_W;
   ;	
	mov	ax,word ptr [bp-4]
	cwd	
	push	ax
	push	dx
	xor	dx,dx
	mov	ax,320
	pop	cx
	pop	bx
	call	far ptr F_LXMUL@
	mov	dx,word ptr DGROUP:_vram+2
	mov	bx,word ptr DGROUP:_vram
	add	bx,ax
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],bx
   ;	
   ;	        for (x = x0; x < x1; x++)
   ;	
	mov	word ptr [bp-2],si
	mov	ax,word ptr [bp+10]
	cmp	word ptr [bp-2],ax
	jge	short @3@478
	mov	cx,word ptr [bp+10]
	sub	cx,si
	mov	di,word ptr [bp-8]
	add	di,si
	mov	es,word ptr [bp-6]
	mov	al,byte ptr [bp+14]
	mov	ah,al
	shr	cx,1
	rep 	stosw	
	jnc	short @3@478
	stosb	
@3@478:
	inc	word ptr [bp-4]
	mov	ax,word ptr [bp-4]
	cmp	ax,word ptr [bp+12]
	jl	short @3@310
@3@534:
   ;	
   ;	            row[x] = color;
   ;	    }
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
fill_rect	endp
   ;	
   ;	static void color_view(void)
   ;	
	assume	cs:MAIN_TEXT
color_view	proc	far
	enter	4,0
	push	si
	push	di
   ;	
   ;	{
   ;	    int w = view_w;
   ;	
	mov	si,word ptr DGROUP:view_w
   ;	
   ;	    int h = view_h;
   ;	
	mov	di,word ptr DGROUP:view_h
   ;	
   ;	    int pw = prev_view_w;
   ;	
	mov	ax,word ptr DGROUP:prev_view_w
	mov	word ptr [bp-2],ax
   ;	
   ;	    int ph = prev_view_h;
   ;	
	mov	ax,word ptr DGROUP:prev_view_h
	mov	word ptr [bp-4],ax
   ;	
   ;	
   ;	    /* --- По горизонтали --- */
   ;	    if (w > pw)
   ;	
	cmp	si,word ptr [bp-2]
	jle	short @4@86
   ;	
   ;	    {
   ;	        /* окно расширилось: справа появилась новая зона — красим тёмным */
   ;	        fill_rect(pw, 0, w, h, BLACK_BG);
   ;	
	push	0
	push	di
	push	si
	push	0
	push	word ptr [bp-2]
	jmp	short @4@142
@4@86:
   ;	
   ;	    }
   ;	    else if (w < pw)
   ;	
	cmp	si,word ptr [bp-2]
	jge	short @4@170
   ;	
   ;	    {
   ;	        /* окно сузилось: полоса справа стала "вне окна" — красим белым */
   ;	        fill_rect(w, 0, pw, ph, WHITE_BG);
   ;	
	push	15
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	push	0
	push	si
@4@142:
	push	cs
	call	near ptr fill_rect
	add	sp,10
@4@170:
   ;	
   ;	    }
   ;	
   ;	    /* --- По вертикали --- */
   ;	    if (h > ph)
   ;	
	cmp	di,word ptr [bp-4]
	jle	short @4@226
   ;	
   ;	    {
   ;	        /* окно выросло вниз: новая зона снизу — тёмным */
   ;	        fill_rect(0, ph, w, h, BLACK_BG);
   ;	
	push	0
	push	di
	push	si
	push	word ptr [bp-4]
	jmp	short @4@282
@4@226:
   ;	
   ;	    }
   ;	    else if (h < ph)
   ;	
	cmp	di,word ptr [bp-4]
	jge	short @4@310
   ;	
   ;	    {
   ;	        /* окно сузилось по высоте: полоса снизу — белым */
   ;	        fill_rect(0, h, pw, ph, WHITE_BG);
   ;	
	push	15
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	push	di
@4@282:
	push	0
	push	cs
	call	near ptr fill_rect
	add	sp,10
@4@310:
   ;	
   ;	    }
   ;	
   ;	    /* Запоминаем текущие размеры как предыдущие */
   ;	    prev_view_w = w;
   ;	
	mov	word ptr DGROUP:prev_view_w,si
   ;	
   ;	    prev_view_h = h;
   ;	
	mov	word ptr DGROUP:prev_view_h,di
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
color_view	endp
   ;	
   ;	static void tri_vertex(const Body *b, int i, float *out_x, float *out_y)
   ;	
	assume	cs:MAIN_TEXT
tri_vertex	proc	far
	enter	28,0
   ;	
   ;	{
   ;	 float local = b->tri.angle + (float)(M_PI / 2.0) + (float)i * (float)(2.0 * M_PI / 3.0);
   ;	
	mov	ax,word ptr [bp+10]
	mov	word ptr [bp-6],ax
	fild	word ptr [bp-6]
	fmul	dword ptr DGROUP:s@
	les	bx,dword ptr [bp+6]
	fld	dword ptr es:[bx]
	fadd	dword ptr DGROUP:s@+4
	fadd	
	fstp	dword ptr [bp-4]
   ;	
   ;	 float r = b->tri.side / sqrt(3.0f);
   ;	
	fwait	
	les	bx,dword ptr [bp+6]
	fld	dword ptr es:[bx+8]
	fstp	tbyte ptr [bp-28]
	fld	dword ptr DGROUP:s@+8
	sub	sp,8
	fstp	qword ptr [bp-36]
	fwait	
	call	far ptr _sqrt
	add	sp,8
	fld	tbyte ptr [bp-28]
	fdivr	
	fstp	dword ptr [bp-10]
   ;	
   ;	 float wx = b->pos.x + r * cos(local);
   ;	
	fld	dword ptr [bp-10]
	fstp	tbyte ptr [bp-28]
	fld	dword ptr [bp-4]
	sub	sp,8
	fstp	qword ptr [bp-36]
	fwait	
	call	far ptr _cos
	add	sp,8
	fld	tbyte ptr [bp-28]
	fmul	
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx+36]
	fstp	dword ptr [bp-14]
   ;	
   ;	 float wy = b->pos.y + r * sin(local);
   ;	
	fld	dword ptr [bp-10]
	fstp	tbyte ptr [bp-28]
	fld	dword ptr [bp-4]
	sub	sp,8
	fstp	qword ptr [bp-36]
	fwait	
	call	far ptr _sin
	add	sp,8
	fld	tbyte ptr [bp-28]
	fmul	
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx+40]
	fstp	dword ptr [bp-18]
   ;	
   ;	 *out_x = wx + 0.5f;
   ;	
	fld	dword ptr [bp-14]
	fadd	dword ptr DGROUP:s@+12
	les	bx,dword ptr [bp+12]
	fstp	dword ptr es:[bx]
   ;	
   ;	 *out_y = wy + 0.5f;
   ;	
	fld	dword ptr [bp-18]
	fadd	dword ptr DGROUP:s@+12
	les	bx,dword ptr [bp+16]
	fstp	dword ptr es:[bx]
	fwait	
   ;	
   ;	}
   ;	
	leave	
	ret	
tri_vertex	endp
   ;	
   ;	static int resolve_collision(Body *b)
   ;	
	assume	cs:MAIN_TEXT
resolve_collision	proc	far
	enter	22,0
   ;	
   ;	{
   ;	 Point *w = b->tri.points;
   ;	
	mov	ax,word ptr [bp+8]
	mov	dx,word ptr [bp+6]
	add	dx,12
	mov	word ptr [bp-2],ax
	mov	word ptr [bp-4],dx
   ;	
   ;	 int hit = 0;
   ;	
	xor	cx,cx
   ;	
   ;	 int i;
   ;	 /* Ищем самые «выступающие» точки по каждой оси */
   ;	 float minX = w[0].x, maxX = w[0].x;
   ;	
	les	bx,dword ptr [bp-4]
	fld	dword ptr es:[bx]
	fstp	dword ptr [bp-8]
	fwait	
	les	bx,dword ptr [bp-4]
	fld	dword ptr es:[bx]
	fstp	dword ptr [bp-12]
   ;	
   ;	 float minY = w[0].y, maxY = w[0].y;
   ;	
	fwait	
	les	bx,dword ptr [bp-4]
	fld	dword ptr es:[bx+4]
	fstp	dword ptr [bp-16]
	fwait	
	les	bx,dword ptr [bp-4]
	fld	dword ptr es:[bx+4]
	fstp	dword ptr [bp-20]
   ;	
   ;	 for (i = 0; i < 3; i++)
   ;	
	xor	dx,dx
	fwait	
@6@58:
   ;	
   ;	 {
   ;	  if (w[i].x < minX)
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx]
	fcomp	dword ptr [bp-8]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jae	short @6@114
   ;	
   ;	   minX = w[i].x;
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx]
	fstp	dword ptr [bp-8]
	fwait	
@6@114:
   ;	
   ;	  if (w[i].x > maxX)
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx]
	fcomp	dword ptr [bp-12]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jbe	short @6@170
   ;	
   ;	   maxX = w[i].x;
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx]
	fstp	dword ptr [bp-12]
	fwait	
@6@170:
   ;	
   ;	  if (w[i].y < minY)
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx+4]
	fcomp	dword ptr [bp-16]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jae	short @6@226
   ;	
   ;	   minY = w[i].y;
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx+4]
	fstp	dword ptr [bp-16]
	fwait	
@6@226:
   ;	
   ;	  if (w[i].y > maxY)
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx+4]
	fcomp	dword ptr [bp-20]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jbe	short @6@282
   ;	
   ;	   maxY = w[i].y;
   ;	
	mov	ax,dx
	shl	ax,3
	les	bx,dword ptr [bp-4]
	add	bx,ax
	fld	dword ptr es:[bx+4]
	fstp	dword ptr [bp-20]
	fwait	
@6@282:
	inc	dx
	cmp	dx,3
	jge	@@0
	jmp	@6@58
@@0:
   ;	
   ;	 }
   ;	
   ;	 /* ---------- ГОРИЗОНТАЛЬНЫЕ СТЕНКИ: только зеркало, без импульса ---------- */
   ;	 if (minX < LEFT_LIMIT)
   ;	
	fld	dword ptr [bp-8]
	fldz	
	fcompp
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jbe	short @6@394
   ;	
   ;	 {
   ;	  b->pos.x += (LEFT_LIMIT - minX); /* выталкиваем внутрь */
   ;	
	les	bx,dword ptr [bp+6]
	fld	dword ptr es:[bx+36]
	fldz	
	fsub	dword ptr [bp-8]
	fadd	
	les	bx,dword ptr [bp+6]
	fstp	dword ptr es:[bx+36]
   ;	
   ;	  b->vel.x = -b->vel.x;            /* отражение */
   ;	
	fld	dword ptr es:[bx+44]
	fchs	
	les	bx,dword ptr [bp+6]
	fstp	dword ptr es:[bx+44]
   ;	
   ;	  hit |= 4;
   ;	
	or	cx,4
   ;	
   ;	 }
   ;	
	fwait	
	jmp	short @6@450
@6@394:
   ;	
   ;	 else if (maxX > RIGHT_LIMIT)
   ;	
	mov	ax,word ptr DGROUP:view_w
	mov	word ptr [bp-22],ax
	fild	word ptr [bp-22]
	fcomp	dword ptr [bp-12]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jae	short @6@450
   ;	
   ;	 {
   ;	  b->pos.x -= (maxX - RIGHT_LIMIT);
   ;	
	mov	ax,word ptr DGROUP:view_w
	mov	word ptr [bp-22],ax
	fild	word ptr [bp-22]
	fsubr	dword ptr [bp-12]
	les	bx,dword ptr [bp+6]
	fsubr	dword ptr es:[bx+36]
	fstp	dword ptr es:[bx+36]
   ;	
   ;	  b->vel.x = -b->vel.x;
   ;	
	fld	dword ptr es:[bx+44]
	fchs	
	les	bx,dword ptr [bp+6]
	fstp	dword ptr es:[bx+44]
   ;	
   ;	  hit |= 8;
   ;	
	or	cx,8
	fwait	
@6@450:
   ;	
   ;	 }
   ;	
   ;	 /* ---------- ВЕРХ: зеркало, импульс опционален ---------- */
   ;	 if (minY < TOP_LIMIT)
   ;	
	fld	dword ptr [bp-16]
	fldz	
	fcompp
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jbe	short @6@506
   ;	
   ;	 {
   ;	  b->pos.y += (TOP_LIMIT - minY);
   ;	
	les	bx,dword ptr [bp+6]
	fld	dword ptr es:[bx+40]
	fldz	
	fsub	dword ptr [bp-16]
	fadd	
	les	bx,dword ptr [bp+6]
	fstp	dword ptr es:[bx+40]
   ;	
   ;	  b->vel.y = 0;
   ;	
	fwait	
	mov	word ptr es:[bx+50],0
	mov	word ptr es:[bx+48],0
   ;	
   ;	  hit |= 1;
   ;	
	or	cx,1
@6@506:
   ;	
   ;	 }
   ;	
   ;	 /* ---------- НИЗ: зеркало + импульс вверх ---------- */
   ;	 if (maxY > BOTTOM_LIMIT)
   ;	
	mov	ax,word ptr DGROUP:view_h
	mov	word ptr [bp-22],ax
	fild	word ptr [bp-22]
	fcomp	dword ptr [bp-20]
	fstsw	word ptr [bp-22]
	fwait	
	mov	ax,word ptr [bp-22]
	sahf	
	jae	short @6@562
   ;	
   ;	 {
   ;	  b->pos.y -= (maxY - BOTTOM_LIMIT);
   ;	
	mov	ax,word ptr DGROUP:view_h
	mov	word ptr [bp-22],ax
	fild	word ptr [bp-22]
	fsubr	dword ptr [bp-20]
	les	bx,dword ptr [bp+6]
	fsubr	dword ptr es:[bx+40]
	fstp	dword ptr es:[bx+40]
   ;	
   ;	  b->vel.y = -b->vel.y; /* отражение */
   ;	
	fld	dword ptr es:[bx+48]
	fchs	
	les	bx,dword ptr [bp+6]
	fstp	dword ptr es:[bx+48]
   ;	
   ;	
   ;	  /* Добавляем импульс ВВЕРХ.*/
   ;	  b->vel.y -= b->impulse;
   ;	
	fld	dword ptr es:[bx+56]
	les	bx,dword ptr [bp+6]
	fsubr	dword ptr es:[bx+48]
	fstp	dword ptr es:[bx+48]
   ;	
   ;	  hit |= 2;
   ;	
	or	cx,2
	fwait	
@6@562:
   ;	
   ;	 }
   ;	
   ;	 return hit;
   ;	
	mov	ax,cx
   ;	
   ;	}
   ;	
	leave	
	ret	
resolve_collision	endp
   ;	
   ;	static void draw_triangle(const Triangle *t, unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
draw_triangle	proc	far
	enter	18,0
	push	si
   ;	
   ;	{
   ;	 int i;
   ;	 /* Три стороны треугольника */
   ;	 for (i = 0; i < 3; ++i)
   ;	
	xor	si,si
@7@58:
   ;	
   ;	 {
   ;	  int j = (i + 1) % 3;
   ;	
	mov	ax,si
	inc	ax
	mov	bx,3
	cwd	
	idiv	bx
	mov	word ptr [bp-2],dx
   ;	
   ;	  Point pa = t->points[i];
   ;	
	lea	ax,word ptr [bp-10]
	push	ss
	push	ax
	mov	ax,si
	shl	ax,3
	mov	dx,word ptr [bp+6]
	add	dx,ax
	add	dx,12
	push	word ptr [bp+8]
	push	dx
	mov	cx,8
	call	far ptr F_SCOPY@
   ;	
   ;	  Point pb = t->points[j];
   ;	
	lea	ax,word ptr [bp-18]
	push	ss
	push	ax
	mov	ax,word ptr [bp-2]
	shl	ax,3
	mov	dx,word ptr [bp+6]
	add	dx,ax
	add	dx,12
	push	word ptr [bp+8]
	push	dx
	mov	cx,8
	call	far ptr F_SCOPY@
   ;	
   ;	  line(pa.x, pa.y, pb.x, pb.y, color);
   ;	
	mov	al,byte ptr [bp+10]
	push	ax
	fld	dword ptr [bp-14]
	call	far ptr F_FTOL@
	push	ax
	fld	dword ptr [bp-18]
	call	far ptr F_FTOL@
	push	ax
	fld	dword ptr [bp-6]
	call	far ptr F_FTOL@
	push	ax
	fld	dword ptr [bp-10]
	call	far ptr F_FTOL@
	push	ax
	push	cs
	call	near ptr line
	add	sp,10
	inc	si
	cmp	si,3
	jge	@@1
	jmp	@7@58
@@1:
   ;	
   ;	 }
   ;	}
   ;	
	pop	si
	leave	
	ret	
draw_triangle	endp
   ;	
   ;	static void update_parameters(Body *b)
   ;	
	assume	cs:MAIN_TEXT
update_parameters	proc	far
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	 int i;
   ;	 // Гравитация
   ;	 b->vel.y += b->g;
   ;	
	les	bx,dword ptr [bp+6]
	fld	dword ptr es:[bx+52]
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx+48]
	fstp	dword ptr es:[bx+48]
   ;	
   ;	 // Сдвиг центра
   ;	 b->pos.x += b->vel.x;
   ;	
	fld	dword ptr es:[bx+44]
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx+36]
	fstp	dword ptr es:[bx+36]
   ;	
   ;	 b->pos.y += b->vel.y;
   ;	
	fld	dword ptr es:[bx+48]
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx+40]
	fstp	dword ptr es:[bx+40]
   ;	
   ;	 // Вращение
   ;	 b->tri.angle += b->tri.dangle;
   ;	
	fld	dword ptr es:[bx+4]
	les	bx,dword ptr [bp+6]
	fadd	dword ptr es:[bx]
	fstp	dword ptr es:[bx]
   ;	
   ;	 // Вычисление новых точек
   ;	 for (i = 0; i < 3; i++)
   ;	
	xor	si,si
	fwait	
@8@58:
   ;	
   ;	  tri_vertex(b, i, &b->tri.points[i].x, &b->tri.points[i].y);
   ;	
	mov	ax,si
	shl	ax,3
	mov	dx,word ptr [bp+6]
	add	dx,ax
	add	dx,16
	push	word ptr [bp+8]
	push	dx
	mov	ax,si
	shl	ax,3
	mov	dx,word ptr [bp+6]
	add	dx,ax
	add	dx,12
	push	word ptr [bp+8]
	push	dx
	push	si
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	cs
	call	near ptr tri_vertex
	add	sp,14
	inc	si
	cmp	si,3
	jl	short @8@58
   ;	
   ;	 // Меняем по колизиям векторы
   ;	 resolve_collision(b);
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	cs
	call	near ptr resolve_collision
	add	sp,4
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	
update_parameters	endp
   ;	
   ;	void body_init(Body *b,
   ;	
	assume	cs:MAIN_TEXT
_body_init	proc	far
	push	bp
	mov	bp,sp
   ;	
   ;	               float x, float y,
   ;	               float vx, float vy,
   ;	               float g, float impulse, float side,
   ;	               float dangle, unsigned char color)
   ;	{
   ;	 b->pos.x = x;
   ;	
	les	bx,dword ptr [bp+6]
	mov	ax,word ptr [bp+12]
	mov	dx,word ptr [bp+10]
	mov	word ptr es:[bx+38],ax
	mov	word ptr es:[bx+36],dx
   ;	
   ;	 b->pos.y = y;
   ;	
	mov	ax,word ptr [bp+16]
	mov	dx,word ptr [bp+14]
	mov	word ptr es:[bx+42],ax
	mov	word ptr es:[bx+40],dx
   ;	
   ;	 b->vel.x = vx;
   ;	
	mov	ax,word ptr [bp+20]
	mov	dx,word ptr [bp+18]
	mov	word ptr es:[bx+46],ax
	mov	word ptr es:[bx+44],dx
   ;	
   ;	 b->vel.y = vy;
   ;	
	mov	ax,word ptr [bp+24]
	mov	dx,word ptr [bp+22]
	mov	word ptr es:[bx+50],ax
	mov	word ptr es:[bx+48],dx
   ;	
   ;	 b->g = g;
   ;	
	mov	ax,word ptr [bp+28]
	mov	dx,word ptr [bp+26]
	mov	word ptr es:[bx+54],ax
	mov	word ptr es:[bx+52],dx
   ;	
   ;	 b->impulse = impulse;
   ;	
	mov	ax,word ptr [bp+32]
	mov	dx,word ptr [bp+30]
	mov	word ptr es:[bx+58],ax
	mov	word ptr es:[bx+56],dx
   ;	
   ;	 b->color = color;
   ;	
	mov	al,byte ptr [bp+42]
	mov	byte ptr es:[bx+60],al
   ;	
   ;	 triangle_init(&b->tri, dangle, side);
   ;	
	fld	dword ptr [bp+34]
	sub	sp,4
	fstp	dword ptr [bp-4]
	fld	dword ptr [bp+38]
	sub	sp,4
	fstp	dword ptr [bp-8]
	fwait	
	push	word ptr [bp+8]
	push	bx
	push	cs
	call	near ptr triangle_init
	add	sp,12
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_body_init	endp
   ;	
   ;	void gfx_init(void)
   ;	
	assume	cs:MAIN_TEXT
_gfx_init	proc	far
	enter	16,0
   ;	
   ;	{
   ;	 union REGS r;
   ;	 r.h.ah = 0x00; /* set video mode */
   ;	
	mov	byte ptr [bp-15],0
   ;	
   ;	 r.h.al = 0x13; /* VGA 320x200x256 */
   ;	
	mov	byte ptr [bp-16],19
   ;	
   ;	 int86(0x10, &r, &r);
   ;	
	push	ss
	lea	ax,word ptr [bp-16]
	push	ax
	push	ss
	push	ax
	push	16
	call	far ptr _int86
	add	sp,10
   ;	
   ;	
   ;	 /* сегмент видеопамяти A000:0000 */
   ;	 vram = (unsigned char far *)MK_FP(VIDEO_SEG, 0);
   ;	
	mov	word ptr DGROUP:_vram+2,-24576
	mov	word ptr DGROUP:_vram,0
   ;	
   ;	 last_tick = clock();
   ;	
	call	far ptr _clock
	mov	word ptr DGROUP:last_tick+2,dx
	mov	word ptr DGROUP:last_tick,ax
   ;	
   ;	}
   ;	
	leave	
	ret	
_gfx_init	endp
   ;	
   ;	void gfx_shutdown(void)
   ;	
	assume	cs:MAIN_TEXT
_gfx_shutdown	proc	far
	enter	16,0
   ;	
   ;	{
   ;	 union REGS r;
   ;	 r.h.ah = 0x00;
   ;	
	mov	byte ptr [bp-15],0
   ;	
   ;	 r.h.al = 0x03; /* возврат в текстовый режим */
   ;	
	mov	byte ptr [bp-16],3
   ;	
   ;	 int86(0x10, &r, &r);
   ;	
	push	ss
	lea	ax,word ptr [bp-16]
	push	ax
	push	ss
	push	ax
	push	16
	call	far ptr _int86
	add	sp,10
   ;	
   ;	}
   ;	
	leave	
	ret	
_gfx_shutdown	endp
   ;	
   ;	void wait_frame(void)
   ;	
	assume	cs:MAIN_TEXT
_wait_frame	proc	far
	enter	16,0
   ;	
   ;	{
   ;	 /* Сколько тиков должно пройти между кадрами (float!) */
   ;	 double ticks_per_frame = (double)CLOCKS_PER_SEC / fps;
   ;	
	mov	ax,word ptr DGROUP:fps
	mov	word ptr [bp-12],ax
	fild	word ptr [bp-12]
	fdivr	qword ptr DGROUP:s@+16
	fstp	qword ptr [bp-8]
   ;	
   ;	 clock_t start = clock();
   ;	
	fwait	
	call	far ptr _clock
	mov	word ptr [bp-14],dx
	mov	word ptr [bp-16],ax
@12@58:
   ;	
   ;	 while ((double)(clock() - start) < ticks_per_frame)
   ;	
	call	far ptr _clock
	sub	ax,word ptr [bp-16]
	sbb	dx,word ptr [bp-14]
	mov	word ptr [bp-12],ax
	mov	word ptr [bp-10],dx
	fild	dword ptr [bp-12]
	fcomp	qword ptr [bp-8]
	fstsw	word ptr [bp-12]
	fwait	
	mov	ax,word ptr [bp-12]
	sahf	
	jb	short @12@58
   ;	
   ;	  ;
   ;	}
   ;	
	leave	
	ret	
_wait_frame	endp
   ;	
   ;	void update(Body *b)
   ;	
	assume	cs:MAIN_TEXT
_update	proc	far
	push	bp
	mov	bp,sp
   ;	
   ;	{
   ;	 draw_triangle(&b->tri, BLACK_BG);
   ;	
	push	0
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	cs
	call	near ptr draw_triangle
	add	sp,6
   ;	
   ;	 update_parameters(b);
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	cs
	call	near ptr update_parameters
	add	sp,4
   ;	
   ;	 draw_triangle(&b->tri, b->color);
   ;	
	les	bx,dword ptr [bp+6]
	mov	al,byte ptr es:[bx+60]
	push	ax
	push	word ptr [bp+8]
	push	bx
	push	cs
	call	near ptr draw_triangle
	add	sp,6
   ;	
   ;	}
   ;	
	pop	bp
	ret	
_update	endp
   ;	
   ;	int handle_input(void)
   ;	
	assume	cs:MAIN_TEXT
_handle_input	proc	far
	enter	4,0
   ;	
   ;	{
   ;	 /* 5. Обработка клавиш (ДЗ.Е3) */
   ;	 int key;
   ;	 if (!kbhit()) /* нет нажатия — выходим */
   ;	
	call	far ptr _kbhit
	or	ax,ax
	jne	short @14@86
	jmp	@14@674
@14@86:
   ;	
   ;	  return 1;
   ;	 key = getch();
   ;	
	call	far ptr _getch
	mov	word ptr [bp-2],ax
   ;	
   ;	 switch (key)
   ;	
	mov	word ptr [bp-4],ax
	mov	cx,7
	mov	bx,offset @14@C114
@14@142:
	mov	ax,word ptr cs:[bx]
	cmp	ax,word ptr [bp-4]
	je	short @14@226
	add	bx,2
	loop	short @14@142
	jmp	short @14@674
@14@226:
	jmp	word ptr cs:[bx+14]
@14@254:
   ;	
   ;	 {
   ;	 case 27: // esc
   ;	  return 0;
   ;	
	xor	ax,ax
	jmp	short @14@702
@14@282:
   ;	
   ;	
   ;	 case '+': 
   ;	 case '=': 
   ;	  if (fps < 300)
   ;	
	cmp	word ptr DGROUP:fps,300
	jge	short @14@674
   ;	
   ;	   fps += 30;
   ;	
	add	word ptr DGROUP:fps,30
	jmp	short @14@674
@14@338:
   ;	
   ;	  break;
   ;	 case '-':
   ;	 case '_':
   ;	  if (fps > 30)
   ;	
	cmp	word ptr DGROUP:fps,30
	jle	short @14@674
   ;	
   ;	   fps -= 30;
   ;	
	sub	word ptr DGROUP:fps,30
	jmp	short @14@674
@14@394:
   ;	
   ;	  break;
   ;	 case '[':
   ;	  if (view_w > 80)
   ;	
	cmp	word ptr DGROUP:view_w,80
	jle	short @14@450
   ;	
   ;	   view_w -= 40;
   ;	
	sub	word ptr DGROUP:view_w,40
@14@450:
   ;	
   ;	  if (view_h > 50)
   ;	
	cmp	word ptr DGROUP:view_h,50
	jle	short @14@646
   ;	
   ;	   view_h -= 25;
   ;	
	sub	word ptr DGROUP:view_h,25
	jmp	short @14@646
	jmp	short @14@646
@14@534:
   ;	
   ;	  color_view();
   ;	  break;
   ;	 case ']':
   ;	  if (view_w < SCREEN_W)
   ;	
	cmp	word ptr DGROUP:view_w,320
	jge	short @14@590
   ;	
   ;	   view_w += 40;
   ;	
	add	word ptr DGROUP:view_w,40
@14@590:
   ;	
   ;	  if (view_h < SCREEN_H)
   ;	
	cmp	word ptr DGROUP:view_h,200
	jge	short @14@646
   ;	
   ;	   view_h += 25;
   ;	
	add	word ptr DGROUP:view_h,25
@14@646:
   ;	
   ;	  color_view();
   ;	
	push	cs
	call	near ptr color_view
   ;	
   ;	  break;
   ;	
@14@674:
	mov	ax,1
@14@702:
   ;	
   ;	 default:
   ;	  break;
   ;	 }
   ;	 return 1;
   ;	}
   ;	
	leave	
	ret	
_handle_input	endp
@14@C114	label	word
	db	27
	db	0
	db	43
	db	0
	db	45
	db	0
	db	61
	db	0
	db	91
	db	0
	db	93
	db	0
	db	95
	db	0
	dw	@14@254
	dw	@14@282
	dw	@14@338
	dw	@14@282
	dw	@14@394
	dw	@14@534
	dw	@14@338
	?debug	C E9AE95305D13633A5C42435C494E434C5544455C646F732E68
	?debug	C E9AE95305D14633A5C42435C494E434C5544455C74696D652E68
   ;	
   ;	 main(void)
   ;	
	assume	cs:MAIN_TEXT
_main	proc	far
	enter	62,0
   ;	
   ;	{
   ;	 Body body;
   ;	 body_init(
   ;	
   ;	
   ;	     &body,
   ;	     160.0f, 100.0f, /* позиция */
   ;	     2.0f, -3.0f,    /* начальная скорость */
   ;	     0.1f,           /* гравитация */
   ;	     0.5f,           /* импульс при отскоке */
   ;	     20.0f,          /* сторона треугольника */
   ;	     0.1f,           /* скорость поворота */
   ;	     15              /* цвет */
   ;	 );
   ;	
	push	15
	fld	dword ptr DGROUP:s@+24
	sub	sp,4
	fstp	dword ptr [bp-68]
	fld	dword ptr DGROUP:s@+28
	sub	sp,4
	fstp	dword ptr [bp-72]
	fld	dword ptr DGROUP:s@+12
	sub	sp,4
	fstp	dword ptr [bp-76]
	fld	dword ptr DGROUP:s@+24
	sub	sp,4
	fstp	dword ptr [bp-80]
	fld	dword ptr DGROUP:s@+32
	sub	sp,4
	fstp	dword ptr [bp-84]
	fld	dword ptr DGROUP:s@+36
	sub	sp,4
	fstp	dword ptr [bp-88]
	fld	dword ptr DGROUP:s@+40
	sub	sp,4
	fstp	dword ptr [bp-92]
	fld	dword ptr DGROUP:s@+44
	sub	sp,4
	fstp	dword ptr [bp-96]
	push	ss
	fwait	
	lea	ax,word ptr [bp-62]
	push	ax
	push	cs
	call	near ptr _body_init
	add	sp,38
   ;	
   ;	 gfx_init();
   ;	
	push	cs
	call	near ptr _gfx_init
	jmp	short @15@86
@15@58:
   ;	
   ;	 while (handle_input())
   ;	 {
   ;	  update(&body); /* ОЗ.Р1: новое положение */
   ;	
	push	ss
	lea	ax,word ptr [bp-62]
	push	ax
	push	cs
	call	near ptr _update
	add	sp,4
   ;	
   ;	  wait_frame();
   ;	
	push	cs
	call	near ptr _wait_frame
@15@86:
	push	cs
	call	near ptr _handle_input
	or	ax,ax
	jne	short @15@58
   ;	
   ;	 }
   ;	 gfx_shutdown();
   ;	
	push	cs
	call	near ptr _gfx_shutdown
   ;	
   ;	 return 0;
   ;	
	xor	ax,ax
   ;	
   ;	}
   ;	
	leave	
	ret	
_main	endp
MAIN_TEXT	ends
_BSS	segment word public 'BSS'
last_tick	label	word
	db	4 dup (?)
	?debug	C E9
	?debug	C FA50010000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	-110
	db	10
	db	6
	db	'@'
	db	-37
	db	15
	db	-55
	db	'?'
	db	0
	db	0
	db	'@@'
	db	0
	db	0
	db	0
	db	'?3333332@'
	db	-51
	db	-52
	db	-52
	db	'='
	db	0
	db	0
	db	-96
	db	'A'
	db	0
	db	0
	db	'@'
	db	-64
	db	0
	db	0
	db	0
	db	'@'
	db	0
	db	0
	db	-56
	db	'B'
	db	0
	db	0
	db	' C'
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
	extrn	__turboFloat:word
	public	_main
	public	_handle_input
	public	_update
	public	_wait_frame
	public	_gfx_shutdown
	public	_gfx_init
	public	_body_init
_update_parameters	equ	update_parameters
	extrn	F_FTOL@:far
	extrn	F_SCOPY@:far
_draw_triangle	equ	draw_triangle
_resolve_collision	equ	resolve_collision
_tri_vertex	equ	tri_vertex
_color_view	equ	color_view
	extrn	F_LXMUL@:far
_fill_rect	equ	fill_rect
_line	equ	line
_triangle_init	equ	triangle_init
	public	_vram
_fps	equ	fps
_last_tick	equ	last_tick
_prev_view_h	equ	prev_view_h
_view_h	equ	view_h
_prev_view_w	equ	prev_view_w
_view_w	equ	view_w
	extrn	_sqrt:far
	extrn	_sin:far
	extrn	_cos:far
	extrn	_int86:far
	extrn	_clock:far
	extrn	_kbhit:far
	extrn	_getch:far
_s@	equ	s@
	end
