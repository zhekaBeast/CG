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
	?debug	C E9A9AA355D066D61696E2E63
	?debug	C E9AE95305D15633A5C42435C494E434C5544455C636F6E696F2E68
	?debug	C E9AF95305D15633A5C42435C494E434C5544455C5F646566732E68
	?debug	C E9AE95305D13633A5C42435C494E434C5544455C646F732E68
	?debug	C E9AE95305D14633A5C42435C494E434C5544455C6D6174682E68
	?debug	C E9AE95305D14633A5C42435C494E434C5544455C74696D652E68
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
sin_tab	label	word
	db	0
	db	0
	db	6
	db	0
	db	13
	db	0
	db	19
	db	0
	db	25
	db	0
	db	31
	db	0
	db	38
	db	0
	db	44
	db	0
	db	50
	db	0
	db	56
	db	0
	db	62
	db	0
	db	68
	db	0
	db	74
	db	0
	db	80
	db	0
	db	86
	db	0
	db	92
	db	0
	db	98
	db	0
	db	104
	db	0
	db	109
	db	0
	db	115
	db	0
	db	121
	db	0
	db	126
	db	0
	db	132
	db	0
	db	137
	db	0
	db	142
	db	0
	db	147
	db	0
	db	152
	db	0
	db	157
	db	0
	db	162
	db	0
	db	167
	db	0
	db	171
	db	0
	db	176
	db	0
	db	181
	db	0
	db	185
	db	0
	db	189
	db	0
	db	193
	db	0
	db	197
	db	0
	db	201
	db	0
	db	205
	db	0
	db	209
	db	0
	db	212
	db	0
	db	216
	db	0
	db	219
	db	0
	db	222
	db	0
	db	225
	db	0
	db	228
	db	0
	db	231
	db	0
	db	234
	db	0
	db	236
	db	0
	db	239
	db	0
	db	241
	db	0
	db	243
	db	0
	db	245
	db	0
	db	247
	db	0
	db	248
	db	0
	db	250
	db	0
	db	251
	db	0
	db	252
	db	0
	db	253
	db	0
	db	254
	db	0
	db	254
	db	0
	db	255
	db	0
	db	255
	db	0
	db	255
	db	0
	db	0
	db	1
	db	255
	db	0
	db	255
	db	0
	db	255
	db	0
	db	254
	db	0
	db	254
	db	0
	db	253
	db	0
	db	252
	db	0
	db	251
	db	0
	db	250
	db	0
	db	248
	db	0
	db	247
	db	0
	db	245
	db	0
	db	243
	db	0
	db	241
	db	0
	db	239
	db	0
	db	236
	db	0
	db	234
	db	0
	db	231
	db	0
	db	228
	db	0
	db	225
	db	0
	db	222
	db	0
	db	219
	db	0
	db	216
	db	0
	db	212
	db	0
	db	209
	db	0
	db	205
	db	0
	db	201
	db	0
	db	197
	db	0
	db	193
	db	0
	db	189
	db	0
	db	185
	db	0
	db	181
	db	0
	db	176
	db	0
	db	171
	db	0
	db	167
	db	0
	db	162
	db	0
	db	157
	db	0
	db	152
	db	0
	db	147
	db	0
	db	142
	db	0
	db	137
	db	0
	db	132
	db	0
	db	126
	db	0
	db	121
	db	0
	db	115
	db	0
	db	109
	db	0
	db	104
	db	0
	db	98
	db	0
	db	92
	db	0
	db	86
	db	0
	db	80
	db	0
	db	74
	db	0
	db	68
	db	0
	db	62
	db	0
	db	56
	db	0
	db	50
	db	0
	db	44
	db	0
	db	38
	db	0
	db	31
	db	0
	db	25
	db	0
	db	19
	db	0
	db	13
	db	0
	db	6
	db	0
	db	0
	db	0
	db	250
	db	255
	db	243
	db	255
	db	237
	db	255
	db	231
	db	255
	db	225
	db	255
	db	218
	db	255
	db	212
	db	255
	db	206
	db	255
	db	200
	db	255
	db	194
	db	255
	db	188
	db	255
	db	182
	db	255
	db	176
	db	255
	db	170
	db	255
	db	164
	db	255
	db	158
	db	255
	db	152
	db	255
	db	147
	db	255
	db	141
	db	255
	db	135
	db	255
	db	130
	db	255
	db	124
	db	255
	db	119
	db	255
	db	114
	db	255
	db	109
	db	255
	db	104
	db	255
	db	99
	db	255
	db	94
	db	255
	db	89
	db	255
	db	85
	db	255
	db	80
	db	255
	db	75
	db	255
	db	71
	db	255
	db	67
	db	255
	db	63
	db	255
	db	59
	db	255
	db	55
	db	255
	db	51
	db	255
	db	47
	db	255
	db	44
	db	255
	db	40
	db	255
	db	37
	db	255
	db	34
	db	255
	db	31
	db	255
	db	28
	db	255
	db	25
	db	255
	db	22
	db	255
	db	20
	db	255
	db	17
	db	255
	db	15
	db	255
	db	13
	db	255
	db	11
	db	255
	db	9
	db	255
	db	8
	db	255
	db	6
	db	255
	db	5
	db	255
	db	4
	db	255
	db	3
	db	255
	db	2
	db	255
	db	2
	db	255
	db	1
	db	255
	db	1
	db	255
	db	1
	db	255
	db	0
	db	255
	db	1
	db	255
	db	1
	db	255
	db	1
	db	255
	db	2
	db	255
	db	2
	db	255
	db	3
	db	255
	db	4
	db	255
	db	5
	db	255
	db	6
	db	255
	db	8
	db	255
	db	9
	db	255
	db	11
	db	255
	db	13
	db	255
	db	15
	db	255
	db	17
	db	255
	db	20
	db	255
	db	22
	db	255
	db	25
	db	255
	db	28
	db	255
	db	31
	db	255
	db	34
	db	255
	db	37
	db	255
	db	40
	db	255
	db	44
	db	255
	db	47
	db	255
	db	51
	db	255
	db	55
	db	255
	db	59
	db	255
	db	63
	db	255
	db	67
	db	255
	db	71
	db	255
	db	75
	db	255
	db	80
	db	255
	db	85
	db	255
	db	89
	db	255
	db	94
	db	255
	db	99
	db	255
	db	104
	db	255
	db	109
	db	255
	db	114
	db	255
	db	119
	db	255
	db	124
	db	255
	db	130
	db	255
	db	135
	db	255
	db	141
	db	255
	db	147
	db	255
	db	152
	db	255
	db	158
	db	255
	db	164
	db	255
	db	170
	db	255
	db	176
	db	255
	db	182
	db	255
	db	188
	db	255
	db	194
	db	255
	db	200
	db	255
	db	206
	db	255
	db	212
	db	255
	db	218
	db	255
	db	225
	db	255
	db	231
	db	255
	db	237
	db	255
	db	243
	db	255
	db	250
	db	255
_view_w	label	word
	db	64
	db	1
_prev_view_w	label	word
	db	64
	db	1
_view_h	label	word
	db	200
	db	0
_prev_view_h	label	word
	db	64
	db	1
_fps	label	word
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
   ;	 void draw_line(int x0, int y0, int x1, int y1, unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
_draw_line	proc	far
	push	bp
	mov	bp,sp
	sub	sp,10
	push	si
	push	di
	mov	cx,word ptr [bp+6]
	mov	si,word ptr [bp+8]
   ;	
   ;	 {
   ;	  int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
   ;	
	cmp	word ptr [bp+10],cx
	jle	short @1@86
	mov	ax,word ptr [bp+10]
	sub	ax,cx
	jmp	short @1@114
@1@86:
	mov	ax,cx
	sub	ax,word ptr [bp+10]
@1@114:
	mov	word ptr [bp-2],ax
   ;	
   ;	  int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
   ;	
	cmp	word ptr [bp+12],si
	jle	short @1@170
	mov	ax,word ptr [bp+12]
	sub	ax,si
	jmp	short @1@198
@1@170:
	mov	ax,si
	sub	ax,word ptr [bp+12]
@1@198:
	mov	word ptr [bp-4],ax
   ;	
   ;	  int sx = (x0 < x1) ? 1 : -1;
   ;	
	cmp	cx,word ptr [bp+10]
	jge	short @1@254
	mov	ax,1
	jmp	short @1@282
@1@254:
	mov	ax,-1
@1@282:
	mov	word ptr [bp-6],ax
   ;	
   ;	  int sy = (y0 < y1) ? 1 : -1;
   ;	
	cmp	si,word ptr [bp+12]
	jge	short @1@338
	mov	ax,1
	jmp	short @1@366
@1@338:
	mov	ax,-1
@1@366:
	mov	word ptr [bp-8],ax
   ;	
   ;	  int err = dx - dy;
   ;	
	mov	di,word ptr [bp-2]
	sub	di,word ptr [bp-4]
	mov	ax,word ptr [bp-4]
	neg	ax
	mov	word ptr [bp-10],ax
@1@422:
   ;	
   ;	
   ;	  while (1)
   ;	  {
   ;	   if (x0 < view_w && y0 < view_h)
   ;	
	cmp	cx,word ptr DGROUP:_view_w
	jge	short @1@506
	cmp	si,word ptr DGROUP:_view_h
	jge	short @1@506
   ;	
   ;	    vram[y0 * SCREEN_W + x0] = color;
   ;	
	mov	ax,si
	mov	dx,320
	imul	dx
	add	ax,cx
	mov	es,word ptr DGROUP:_vram+2
	add	ax,word ptr DGROUP:_vram
	mov	dl,byte ptr [bp+14]
	mov	bx,ax
	mov	byte ptr es:[bx],dl
@1@506:
   ;	
   ;	   if (x0 == x1 && y0 == y1)
   ;	
	cmp	cx,word ptr [bp+10]
	jne	short @1@562
	cmp	si,word ptr [bp+12]
	je	short @1@674
@1@562:
   ;	
   ;	    break;
   ;	   {
   ;	    int e2 = 2 * err;
   ;	
	mov	dx,di
	shl	dx,1
   ;	
   ;	    if (e2 > -dy)
   ;	
	cmp	word ptr [bp-10],dx
	jge	short @1@618
   ;	
   ;	    {
   ;	     err -= dy;
   ;	
	sub	di,word ptr [bp-4]
   ;	
   ;	     x0 += sx;
   ;	
	add	cx,word ptr [bp-6]
@1@618:
   ;	
   ;	    }
   ;	    if (e2 < dx)
   ;	
	cmp	dx,word ptr [bp-2]
	jge	short @1@422
   ;	
   ;	    {
   ;	     err += dx;
   ;	
	add	di,word ptr [bp-2]
   ;	
   ;	     y0 += sy;
   ;	
	add	si,word ptr [bp-8]
	jmp	short @1@422
@1@674:
   ;	
   ;	    }
   ;	   }
   ;	  }
   ;	 }
   ;	
	pop	di
	pop	si
	leave	
	ret	
_draw_line	endp
   ;	
   ;	void fill_rect(int x0, int y0, int x1, int y1, unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
_fill_rect	proc	far
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	dx,word ptr [bp+8]
   ;	
   ;	{
   ;	 int x, y;
   ;	 if (x0 < 0)
   ;	
	cmp	word ptr [bp+6],0
	jge	short @2@86
   ;	
   ;	  x0 = 0;
   ;	
	mov	word ptr [bp+6],0
@2@86:
   ;	
   ;	 if (y0 < 0)
   ;	
	or	dx,dx
	jge	short @2@142
   ;	
   ;	  y0 = 0;
   ;	
	xor	dx,dx
@2@142:
   ;	
   ;	 if (x1 > SCREEN_W)
   ;	
	cmp	word ptr [bp+10],320
	jle	short @2@198
   ;	
   ;	  x1 = SCREEN_W;
   ;	
	mov	word ptr [bp+10],320
@2@198:
   ;	
   ;	 if (y1 > SCREEN_H)
   ;	
	cmp	word ptr [bp+12],200
	jle	short @2@254
   ;	
   ;	  y1 = SCREEN_H;
   ;	
	mov	word ptr [bp+12],200
@2@254:
   ;	
   ;	 for (y = y0; y < y1; y++)
   ;	
	mov	si,dx
	cmp	dx,word ptr [bp+12]
	jge	short @2@534
@2@310:
   ;	
   ;	 {
   ;	  unsigned char far *row = vram + (unsigned long)y * SCREEN_W;
   ;	
	mov	ax,si
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
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],bx
   ;	
   ;	  for (x = x0; x < x1; x++)
   ;	
	mov	ax,word ptr [bp+10]
	cmp	word ptr [bp+6],ax
	jge	short @2@478
	mov	cx,word ptr [bp+10]
	sub	cx,word ptr [bp+6]
	mov	di,word ptr [bp-4]
	add	di,word ptr [bp+6]
	mov	es,word ptr DGROUP:_vram+2
	mov	al,byte ptr [bp+14]
	mov	ah,al
	shr	cx,1
	rep 	stosw	
	jnc	short @2@478
	stosb	
@2@478:
	inc	si
	cmp	si,word ptr [bp+12]
	jl	short @2@310
@2@534:
   ;	
   ;	   row[x] = color;
   ;	 }
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_fill_rect	endp
   ;	
   ;	void color_view(void)
   ;	
	assume	cs:MAIN_TEXT
_color_view	proc	far
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
   ;	
   ;	{
   ;	 int w = view_w;
   ;	
	mov	ax,word ptr DGROUP:_view_w
	mov	word ptr [bp-2],ax
   ;	
   ;	 int h = view_h;
   ;	
	mov	si,word ptr DGROUP:_view_h
   ;	
   ;	 int pw = prev_view_w;
   ;	
	mov	ax,word ptr DGROUP:_prev_view_w
	mov	word ptr [bp-4],ax
   ;	
   ;	 int ph = prev_view_h;
   ;	
	mov	di,word ptr DGROUP:_prev_view_h
   ;	
   ;	
   ;	 // --- По горизонтали ---
   ;	 if (w > pw)
   ;	
	mov	ax,word ptr DGROUP:_view_w
	cmp	ax,word ptr DGROUP:_prev_view_w
	jle	short @3@86
   ;	
   ;	 {
   ;	  // окно расширилось: справа появилась новая зона — красим тёмным
   ;	  fill_rect(pw, 0, w, h, BLACK);
   ;	
	push	0
	push	word ptr DGROUP:_view_h
	push	ax
	push	0
	push	word ptr DGROUP:_prev_view_w
	push	cs
	call	near ptr _fill_rect
	add	sp,10
   ;	
   ;	 }
   ;	
	jmp	short @3@142
@3@86:
   ;	
   ;	 else if (w < pw)
   ;	
	mov	ax,word ptr [bp-2]
	cmp	ax,word ptr [bp-4]
	jge	short @3@142
   ;	
   ;	 {
   ;	  // окно сузилось: полоса справа стала "вне окна" — красим белым
   ;	  fill_rect(w, 0, pw, ph, WHITE);
   ;	
	push	15
	push	di
	push	word ptr [bp-4]
	push	0
	push	ax
	push	cs
	call	near ptr _fill_rect
	add	sp,10
@3@142:
   ;	
   ;	 }
   ;	
   ;	 // --- По вертикали ---
   ;	 if (h > ph)
   ;	
	cmp	si,di
	jle	short @3@198
   ;	
   ;	 {
   ;	  // окно выросло вниз: новая зона снизу — тёмным
   ;	  fill_rect(0, ph, w, h, BLACK);
   ;	
	push	0
	push	si
	push	word ptr [bp-2]
	push	di
	push	0
	push	cs
	call	near ptr _fill_rect
	add	sp,10
   ;	
   ;	 }
   ;	
	jmp	short @3@254
@3@198:
   ;	
   ;	 else if (h < ph)
   ;	
	cmp	si,di
	jge	short @3@254
   ;	
   ;	 {
   ;	  // окно сузилось по высоте: полоса снизу — белым
   ;	  fill_rect(0, h, pw, ph, WHITE);
   ;	
	push	15
	push	di
	push	word ptr [bp-4]
	push	si
	push	0
	push	cs
	call	near ptr _fill_rect
	add	sp,10
@3@254:
   ;	
   ;	 }
   ;	
   ;	 // Запоминаем текущие размеры как предыдущие
   ;	 prev_view_w = w;
   ;	
	mov	ax,word ptr [bp-2]
	mov	word ptr DGROUP:_prev_view_w,ax
   ;	
   ;	 prev_view_h = h;
   ;	
	mov	word ptr DGROUP:_prev_view_h,si
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_color_view	endp
   ;	
   ;	void resolve_collision(void)
   ;	
	assume	cs:MAIN_TEXT
_resolve_collision	proc	far
	push	bp
	mov	bp,sp
	sub	sp,16
	push	si
	push	di
   ;	
   ;	{
   ;	 int i;
   ;	 Point *w = body.tri.points;
   ;	
	mov	word ptr [bp-2],ds
	mov	word ptr [bp-4],offset DGROUP:_body+6
   ;	
   ;	 int minX = w[0].x, maxX = w[0].x;
   ;	
	les	bx,dword ptr [bp-4]
	mov	ax,word ptr es:[bx]
	mov	word ptr [bp-14],ax
	mov	word ptr [bp-6],ax
	mov	word ptr [bp-8],ax
   ;	
   ;	 int minY = w[0].y, maxY = w[0].y;
   ;	
	mov	ax,word ptr es:[bx+2]
	mov	word ptr [bp-16],ax
	mov	word ptr [bp-10],ax
	mov	word ptr [bp-12],ax
   ;	
   ;	 for (i = 0; i < 3; i++)
   ;	
	xor	cx,cx
	mov	di,offset DGROUP:_body+6
	mov	si,offset DGROUP:_body+6
	add	si,2
@4@86:
   ;	
   ;	 {
   ;	  if (w[i].x < minX)
   ;	
	mov	es,word ptr [bp-2]
	mov	ax,word ptr es:[di]
	mov	dx,ax
	cmp	ax,word ptr [bp-6]
	jge	short @4@142
   ;	
   ;	   minX = w[i].x;
   ;	
	mov	word ptr [bp-6],dx
@4@142:
   ;	
   ;	  if (w[i].x > maxX)
   ;	
	cmp	dx,word ptr [bp-8]
	jle	short @4@198
   ;	
   ;	   maxX = w[i].x;
   ;	
	mov	word ptr [bp-8],dx
@4@198:
   ;	
   ;	  if (w[i].y < minY)
   ;	
	mov	es,word ptr [bp-2]
	mov	ax,word ptr es:[si]
	mov	dx,ax
	cmp	ax,word ptr [bp-10]
	jge	short @4@254
   ;	
   ;	   minY = w[i].y;
   ;	
	mov	word ptr [bp-10],dx
@4@254:
   ;	
   ;	  if (w[i].y > maxY)
   ;	
	cmp	dx,word ptr [bp-12]
	jle	short @4@310
   ;	
   ;	   maxY = w[i].y;
   ;	
	mov	word ptr [bp-12],dx
@4@310:
	add	di,4
	add	si,4
	inc	cx
	cmp	cx,3
	jl	short @4@86
   ;	
   ;	 }
   ;	 if (minX < LEFT_LIMIT)
   ;	
	cmp	word ptr [bp-6],0
	jge	short @4@478
   ;	
   ;	 {
   ;	  body.pos.x += (LEFT_LIMIT - minX); // выталкиваем внутрь
   ;	
	xor	ax,ax
	sub	ax,word ptr [bp-6]
	add	word ptr DGROUP:_body+18,ax
   ;	
   ;	  body.vel.x = -body.vel.x;          // отражение
   ;	
	mov	ax,word ptr DGROUP:_body+22
	neg	ax
	mov	word ptr DGROUP:_body+22,ax
   ;	
   ;	 }
   ;	
	jmp	short @4@534
@4@478:
   ;	
   ;	 else if (maxX > RIGHT_LIMIT)
   ;	
	mov	ax,word ptr [bp-8]
	cmp	ax,word ptr DGROUP:_view_w
	jle	short @4@534
   ;	
   ;	 {
   ;	  body.pos.x -= (maxX - RIGHT_LIMIT);
   ;	
	sub	ax,word ptr DGROUP:_view_w
	sub	word ptr DGROUP:_body+18,ax
   ;	
   ;	  body.vel.x = -body.vel.x;
   ;	
	mov	ax,word ptr DGROUP:_body+22
	neg	ax
	mov	word ptr DGROUP:_body+22,ax
@4@534:
   ;	
   ;	 }
   ;	 if (minY < TOP_LIMIT)
   ;	
	cmp	word ptr [bp-10],0
	jge	short @4@590
   ;	
   ;	 {
   ;	  body.pos.y += (TOP_LIMIT - minY);
   ;	
	xor	ax,ax
	sub	ax,word ptr [bp-10]
	add	word ptr DGROUP:_body+20,ax
   ;	
   ;	  body.vel.y = 0;
   ;	
	mov	word ptr DGROUP:_body+24,0
   ;	
   ;	 }
   ;	
	pop	di
	pop	si
	leave	
	ret	
@4@590:
   ;	
   ;	 else if (maxY > BOTTOM_LIMIT)
   ;	
	mov	ax,word ptr [bp-12]
	cmp	ax,word ptr DGROUP:_view_h
	jle	short @4@646
   ;	
   ;	 {
   ;	  body.pos.y -= (maxY - BOTTOM_LIMIT);
   ;	
	sub	ax,word ptr DGROUP:_view_h
	sub	word ptr DGROUP:_body+20,ax
   ;	
   ;	  body.vel.y = -body.vel.y; // отражение
   ;	
	mov	ax,word ptr DGROUP:_body+24
	neg	ax
	mov	word ptr DGROUP:_body+24,ax
   ;	
   ;	  body.vel.y -= body.impulse;
   ;	
	mov	ax,word ptr DGROUP:_body+28
	sub	word ptr DGROUP:_body+24,ax
@4@646:
   ;	
   ;	 }
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_resolve_collision	endp
   ;	
   ;	void draw_triangle(unsigned char color)
   ;	
	assume	cs:MAIN_TEXT
_draw_triangle	proc	far
	push	bp
	mov	bp,sp
	sub	sp,12
	push	si
	push	di
   ;	
   ;	{
   ;	 int i;
   ;	 const Triangle *t = &body.tri;
   ;	
	mov	word ptr [bp-2],ds
	mov	word ptr [bp-4],offset DGROUP:_body
   ;	
   ;	 // Три стороны треугольника
   ;	 for (i = 0; i < 3; ++i)
   ;	
	xor	si,si
	mov	di,offset DGROUP:_body
	add	di,6
@5@86:
   ;	
   ;	 {
   ;	  int j = (i + 1) % 3;
   ;	
	mov	ax,si
	inc	ax
	mov	bx,3
	cwd	
	idiv	bx
	mov	cx,dx
   ;	
   ;	  Point pa = t->points[i];
   ;	
	mov	es,word ptr [bp-2]
	mov	ax,word ptr es:[di+2]
	mov	dx,word ptr es:[di]
	mov	word ptr [bp-6],ax
	mov	word ptr [bp-8],dx
   ;	
   ;	  Point pb = t->points[j];
   ;	
	mov	ax,cx
	shl	ax,2
	mov	bx,word ptr [bp-4]
	add	bx,ax
	mov	ax,word ptr es:[bx+8]
	mov	dx,word ptr es:[bx+6]
	mov	word ptr [bp-10],ax
	mov	word ptr [bp-12],dx
   ;	
   ;	  draw_line(pa.x, pa.y, pb.x, pb.y, color);
   ;	
	mov	al,byte ptr [bp+6]
	push	ax
	push	word ptr [bp-10]
	push	dx
	push	word ptr [bp-6]
	push	word ptr [bp-8]
	push	cs
	call	near ptr _draw_line
	add	sp,10
	add	di,4
	inc	si
	cmp	si,3
	jl	short @5@86
   ;	
   ;	 }
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_draw_triangle	endp
   ;	
   ;	int handle_input(void)
   ;	
	assume	cs:MAIN_TEXT
_handle_input	proc	far
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	 // 5. Обработка клавиш (ДЗ.Е3)
   ;	 int key;
   ;	 if (!kbhit()) // нет нажатия — выходим
   ;	
	call	far ptr _kbhit
	or	ax,ax
	jne	short @6@86
   ;	
   ;	  return 1;
   ;	
	mov	ax,1
	leave	
	ret	
@6@86:
   ;	
   ;	 key = getch();
   ;	
	call	far ptr _getch
	mov	word ptr [bp-2],ax
   ;	
   ;	 switch (key)
   ;	
	cmp	ax,61
	je	short @6@422
	jg	short @6@282
	cmp	ax,27
	je	short @6@394
	cmp	ax,43
	je	short @6@422
	cmp	ax,45
	je	short @6@478
	jmp	short @6@814
@6@282:
	cmp	ax,91
	je	short @6@534
	cmp	ax,93
	je	short @6@674
	cmp	ax,95
	je	short @6@478
	jmp	short @6@814
@6@394:
   ;	
   ;	 {
   ;	 case 27: // esc
   ;	  return 0;
   ;	
	xor	ax,ax
	leave	
	ret	
@6@422:
   ;	
   ;	 case '+':
   ;	 case '=':
   ;	  if (fps < 300)
   ;	
	cmp	word ptr DGROUP:_fps,300
	jge	short @6@814
   ;	
   ;	   fps += 60;
   ;	
	add	word ptr DGROUP:_fps,60
	jmp	short @6@814
@6@478:
   ;	
   ;	  break;
   ;	 case '-':
   ;	 case '_':
   ;	  if (fps > 30)
   ;	
	cmp	word ptr DGROUP:_fps,30
	jle	short @6@814
   ;	
   ;	   fps -= 30;
   ;	
	sub	word ptr DGROUP:_fps,30
	jmp	short @6@814
@6@534:
   ;	
   ;	  break;
   ;	 case '[':
   ;	  if (view_w > 80)
   ;	
	cmp	word ptr DGROUP:_view_w,80
	jle	short @6@590
   ;	
   ;	   view_w -= 40;
   ;	
	sub	word ptr DGROUP:_view_w,40
@6@590:
   ;	
   ;	  if (view_h > 50)
   ;	
	cmp	word ptr DGROUP:_view_h,50
	jle	short @6@646
   ;	
   ;	   view_h -= 25;
   ;	
	sub	word ptr DGROUP:_view_h,25
@6@646:
   ;	
   ;	  color_view();
   ;	
	push	cs
	call	near ptr _color_view
   ;	
   ;	  break;
   ;	
	jmp	short @6@814
@6@674:
   ;	
   ;	 case ']':
   ;	  if (view_w < SCREEN_W)
   ;	
	cmp	word ptr DGROUP:_view_w,320
	jge	short @6@730
   ;	
   ;	   view_w += 40;
   ;	
	add	word ptr DGROUP:_view_w,40
@6@730:
   ;	
   ;	  if (view_h < SCREEN_H)
   ;	
	cmp	word ptr DGROUP:_view_h,200
	jge	short @6@786
   ;	
   ;	   view_h += 25;
   ;	
	add	word ptr DGROUP:_view_h,25
@6@786:
   ;	
   ;	  color_view();
   ;	
	push	cs
	call	near ptr _color_view
   ;	
   ;	  break;
   ;	
@6@814:
   ;	
   ;	 default:
   ;	  break;
   ;	 }
   ;	 return 1;
   ;	
	mov	ax,1
   ;	
   ;	}
   ;	
	leave	
	ret	
_handle_input	endp
   ;	
   ;	void gfx_init(void)
   ;	
	assume	cs:MAIN_TEXT
_gfx_init	proc	far
	push	bp
	mov	bp,sp
	sub	sp,16
   ;	
   ;	{
   ;	 union REGS r;
   ;	 r.h.ah = 0x00; // set video mode
   ;	
	mov	byte ptr [bp-15],0
   ;	
   ;	 r.h.al = 0x13; // VGA 320x200x256
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
   ;	 // сегмент видеопамяти A000:0000
   ;	 vram = (unsigned char far *)MK_FP(VIDEO_SEG, 0);
   ;	
	mov	word ptr DGROUP:_vram+2,-24576
	mov	word ptr DGROUP:_vram,0
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
	push	bp
	mov	bp,sp
	sub	sp,16
   ;	
   ;	{
   ;	 union REGS r;
   ;	 r.h.ah = 0x00;
   ;	
	mov	byte ptr [bp-15],0
   ;	
   ;	 r.h.al = 0x03; // возврат в текстовый режим
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
   ;	int main(void)
   ;	
	assume	cs:MAIN_TEXT
_main	proc	far
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
   ;	
   ;	{
   ;	int i;
   ;	int r_factor;
   ;	int angle_idx;
   ;	int local_idx;
   ;	 body.pos.x = 160;
   ;	
	mov	word ptr DGROUP:_body+18,160
   ;	
   ;	 body.pos.y = 100;
   ;	
	mov	word ptr DGROUP:_body+20,100
   ;	
   ;	 body.vel.x = 2;
   ;	
	mov	word ptr DGROUP:_body+22,2
   ;	
   ;	 body.vel.y = -3;
   ;	
	mov	word ptr DGROUP:_body+24,-3
   ;	
   ;	 body.g = 1;
   ;	
	mov	word ptr DGROUP:_body+26,1
   ;	
   ;	 body.impulse = 1;
   ;	
	mov	word ptr DGROUP:_body+28,1
   ;	
   ;	 body.tri.dangle = 10;
   ;	
	mov	word ptr DGROUP:_body+2,10
   ;	
   ;	 body.tri.side = 20;
   ;	
	mov	word ptr DGROUP:_body+4,20
   ;	
   ;	
   ;	 gfx_init();
   ;	
	push	cs
	call	near ptr _gfx_init
	jmp	@9@282
@9@58:
   ;	
   ;	 while (handle_input())
   ;	 {
   ;	  draw_triangle(BLACK);
   ;	
	push	0
	push	cs
	call	near ptr _draw_triangle
	add	sp,2
   ;	
   ;	  // сила тяжести
   ;	  body.vel.y += body.g;
   ;	
	mov	ax,word ptr DGROUP:_body+26
	add	word ptr DGROUP:_body+24,ax
   ;	
   ;	  // Сдвиг центра
   ;	  body.pos.x += body.vel.x;
   ;	
	mov	ax,word ptr DGROUP:_body+22
	add	word ptr DGROUP:_body+18,ax
   ;	
   ;	  body.pos.y += body.vel.y;
   ;	
	mov	ax,word ptr DGROUP:_body+24
	add	word ptr DGROUP:_body+20,ax
   ;	
   ;	  // Вращение
   ;	  body.tri.angle += body.tri.dangle;
   ;	
	mov	ax,word ptr DGROUP:_body+2
	add	word ptr DGROUP:_body,ax
   ;	
   ;	  // Вычисление новых точек
   ;	  r_factor = (body.tri.side * 148) >> 8;
   ;	
	mov	ax,word ptr DGROUP:_body+4
	mov	dx,148
	imul	dx
	sar	ax,8
	mov	word ptr [bp-4],ax
   ;	
   ;	  angle_idx = body.tri.angle & 255;
   ;	
	mov	dx,word ptr DGROUP:_body
	and	dx,255
   ;	
   ;	  for (i = 0; i < 3; i++)
   ;	
	mov	word ptr [bp-2],0
	mov	cx,dx
	add	cx,64
	xor	si,si
@9@114:
   ;	
   ;	  {
   ;	   local_idx = (angle_idx + 64 + i * 85) & 255; // 85 ≈ 256/3
   ;	
	mov	di,cx
	and	di,255
   ;	
   ;	   body.tri.points[i].x = body.pos.x + ((r_factor * sin_tab[(local_idx + 64) & 255]) >> 8);
   ;	
	mov	bx,di
	add	bx,64
	and	bx,255
	shl	bx,1
	mov	ax,word ptr [bp-4]
	imul	word ptr DGROUP:sin_tab[bx]
	sar	ax,8
	mov	dx,word ptr DGROUP:_body+18
	add	dx,ax
	mov	word ptr DGROUP:_body[si+6],dx
   ;	
   ;	   body.tri.points[i].y = body.pos.y + ((r_factor * sin_tab[local_idx]) >> 8);
   ;	
	mov	bx,di
	shl	bx,1
	mov	ax,word ptr [bp-4]
	imul	word ptr DGROUP:sin_tab[bx]
	sar	ax,8
	mov	dx,word ptr DGROUP:_body+20
	add	dx,ax
	mov	word ptr DGROUP:_body[si+8],dx
	add	cx,85
	add	si,4
	inc	word ptr [bp-2]
	cmp	si,12
	jne	short @9@114
   ;	
   ;	  }
   ;	  // Меняем по колизиям векторы
   ;	  resolve_collision();
   ;	
	push	cs
	call	near ptr _resolve_collision
   ;	
   ;	  draw_triangle(WHITE);
   ;	
	push	15
	push	cs
	call	near ptr _draw_triangle
	add	sp,2
   ;	
   ;	
   ;	  delay(1000 / fps);
   ;	
	mov	ax,1000
	cwd	
	idiv	word ptr DGROUP:_fps
	push	ax
	call	far ptr _delay
	add	sp,2
@9@282:
	push	cs
	call	near ptr _handle_input
	or	ax,ax
	je	@@0
	jmp	@9@58
@@0:
   ;	
   ;	 }
   ;	 gfx_shutdown();
   ;	
	push	cs
	call	near ptr _gfx_shutdown
   ;	
   ;	
   ;	 return 0;
   ;	
	xor	ax,ax
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_main	endp
MAIN_TEXT	ends
_BSS	segment word public 'BSS'
_body	label	word
	db	30 dup (?)
	?debug	C E9
	?debug	C FA5D030000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
	public	_main
	public	_gfx_shutdown
	public	_gfx_init
	public	_handle_input
	public	_draw_triangle
	public	_resolve_collision
	public	_color_view
	extrn	F_LXMUL@:far
	public	_fill_rect
	public	_draw_line
	public	_body
	public	_vram
	public	_fps
	public	_prev_view_h
	public	_view_h
	public	_prev_view_w
	public	_view_w
_sin_tab	equ	sin_tab
	extrn	_int86:far
	extrn	_delay:far
	extrn	_kbhit:far
	extrn	_getch:far
_s@	equ	s@
	end
