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
	?debug	C E91C575B5D066D61696E2E63
	?debug	C E9AE95305D15633A5C42435C494E434C5544455C737464696F2E68
	?debug	C E9AF95305D15633A5C42435C494E434C5544455C5F646566732E68
	?debug	C E9AF95305D16633A5C42435C494E434C5544455C5F6E66696C652E+
	?debug	C 68
	?debug	C E9AF95305D15633A5C42435C494E434C5544455C5F6E756C6C2E68
	?debug	C E9AE95305D16633A5C42435C494E434C5544455C7374646C69622E+
	?debug	C 68
	?debug	C E9AE95305D16633A5C42435C494E434C5544455C737472696E672E+
	?debug	C 68
	?debug	C E9AE95305D15633A5C42435C494E434C5544455C636F6E696F2E68
	?debug	C E9AE95305D13633A5C42435C494E434C5544455C646F732E68
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
_raster_buffer	label	dword
	db	0
	db	0
	db	0
	db	0
_p_bytes	label	word
	db	0
	db	0
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
   ;	
   ;	void set_video_mode(unsigned char mode)
   ;	
	assume	cs:MAIN_TEXT
_set_video_mode	proc	far
	enter	16,0
   ;	
   ;	{
   ;	 union REGS regs;
   ;	 regs.h.ah = 0x00;
   ;	
	mov	byte ptr [bp-15],0
   ;	
   ;	 regs.h.al = mode;
   ;	
	mov	al,byte ptr [bp+6]
	mov	byte ptr [bp-16],al
   ;	
   ;	 int86(0x10, &regs, &regs);
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
_set_video_mode	endp
   ;	
   ;	unsigned char decode_pixel(unsigned char *pixel_data)
   ;	
	assume	cs:MAIN_TEXT
_decode_pixel	proc	far
	enter	24,0
	push	si
   ;	
   ;	{
   ;	 unsigned short p = 0;
   ;	
   ;	
   ;	 unsigned char i1, i2, t;
   ;	 int i_bits, t_bits;
   ;	 RGB24 c1, c2;
   ;	 int r, g, b, t_scaled;
   ;	 unsigned char vga_color;
   ;	
   ;	 if (current_header.palette_size <= 2)      i_bits = 1;
   ;	
	cmp	word ptr DGROUP:_current_header+8,2
	ja	short @2@86
	mov	word ptr [bp-6],1
	jmp	short @2@170
@2@86:
   ;	
   ;	 else if (current_header.palette_size <= 4) i_bits = 2;
   ;	
	cmp	word ptr DGROUP:_current_header+8,4
	ja	short @2@142
	mov	word ptr [bp-6],2
	jmp	short @2@170
@2@142:
   ;	
   ;	 else                                       i_bits = 3;
   ;	
	mov	word ptr [bp-6],3
@2@170:
   ;	
   ;	
   ;	 t_bits = current_header.mix_bits;
   ;	
	mov	ax,word ptr DGROUP:_current_header+10
	mov	word ptr [bp-8],ax
   ;	
   ;	
   ;	 if (p_bytes == 1) {
   ;	
	cmp	word ptr DGROUP:_p_bytes,1
	jne	short @2@226
   ;	
   ;	  p = pixel_data[0];
   ;	
	les	bx,dword ptr [bp+6]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	jmp	short @2@254
@2@226:
   ;	
   ;	 } else {
   ;	  p = pixel_data[0] | (pixel_data[1] << 8); // Little Endian
   ;	
	les	bx,dword ptr [bp+6]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	mov	dl,byte ptr es:[bx+1]
	mov	dh,0
	shl	dx,8
	or	ax,dx
@2@254:
	mov	bx,ax
   ;	
   ;	 }
   ;	
   ;	 t = p & ((1 << t_bits) - 1);
   ;	
	mov	al,1
	mov	cl,byte ptr [bp-8]
	shl	al,cl
	add	al,255
	mov	dl,bl
	and	dl,al
	mov	byte ptr [bp-3],dl
   ;	
   ;	 i1 = (p >> t_bits) & ((1 << i_bits) - 1);
   ;	
	mov	ax,bx
	shr	ax,cl
	mov	dl,1
	mov	cl,byte ptr [bp-6]
	shl	dl,cl
	add	dl,255
	mov	byte ptr [bp-24],dl
	and	al,dl
	mov	byte ptr [bp-1],al
   ;	
   ;	 i2 = (p >> (t_bits + i_bits)) & ((1 << i_bits) - 1);
   ;	
	mov	cl,byte ptr [bp-8]
	add	cl,byte ptr [bp-6]
	mov	ax,bx
	shr	ax,cl
	and	al,byte ptr [bp-24]
	mov	byte ptr [bp-2],al
   ;	
   ;	
   ;	 c1 = current_palette[i1];
   ;	
	lea	ax,word ptr [bp-12]
	push	ss
	push	ax
	mov	al,byte ptr [bp-1]
	mov	ah,0
	imul	ax,ax,3
	add	ax,offset DGROUP:_current_palette
	push	ds
	push	ax
	mov	cx,3
	call	far ptr F_SCOPY@
   ;	
   ;	 c2 = current_palette[i2];
   ;	
	lea	ax,word ptr [bp-16]
	push	ss
	push	ax
	mov	al,byte ptr [bp-2]
	mov	ah,0
	imul	ax,ax,3
	add	ax,offset DGROUP:_current_palette
	push	ds
	push	ax
	mov	cx,3
	call	far ptr F_SCOPY@
   ;	
   ;	
   ;	 t_scaled = (t * 255) / ((1 << t_bits) - 1);
   ;	
	mov	al,byte ptr [bp-3]
	mov	ah,0
	imul	ax,ax,255
	mov	dx,1
	mov	cl,byte ptr [bp-8]
	shl	dx,cl
	dec	dx
	push	dx
	cwd	
	pop	bx
	idiv	bx
	mov	cx,ax
   ;	
   ;	
   ;	 r = (c1.r * (255 - t_scaled) + c2.r * t_scaled) / 255;
   ;	
	mov	al,byte ptr [bp-12]
	mov	ah,0
	mov	dx,255
	sub	dx,cx
	mov	si,dx
	imul	dx
	mov	dl,byte ptr [bp-16]
	mov	dh,0
	push	ax
	mov	ax,dx
	imul	cx
	mov	dx,ax
	pop	ax
	add	ax,dx
	mov	bx,255
	cwd	
	idiv	bx
	mov	word ptr [bp-18],ax
   ;	
   ;	 g = (c1.g * (255 - t_scaled) + c2.g * t_scaled) / 255;
   ;	
	mov	al,byte ptr [bp-11]
	mov	ah,0
	imul	si
	mov	dl,byte ptr [bp-15]
	mov	dh,0
	push	ax
	mov	ax,dx
	imul	cx
	mov	dx,ax
	pop	ax
	add	ax,dx
	cwd	
	idiv	bx
	mov	word ptr [bp-20],ax
   ;	
   ;	 b = (c1.b * (255 - t_scaled) + c2.b * t_scaled) / 255;
   ;	
	mov	al,byte ptr [bp-10]
	mov	ah,0
	imul	si
	mov	dl,byte ptr [bp-14]
	mov	dh,0
	push	ax
	mov	ax,dx
	imul	cx
	mov	dx,ax
	pop	ax
	add	ax,dx
	cwd	
	idiv	bx
	mov	word ptr [bp-22],ax
   ;	
   ;	
   ;	 vga_color = (r & 0xE0) | ((g & 0xE0) >> 3) | ((b & 0xC0) >> 6);
   ;	
	mov	ax,word ptr [bp-20]
	and	ax,224
	sar	ax,3
	mov	dl,byte ptr [bp-18]
	and	dl,224
	or	dl,al
	mov	ax,word ptr [bp-22]
	and	ax,192
	sar	ax,6
	or	dl,al
	mov	byte ptr [bp-23],dl
   ;	
   ;	
   ;	 return vga_color;
   ;	
	mov	al,byte ptr [bp-23]
   ;	
   ;	}
   ;	
	pop	si
	leave	
	ret	
_decode_pixel	endp
   ;	
   ;	void create_image( void )
   ;	
	assume	cs:MAIN_TEXT
_create_image	proc	far
	enter	290,0
	push	si
	push	di
   ;	
   ;	{
   ;	 // ... (код создания оставляем без изменений, он работает) ...
   ;	 char filename[100];
   ;	 int w, h, palette_size, t_bits;
   ;	 RGB24 pal[8];
   ;	 int i, b;
   ;	 FILE *f;
   ;	 QBT1_FileHeader fh;
   ;	 int i_bits, pixel_bits;
   ;	 char input[100];
   ;	 int r, g, bl;
   ;	
   ;	 printf("\n--- Create New QBT1 File ---\n");
   ;	
	push	ds
	push	offset DGROUP:s@
@3@58:
	call	far ptr _printf
	add	sp,4
   ;	
   ;	
   ;	 while (1) {
   ;	  printf("Enter filename (or 'cancel'): ");
   ;	
	push	ds
	push	offset DGROUP:s@+31
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	  if (strcmp(input, "cancel") == 0) return;
   ;	
	push	ds
	push	offset DGROUP:s@+62
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _strcmp
	add	sp,8
	or	ax,ax
	jne	@@0
	jmp	@3@2158
@@0:
   ;	
   ;	  if (strlen(input) == 0) { printf("Error: Empty name.\n"); continue; }
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _strlen
	add	sp,4
	or	ax,ax
	jne	short @3@170
	push	ds
	push	offset DGROUP:s@+69
	jmp	short @3@58
@3@170:
   ;	
   ;	  strcpy(filename, input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	push	ss
	lea	ax,word ptr [bp-142]
	push	ax
	call	far ptr _strcpy
	add	sp,8
   ;	
   ;	  break;
   ;	
@3@198:
   ;	
   ;	 }
   ;	
   ;	 while (1) {
   ;	  printf("Enter width (1..320): ");
   ;	
	push	ds
	push	offset DGROUP:s@+89
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	  w = atoi(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _atol
	add	sp,4
	mov	word ptr [bp-2],ax
   ;	
   ;	  if (w > 0 && w <= 320) break;
   ;	
	cmp	word ptr [bp-2],0
	jle	short @3@254
	cmp	word ptr [bp-2],320
	jle	short @3@282
@3@254:
   ;	
   ;	  printf("Error: 1..320.\n");
   ;	
	push	ds
	push	offset DGROUP:s@+112
	call	far ptr _printf
	add	sp,4
	jmp	short @3@198
@3@282:
   ;	
   ;	 }
   ;	
   ;	 while (1) {
   ;	  printf("Enter height (1..200): ");
   ;	
	push	ds
	push	offset DGROUP:s@+128
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	  h = atoi(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _atol
	add	sp,4
	mov	word ptr [bp-4],ax
   ;	
   ;	  if (h > 0 && h <= 200) break;
   ;	
	cmp	word ptr [bp-4],0
	jle	short @3@338
	cmp	word ptr [bp-4],200
	jle	short @3@366
@3@338:
   ;	
   ;	  printf("Error: 1..200.\n");
   ;	
	push	ds
	push	offset DGROUP:s@+152
	call	far ptr _printf
	add	sp,4
	jmp	short @3@282
@3@366:
   ;	
   ;	 }
   ;	
   ;	 while (1) {
   ;	  printf("Enter palette size (2..8): ");
   ;	
	push	ds
	push	offset DGROUP:s@+168
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	  palette_size = atoi(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _atol
	add	sp,4
	mov	di,ax
   ;	
   ;	  if (palette_size >= 2 && palette_size <= 8) break;
   ;	
	cmp	di,2
	jl	short @3@422
	cmp	di,8
	jle	short @3@450
@3@422:
   ;	
   ;	  printf("Error: 2..8.\n");
   ;	
	push	ds
	push	offset DGROUP:s@+196
	call	far ptr _printf
	add	sp,4
	jmp	short @3@366
@3@450:
   ;	
   ;	 }
   ;	
   ;	 printf("Enter %d colors (R G B) separated by spaces:\n", palette_size);
   ;	
	push	di
	push	ds
	push	offset DGROUP:s@+210
	call	far ptr _printf
	add	sp,6
   ;	
   ;	 for (i = 0; i < palette_size; i++) {
   ;	
	xor	si,si
	cmp	si,di
	jl	@@1
	jmp	@3@814
@@1:
@3@506:
   ;	
   ;	  while (1) {
   ;	   printf("Color %d: ", i);
   ;	
	push	si
	push	ds
	push	offset DGROUP:s@+256
	call	far ptr _printf
	add	sp,6
   ;	
   ;	   gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	   if (sscanf(input, "%d %d %d", &r, &g, &bl) == 3) {
   ;	
	push	ss
	lea	ax,word ptr [bp-22]
	push	ax
	push	ss
	lea	ax,word ptr [bp-20]
	push	ax
	push	ss
	lea	ax,word ptr [bp-18]
	push	ax
	push	ds
	push	offset DGROUP:s@+267
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _sscanf
	add	sp,20
	cmp	ax,3
	jne	short @3@730
   ;	
   ;	    if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && bl >= 0 && bl <= 255) {
   ;	
	cmp	word ptr [bp-18],0
	jl	short @3@730
	cmp	word ptr [bp-18],255
	jg	short @3@730
	cmp	word ptr [bp-20],0
	jl	short @3@730
	cmp	word ptr [bp-20],255
	jg	short @3@730
	cmp	word ptr [bp-22],0
	jl	short @3@730
	cmp	word ptr [bp-22],255
	jg	short @3@730
   ;	
   ;	     pal[i].r = (unsigned char)r;
   ;	
	mov	bx,si
	imul	bx,bx,3
	mov	dx,bx
	lea	ax,word ptr [bp-166]
	add	bx,ax
	mov	al,byte ptr [bp-18]
	mov	byte ptr ss:[bx],al
   ;	
   ;	     pal[i].g = (unsigned char)g;
   ;	
	mov	bx,dx
	lea	ax,word ptr [bp-165]
	add	bx,ax
	mov	al,byte ptr [bp-20]
	mov	byte ptr ss:[bx],al
   ;	
   ;	     pal[i].b = (unsigned char)bl;
   ;	
	mov	bx,dx
	lea	ax,word ptr [bp-164]
	add	bx,ax
	mov	al,byte ptr [bp-22]
	mov	byte ptr ss:[bx],al
   ;	
   ;	     break;
   ;	
	jmp	short @3@758
@3@730:
   ;	
   ;	    }
   ;	   }
   ;	   printf("Error: Need 3 numbers (0..255).\n");
   ;	
	push	ds
	push	offset DGROUP:s@+276
	call	far ptr _printf
	add	sp,4
	jmp	@3@506
@3@758:
	inc	si
	cmp	si,di
	jge	@@2
	jmp	@3@506
@@2:
@3@814:
   ;	
   ;	  }
   ;	 }
   ;	
   ;	 printf("Enter t precision (3..5) [default 5]: ");
   ;	
	push	ds
	push	offset DGROUP:s@+309
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	 t_bits = atoi(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-290]
	push	ax
	call	far ptr _atol
	add	sp,4
	mov	word ptr [bp-6],ax
   ;	
   ;	 if (t_bits < 3 || t_bits > 5) t_bits = 5;
   ;	
	cmp	word ptr [bp-6],3
	jl	short @3@870
	cmp	word ptr [bp-6],5
	jle	short @3@898
@3@870:
	mov	word ptr [bp-6],5
@3@898:
   ;	
   ;	
   ;	 if (palette_size <= 2) i_bits = 1;
   ;	
	cmp	di,2
	jg	short @3@954
	mov	word ptr [bp-14],1
	jmp	short @3@1038
@3@954:
   ;	
   ;	 else if (palette_size <= 4) i_bits = 2;
   ;	
	cmp	di,4
	jg	short @3@1010
	mov	word ptr [bp-14],2
	jmp	short @3@1038
@3@1010:
   ;	
   ;	 else i_bits = 3;
   ;	
	mov	word ptr [bp-14],3
@3@1038:
   ;	
   ;	
   ;	 pixel_bits = i_bits + i_bits + t_bits;
   ;	
	mov	ax,word ptr [bp-14]
	add	ax,word ptr [bp-14]
	add	ax,word ptr [bp-6]
	mov	word ptr [bp-16],ax
   ;	
   ;	 p_bytes = (pixel_bits + 7) / 8;
   ;	
	add	ax,7
	mov	bx,8
	cwd	
	idiv	bx
	mov	word ptr DGROUP:_p_bytes,ax
   ;	
   ;	
   ;	 memcpy(fh.header.signature, "QBT1", 4);
   ;	
	push	4
	push	ds
	push	offset DGROUP:s@+348
	push	ss
	lea	ax,word ptr [bp-178]
	push	ax
	call	far ptr _memcpy
	add	sp,10
   ;	
   ;	 fh.header.width = (unsigned short)w;
   ;	
	mov	ax,word ptr [bp-2]
	mov	word ptr [bp-174],ax
   ;	
   ;	 fh.header.height = (unsigned short)h;
   ;	
	mov	ax,word ptr [bp-4]
	mov	word ptr [bp-172],ax
   ;	
   ;	 fh.header.palette_size = (unsigned short)palette_size;
   ;	
	mov	word ptr [bp-170],di
   ;	
   ;	 fh.header.mix_bits = (unsigned short)t_bits;
   ;	
	mov	ax,word ptr [bp-6]
	mov	word ptr [bp-168],ax
   ;	
   ;	
   ;	 fh.content.palette_offset = sizeof(QBT1_FileHeader);
   ;	
	mov	word ptr [bp-184],0
	mov	word ptr [bp-186],24
   ;	
   ;	 fh.content.pixels_offset = fh.content.palette_offset + (sizeof(RGB24) * palette_size);
   ;	
	mov	ax,di
	imul	ax,ax,3
	mov	dx,word ptr [bp-184]
	mov	bx,word ptr [bp-186]
	add	bx,ax
	adc	dx,0
	mov	word ptr [bp-180],dx
	mov	word ptr [bp-182],bx
   ;	
   ;	 fh.content.file_size = fh.content.pixels_offset + (w * h * p_bytes);
   ;	
	mov	ax,word ptr [bp-2]
	imul	word ptr [bp-4]
	imul	word ptr DGROUP:_p_bytes
	cwd	
	mov	bx,word ptr [bp-180]
	mov	cx,word ptr [bp-182]
	add	cx,ax
	adc	bx,dx
	mov	word ptr [bp-188],bx
	mov	word ptr [bp-190],cx
   ;	
   ;	
   ;	 f = fopen(filename, "wb");
   ;	
	push	ds
	push	offset DGROUP:s@+353
	push	ss
	lea	ax,word ptr [bp-142]
	push	ax
	call	far ptr _fopen
	add	sp,8
	mov	word ptr [bp-10],dx
	mov	word ptr [bp-12],ax
   ;	
   ;	 if (!f) { printf("Error: Cannot create file '%s'.\n", filename); return; }
   ;	
	or	ax,word ptr [bp-10]
	jne	short @3@1094
	push	ss
	lea	ax,word ptr [bp-142]
	push	ax
	push	ds
	push	offset DGROUP:s@+356
	call	far ptr _printf
	add	sp,8
	jmp	@3@2158
@3@1094:
   ;	
   ;	
   ;	 fwrite(&fh, sizeof(QBT1_FileHeader), 1, f);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-12]
	push	1
	push	24
	push	ss
	lea	ax,word ptr [bp-190]
	push	ax
	call	far ptr _fwrite
	add	sp,12
   ;	
   ;	 fwrite(pal, sizeof(RGB24), palette_size, f);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-12]
	push	di
	push	3
	push	ss
	lea	ax,word ptr [bp-166]
	push	ax
	call	far ptr _fwrite
	add	sp,12
   ;	
   ;	
   ;	 for (i = 0; i < w * h; i++) {
   ;	
	xor	si,si
	jmp	@3@2102
@3@1122:
   ;	
   ;	  unsigned short p = 0;
   ;	
   ;	
   ;	  unsigned char idx1 = 0;
   ;	
   ;	
   ;	  unsigned char idx2 = 1;
   ;	
   ;	
   ;	  unsigned char t_val = 0;
   ;	
   ;	
   ;	  int x = i % w;
   ;	
	mov	ax,si
	cwd	
	idiv	word ptr [bp-2]
	mov	word ptr [bp-34],dx
   ;	
   ;	  int y = i / w;
   ;	
	mov	ax,si
	cwd	
	idiv	word ptr [bp-2]
	mov	bx,ax
   ;	
   ;	  int max_t = (1 << t_bits) - 1;
   ;	
	mov	ax,1
	mov	cl,byte ptr [bp-6]
	shl	ax,cl
	dec	ax
	mov	word ptr [bp-36],ax
   ;	
   ;	
   ;	  switch (t_bits) {
   ;	
	mov	ax,word ptr [bp-6]
	cmp	ax,3
	je	short @3@1290
	cmp	ax,4
	je	short @3@1486
	cmp	ax,5
	jne	@@3
	jmp	@3@1682
@@3:
	jmp	@3@1906
@3@1290:
   ;	
   ;	  case 3: {
   ;	   int band = x / 4;
   ;	
	mov	ax,word ptr [bp-34]
	mov	bx,4
	cwd	
	idiv	bx
	mov	word ptr [bp-38],ax
   ;	
   ;	   idx1 = (band % 2 == 0) ? 0 : 1;
   ;	
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-24],dx
	or	dx,dx
	jne	short @3@1346
	mov	al,0
	jmp	short @3@1374
@3@1346:
	mov	al,1
@3@1374:
	mov	byte ptr [bp-31],al
   ;	
   ;	   idx2 = (band % 2 == 0) ? 1 : 0;
   ;	
	cmp	word ptr [bp-24],0
	jne	short @3@1430
	mov	al,1
	jmp	short @3@1458
@3@1430:
	mov	al,0
@3@1458:
	mov	cl,al
   ;	
   ;	   t_val = (x % 4) * max_t / 3;
   ;	
	mov	ax,word ptr [bp-34]
	mov	bx,4
	cwd	
	idiv	bx
	mov	ax,dx
	imul	word ptr [bp-36]
	mov	bx,3
	cwd	
	idiv	bx
	mov	bl,al
   ;	
   ;	   break;
   ;	
	jmp	@3@1934
@3@1486:
   ;	
   ;	  }
   ;	  case 4: {
   ;	   int diag = (x + y) / 2;
   ;	
	mov	ax,word ptr [bp-34]
	add	ax,bx
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	word ptr [bp-38],ax
   ;	
   ;	   idx1 = (diag % 2 == 0) ? 0 : 1;
   ;	
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-26],dx
	or	dx,dx
	jne	short @3@1542
	mov	al,0
	jmp	short @3@1570
@3@1542:
	mov	al,1
@3@1570:
	mov	byte ptr [bp-31],al
   ;	
   ;	   idx2 = (diag % 2 == 0) ? 1 : 0;
   ;	
	cmp	word ptr [bp-26],0
	jne	short @3@1626
	mov	al,1
	jmp	short @3@1654
@3@1626:
	mov	al,0
@3@1654:
	mov	cl,al
   ;	
   ;	   t_val = (diag * 3) % max_t;
   ;	
	mov	ax,word ptr [bp-38]
	imul	ax,ax,3
	jmp	short @3@1878
@3@1682:
   ;	
   ;	   break;
   ;	  }
   ;	  case 5: {
   ;	   int cx = w / 2;
   ;	
	mov	ax,word ptr [bp-2]
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	word ptr [bp-38],ax
   ;	
   ;	   int cy = h / 2;
   ;	
	mov	ax,word ptr [bp-4]
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	word ptr [bp-40],ax
   ;	
   ;	   int dx = x - cx;
   ;	
	mov	dx,word ptr [bp-34]
	sub	dx,word ptr [bp-38]
   ;	
   ;	   int dy = y - cy;
   ;	
	sub	bx,word ptr [bp-40]
   ;	
   ;	   int dist = (dx * dx + dy * dy) / 10;
   ;	
	mov	ax,dx
	imul	dx
	push	ax
	mov	ax,bx
	imul	bx
	mov	dx,ax
	pop	ax
	add	ax,dx
	mov	bx,10
	cwd	
	idiv	bx
	mov	word ptr [bp-42],ax
   ;	
   ;	   idx1 = (dist % 2 == 0) ? 0 : 1;
   ;	
	mov	bx,2
	cwd	
	idiv	bx
	mov	word ptr [bp-28],dx
	or	dx,dx
	jne	short @3@1738
	mov	al,0
	jmp	short @3@1766
@3@1738:
	mov	al,1
@3@1766:
	mov	byte ptr [bp-31],al
   ;	
   ;	   idx2 = (dist % 2 == 0) ? 1 : 0;
   ;	
	cmp	word ptr [bp-28],0
	jne	short @3@1822
	mov	al,1
	jmp	short @3@1850
@3@1822:
	mov	al,0
@3@1850:
	mov	cl,al
   ;	
   ;	   t_val = dist % max_t;
   ;	
	mov	ax,word ptr [bp-42]
@3@1878:
	cwd	
	idiv	word ptr [bp-36]
	mov	bl,dl
   ;	
   ;	   break;
   ;	
	jmp	short @3@1934
@3@1906:
   ;	
   ;	  }
   ;	  default: {
   ;	   idx1 = 0; idx2 = 1; t_val = 0;
   ;	
	mov	byte ptr [bp-31],0
	mov	cl,1
	mov	bl,0
   ;	
   ;	   break;
   ;	
@3@1934:
   ;	
   ;	  }
   ;	  }
   ;	
   ;	  p = (idx2 << (t_bits + i_bits)) | (idx1 << t_bits) | t_val;
   ;	
	mov	al,cl
	mov	ah,0
	mov	cl,byte ptr [bp-6]
	add	cl,byte ptr [bp-14]
	shl	ax,cl
	mov	dl,byte ptr [bp-31]
	mov	dh,0
	mov	cl,byte ptr [bp-6]
	shl	dx,cl
	or	ax,dx
	mov	dl,bl
	mov	dh,0
	or	ax,dx
	mov	word ptr [bp-30],ax
   ;	
   ;	
   ;	  for (b = 0; b < p_bytes; b++) {
   ;	
	mov	word ptr [bp-8],0
	mov	ax,word ptr [bp-8]
	cmp	ax,word ptr DGROUP:_p_bytes
	jge	short @3@2074
@3@1990:
   ;	
   ;	   fputc((p >> (8 * b)) & 0xFF, f);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-12]
	mov	al,byte ptr [bp-8]
	shl	al,3
	mov	dx,word ptr [bp-30]
	mov	cl,al
	shr	dx,cl
	and	dx,255
	push	dx
	call	far ptr _fputc
	add	sp,6
	inc	word ptr [bp-8]
	mov	ax,word ptr [bp-8]
	cmp	ax,word ptr DGROUP:_p_bytes
	jl	short @3@1990
@3@2074:
	inc	si
@3@2102:
	mov	ax,word ptr [bp-2]
	imul	word ptr [bp-4]
	cmp	ax,si
	jle	@@4
	jmp	@3@1122
@@4:
   ;	
   ;	  }
   ;	 }
   ;	
   ;	 fclose(f);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-12]
	call	far ptr _fclose
	add	sp,4
   ;	
   ;	
   ;	 printf("\nSuccess! File '%s' created.\n", filename);
   ;	
	push	ss
	lea	ax,word ptr [bp-142]
	push	ax
	push	ds
	push	offset DGROUP:s@+389
	call	far ptr _printf
	add	sp,8
   ;	
   ;	 printf("Size: %dx%d, Colors: %d, Pixel size: %d bits (%d bytes)\n",
   ;	
   ;	
   ;	        w, h, palette_size, pixel_bits, p_bytes);
   ;	
	push	word ptr DGROUP:_p_bytes
	push	word ptr [bp-16]
	push	di
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	push	ds
	push	offset DGROUP:s@+419
	call	far ptr _printf
	add	sp,14
@3@2158:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_create_image	endp
   ;	
   ;	void view_image(void)
   ;	
	assume	cs:MAIN_TEXT
_view_image	proc	far
	enter	24,0
	push	si
	push	di
   ;	
   ;	{
   ;	 int offset_x = 0;
   ;	
	xor	di,di
   ;	
   ;	 int offset_y = 0;
   ;	
	mov	word ptr [bp-2],0
   ;	
   ;	 int zoom = 1;
   ;	
	mov	si,1
   ;	
   ;	 int running = 1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;	 int y, x, dy, dx, key;
   ;	 int shift_step = 20;
   ;	
	mov	word ptr [bp-12],20
   ;	
   ;	
   ;	 set_video_mode(0x13);
   ;	
	push	19
	push	cs
	call	near ptr _set_video_mode
	pop	cx
	jmp	@4@1542
@4@58:
   ;	
   ;	
   ;	 while (running)
   ;	 {
   ;	  int start_x, end_x, start_y, end_y;
   ;	  CLEAR_SCREEN_VGA(7); // Серый фон
   ;	
	push	-1536
	push	7
	push	word ptr DGROUP:_vga+2
	push	word ptr DGROUP:_vga
	call	far ptr __fmemset
	add	sp,8
   ;	
   ;	
   ;	  start_x = (offset_x < 0) ? (-offset_x / zoom) : 0;
   ;	
	or	di,di
	jge	short @4@114
	mov	ax,di
	neg	ax
	cwd	
	idiv	si
	jmp	short @4@142
@4@114:
	xor	ax,ax
@4@142:
	mov	word ptr [bp-16],ax
   ;	
   ;	  start_y = (offset_y < 0) ? (-offset_y / zoom) : 0;
   ;	
	cmp	word ptr [bp-2],0
	jge	short @4@198
	mov	ax,word ptr [bp-2]
	neg	ax
	cwd	
	idiv	si
	jmp	short @4@226
@4@198:
	xor	ax,ax
@4@226:
	mov	bx,ax
   ;	
   ;	  end_x = (VIEW_W - offset_x) / zoom + 1;
   ;	
	mov	ax,320
	sub	ax,di
	cwd	
	idiv	si
	inc	ax
	mov	word ptr [bp-18],ax
   ;	
   ;	  end_y = (VIEW_H - offset_y) / zoom + 1;
   ;	
	mov	ax,200
	sub	ax,word ptr [bp-2]
	cwd	
	idiv	si
	inc	ax
	mov	word ptr [bp-20],ax
   ;	
   ;	  
   ;	  if (end_x > current_header.width)  end_x = current_header.width;
   ;	
	mov	ax,word ptr [bp-18]
	cmp	ax,word ptr DGROUP:_current_header+4
	jbe	short @4@282
	mov	ax,word ptr DGROUP:_current_header+4
	mov	word ptr [bp-18],ax
@4@282:
   ;	
   ;	  if (end_y > current_header.height) end_y = current_header.height;
   ;	
	mov	ax,word ptr [bp-20]
	cmp	ax,word ptr DGROUP:_current_header+6
	jbe	short @4@338
	mov	ax,word ptr DGROUP:_current_header+6
	mov	word ptr [bp-20],ax
@4@338:
   ;	
   ;	  if (start_x < 0) start_x = 0;
   ;	
	cmp	word ptr [bp-16],0
	jge	short @4@394
	mov	word ptr [bp-16],0
@4@394:
   ;	
   ;	  if (start_y < 0) start_y = 0;
   ;	
	or	bx,bx
	jge	short @4@450
	xor	bx,bx
@4@450:
   ;	
   ;	
   ;	  for (y = start_y; y < end_y; y++)
   ;	
	mov	word ptr [bp-6],bx
	mov	ax,word ptr [bp-6]
	cmp	ax,word ptr [bp-20]
	jl	@@5
	jmp	@4@1038
@@5:
@4@506:
   ;	
   ;	  {
   ;	   for (x = start_x; x < end_x; x++)
   ;	
	mov	ax,word ptr [bp-16]
	mov	word ptr [bp-8],ax
	cmp	ax,word ptr [bp-18]
	jl	@@6
	jmp	@4@982
@@6:
@4@562:
   ;	
   ;	   {
   ;	    // Берем пиксель из сырого буфера в памяти
   ;	    int idx = (y * current_header.width + x) * p_bytes;
   ;	
	mov	ax,word ptr [bp-6]
	imul	word ptr DGROUP:_current_header+4
	add	ax,word ptr [bp-8]
	imul	word ptr DGROUP:_p_bytes
	mov	word ptr [bp-22],ax
   ;	
   ;	    unsigned char color = decode_pixel(&raster_buffer[idx]);
   ;	
	mov	ax,word ptr DGROUP:_raster_buffer
	add	ax,word ptr [bp-22]
	push	word ptr DGROUP:_raster_buffer+2
	push	ax
	push	cs
	call	near ptr _decode_pixel
	add	sp,4
	mov	byte ptr [bp-23],al
   ;	
   ;	
   ;	    for (dy = 0; dy < zoom; dy++)
   ;	
	xor	cx,cx
	cmp	cx,si
	jge	short @4@926
@4@618:
   ;	
   ;	    {
   ;	     for (dx = 0; dx < zoom; dx++)
   ;	
	mov	word ptr [bp-10],0
	cmp	word ptr [bp-10],si
	jge	short @4@870
@4@674:
   ;	
   ;	     {
   ;	      PUT_PIXEL_VGA(offset_x + x * zoom + dx,
   ;	                    offset_y + y * zoom + dy, color);
   ;	
	mov	ax,word ptr [bp-8]
	imul	si
	mov	dx,di
	add	dx,ax
	add	dx,word ptr [bp-10]
	mov	word ptr [bp-14],dx
	jl	short @4@814
	cmp	word ptr [bp-14],320
	jge	short @4@814
	mov	ax,word ptr [bp-6]
	imul	si
	mov	dx,word ptr [bp-2]
	add	dx,ax
	add	dx,cx
	jl	short @4@814
	cmp	dx,200
	jge	short @4@814
	mov	bx,word ptr [bp-14]
	mov	ax,dx
	imul	ax,ax,320
	add	bx,ax
	mov	es,word ptr DGROUP:_vga+2
	add	bx,word ptr DGROUP:_vga
	mov	al,byte ptr [bp-23]
	mov	byte ptr es:[bx],al
@4@814:
	inc	word ptr [bp-10]
	cmp	word ptr [bp-10],si
	jl	short @4@674
@4@870:
	inc	cx
	cmp	cx,si
	jl	short @4@618
@4@926:
	inc	word ptr [bp-8]
	mov	ax,word ptr [bp-8]
	cmp	ax,word ptr [bp-18]
	jge	@@7
	jmp	@4@562
@@7:
@4@982:
	inc	word ptr [bp-6]
	mov	ax,word ptr [bp-6]
	cmp	ax,word ptr [bp-20]
	jge	@@8
	jmp	@4@506
@@8:
@4@1038:
   ;	
   ;	     }
   ;	    }
   ;	   }
   ;	  }
   ;	  
   ;	  key = getch();
   ;	
	call	far ptr _getch
	mov	dx,ax
   ;	
   ;	  if (key == 0)
   ;	
	or	dx,dx
	jne	short @4@1290
   ;	
   ;	  {
   ;	   key = getch();
   ;	
	call	far ptr _getch
	mov	dx,ax
   ;	
   ;	   switch (key)
   ;	
	mov	bx,dx
	sub	bx,72
	cmp	bx,8
	ja	short @4@1542
	shl	bx,1
	jmp	word ptr cs:@4@C1410[bx]
@4@1178:
   ;	
   ;	   {
   ;	   case 72: offset_y += shift_step; break;
   ;	
	mov	ax,word ptr [bp-12]
	add	word ptr [bp-2],ax
	jmp	short @4@1542
@4@1206:
   ;	
   ;	   case 80: offset_y -= shift_step; break;
   ;	
	mov	ax,word ptr [bp-12]
	sub	word ptr [bp-2],ax
	jmp	short @4@1542
@4@1234:
   ;	
   ;	   case 75: offset_x += shift_step; break;
   ;	
	add	di,word ptr [bp-12]
	jmp	short @4@1542
@4@1262:
   ;	
   ;	   case 77: offset_x -= shift_step; break;
   ;	
	sub	di,word ptr [bp-12]
	jmp	short @4@1542
@4@1290:
   ;	
   ;	   }
   ;	  }
   ;	  else
   ;	  {
   ;	   if (key == 27) running = 0;
   ;	
	cmp	dx,27
	jne	short @4@1346
	mov	word ptr [bp-4],0
	jmp	short @4@1542
@4@1346:
   ;	
   ;	   else if (key == '+' || key == '=') zoom++;
   ;	
	cmp	dx,43
	je	short @4@1402
	cmp	dx,61
	jne	short @4@1430
@4@1402:
	inc	si
	jmp	short @4@1542
@4@1430:
   ;	
   ;	   else if (key == '-' || key == '_') { if (zoom > 1) zoom--; }
   ;	
	cmp	dx,45
	je	short @4@1486
	cmp	dx,95
	jne	short @4@1542
@4@1486:
	cmp	si,1
	jle	short @4@1542
	dec	si
@4@1542:
	cmp	word ptr [bp-4],0
	je	@@9
	jmp	@4@58
@@9:
   ;	
   ;	  }
   ;	 }
   ;	 set_video_mode(0x03);
   ;	
	push	3
	push	cs
	call	near ptr _set_video_mode
	pop	cx
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
_view_image	endp
@4@C1410	label	word
	dw	@4@1178
	dw	@4@1542
	dw	@4@1542
	dw	@4@1234
	dw	@4@1542
	dw	@4@1262
	dw	@4@1542
	dw	@4@1542
	dw	@4@1206
   ;	
   ;	void cmd_open(char *filename)
   ;	
	assume	cs:MAIN_TEXT
_cmd_open	proc	far
	enter	4,0
	push	si
   ;	
   ;	{
   ;	 FILE *f;
   ;	 int i_bits;
   ;	 int raster_size;
   ;	
   ;	 f = fopen(filename, "rb");
   ;	
	push	ds
	push	offset DGROUP:s@+476
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _fopen
	add	sp,8
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
   ;	
   ;	 if (!f) { printf("Error: Cannot open %s\n", filename); return; }
   ;	
	or	ax,word ptr [bp-2]
	jne	short @5@86
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	ds
	push	offset DGROUP:s@+479
	call	far ptr _printf
	add	sp,8
	jmp	@5@450
@5@86:
   ;	
   ;	
   ;	 if (fread(&current_file_header, sizeof(QBT1_FileHeader), 1, f) != 1) {
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	1
	push	24
	push	ds
	push	offset DGROUP:_current_file_header
	call	far ptr _fread
	add	sp,12
	cmp	ax,1
	je	short @5@142
   ;	
   ;	  printf("Error: Read error.\n"); fclose(f); return;
   ;	
	push	ds
	push	offset DGROUP:s@+502
	jmp	@5@394
@5@142:
   ;	
   ;	 }
   ;	 current_header = current_file_header.header;
   ;	
	push	ds
	push	offset DGROUP:_current_header
	push	ds
	push	offset DGROUP:_current_file_header+12
	mov	cx,12
	call	far ptr F_SCOPY@
   ;	
   ;	
   ;	 if (memcmp(current_header.signature, "QBT1", 4) != 0) {
   ;	
	push	4
	push	ds
	push	offset DGROUP:s@+522
	push	ds
	push	offset DGROUP:_current_header
	call	far ptr _memcmp
	add	sp,10
	or	ax,ax
	je	short @5@198
   ;	
   ;	  printf("Error: Invalid format.\n"); fclose(f); return;
   ;	
	push	ds
	push	offset DGROUP:s@+527
	jmp	@5@394
@5@198:
   ;	
   ;	 }
   ;	
   ;	 fseek(f, current_file_header.content.palette_offset, SEEK_SET);
   ;	
	push	0
	push	word ptr DGROUP:_current_file_header+6
	push	word ptr DGROUP:_current_file_header+4
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _fseek
	add	sp,10
   ;	
   ;	 fread(current_palette, sizeof(RGB24), current_header.palette_size, f);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	word ptr DGROUP:_current_header+8
	push	3
	push	ds
	push	offset DGROUP:_current_palette
	call	far ptr _fread
	add	sp,12
   ;	
   ;	
   ;	 if (current_header.palette_size <= 2) i_bits = 1;
   ;	
	cmp	word ptr DGROUP:_current_header+8,2
	ja	short @5@254
	mov	dx,1
	jmp	short @5@338
@5@254:
   ;	
   ;	 else if (current_header.palette_size <= 4) i_bits = 2;
   ;	
	cmp	word ptr DGROUP:_current_header+8,4
	ja	short @5@310
	mov	dx,2
	jmp	short @5@338
@5@310:
   ;	
   ;	 else i_bits = 3;
   ;	
	mov	dx,3
@5@338:
   ;	
   ;	 p_bytes = (i_bits + i_bits + current_header.mix_bits + 7) / 8;
   ;	
	mov	ax,dx
	add	ax,dx
	add	ax,word ptr DGROUP:_current_header+10
	add	ax,7
	shr	ax,3
	mov	word ptr DGROUP:_p_bytes,ax
   ;	
   ;	 
   ;	 // Вычисляем размер и выделяем память ОДИН РАЗ
   ;	 raster_size = current_header.width * current_header.height * p_bytes;
   ;	
	mov	ax,word ptr DGROUP:_current_header+4
	imul	word ptr DGROUP:_current_header+6
	imul	word ptr DGROUP:_p_bytes
	mov	si,ax
   ;	
   ;	 raster_buffer = (unsigned char *)malloc(raster_size);
   ;	
	push	ax
	call	far ptr _malloc
	pop	cx
	mov	word ptr DGROUP:_raster_buffer+2,dx
	mov	word ptr DGROUP:_raster_buffer,ax
   ;	
   ;	
   ;	 if (!raster_buffer) {
   ;	
	or	ax,word ptr DGROUP:_raster_buffer+2
	jne	short @5@422
   ;	
   ;	  printf("Error: Out of memory.\n");
   ;	
	push	ds
	push	offset DGROUP:s@+551
@5@394:
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  fclose(f);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _fclose
	add	sp,4
   ;	
   ;	  return;
   ;	
	jmp	short @5@450
@5@422:
   ;	
   ;	 }
   ;	
   ;	 // Читаем пиксели в память
   ;	 fseek(f, current_file_header.content.pixels_offset, SEEK_SET);
   ;	
	push	0
	push	word ptr DGROUP:_current_file_header+10
	push	word ptr DGROUP:_current_file_header+8
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _fseek
	add	sp,10
   ;	
   ;	 fread(raster_buffer, 1, raster_size, f);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	si
	push	1
	push	word ptr DGROUP:_raster_buffer+2
	push	word ptr DGROUP:_raster_buffer
	call	far ptr _fread
	add	sp,12
   ;	
   ;	 fclose(f);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _fclose
	add	sp,4
   ;	
   ;	
   ;	 // Запускаем отрисовку
   ;	 view_image();
   ;	
	push	cs
	call	near ptr _view_image
   ;	
   ;	
   ;	 // Освобождаем память после выхода
   ;	 free(raster_buffer);
   ;	
	push	word ptr DGROUP:_raster_buffer+2
	push	word ptr DGROUP:_raster_buffer
	call	far ptr _free
	add	sp,4
   ;	
   ;	 raster_buffer = NULL;
   ;	
	mov	word ptr DGROUP:_raster_buffer+2,0
	mov	word ptr DGROUP:_raster_buffer,0
@5@450:
   ;	
   ;	}
   ;	
	pop	si
	leave	
	ret	
_cmd_open	endp
   ;	
   ;	void print_help(void)
   ;	
	assume	cs:MAIN_TEXT
_print_help	proc	far
   ;	
   ;	{
   ;	 printf("QBT1 MVP (Turbo C)\n");
   ;	
	push	ds
	push	offset DGROUP:s@+574
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 printf("Commands:\n");
   ;	
	push	ds
	push	offset DGROUP:s@+594
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 printf("  h - help\n");
   ;	
	push	ds
	push	offset DGROUP:s@+605
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 printf("  c - crerate\n");
   ;	
	push	ds
	push	offset DGROUP:s@+617
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 printf("  o - open\n");
   ;	
	push	ds
	push	offset DGROUP:s@+632
	call	far ptr _printf
	add	sp,4
   ;	
   ;	 printf("  e - exit\n\n");
   ;	
	push	ds
	push	offset DGROUP:s@+644
	call	far ptr _printf
	add	sp,4
   ;	
   ;	}
   ;	
	ret	
_print_help	endp
   ;	
   ;	int main()
   ;	
	assume	cs:MAIN_TEXT
_main	proc	far
	enter	200,0
   ;	
   ;	{
   ;	 char input[200];
   ;	 vga = (unsigned char far *)0xA0000000L;
   ;	
	mov	word ptr DGROUP:_vga+2,-24576
	mov	word ptr DGROUP:_vga,0
   ;	
   ;	 print_help();
   ;	
@7@58:
	push	cs
	call	near ptr _print_help
@7@86:
   ;	
   ;	 while (1)
   ;	 {
   ;	  printf("> ");
   ;	
	push	ds
	push	offset DGROUP:s@+657
	call	far ptr _printf
	add	sp,4
   ;	
   ;	  gets(input);
   ;	
	push	ss
	lea	ax,word ptr [bp-200]
	push	ax
	call	far ptr _gets
	add	sp,4
   ;	
   ;	  if (strcmp(input, "e") == 0) break;
   ;	
	push	ds
	push	offset DGROUP:s@+660
	push	ss
	lea	ax,word ptr [bp-200]
	push	ax
	call	far ptr _strcmp
	add	sp,8
	or	ax,ax
	je	short @7@310
   ;	
   ;	  if      (strcmp (input, "h") == 0)     print_help();
   ;	
	push	ds
	push	offset DGROUP:s@+662
	push	ss
	lea	ax,word ptr [bp-200]
	push	ax
	call	far ptr _strcmp
	add	sp,8
	or	ax,ax
	je	short @7@58
   ;	
   ;	  else if (strcmp (input, "c") == 0)     create_image();
   ;	
	push	ds
	push	offset DGROUP:s@+664
	push	ss
	lea	ax,word ptr [bp-200]
	push	ax
	call	far ptr _strcmp
	add	sp,8
	or	ax,ax
	jne	short @7@198
	push	cs
	call	near ptr _create_image
	jmp	short @7@86
@7@198:
   ;	
   ;	  else if (strncmp(input, "o ", 2) == 0) cmd_open(input + 2);
   ;	
	push	2
	push	ds
	push	offset DGROUP:s@+666
	push	ss
	lea	ax,word ptr [bp-200]
	push	ax
	call	far ptr _strncmp
	add	sp,10
	or	ax,ax
	jne	short @7@254
	push	ss
	lea	ax,word ptr [bp-198]
	push	ax
	push	cs
	call	near ptr _cmd_open
	jmp	short @7@282
@7@254:
   ;	
   ;	  else                                   printf("Unknown command.\n");
   ;	
	push	ds
	push	offset DGROUP:s@+669
	call	far ptr _printf
@7@282:
	add	sp,4
	jmp	@7@86
@7@310:
   ;	
   ;	 }
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
_current_palette	label	word
	db	24 dup (?)
_current_file_header	label	word
	db	24 dup (?)
_current_header	label	word
	db	12 dup (?)
_vga	label	dword
	db	4 dup (?)
	?debug	C E9
	?debug	C FA11010000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	10
	db	'--- Create New QBT1 File ---'
	db	10
	db	0
	db	'Enter filename (or '
	db	39
	db	'cancel'
	db	39
	db	'): '
	db	0
	db	'cancel'
	db	0
	db	'Error: Empty name.'
	db	10
	db	0
	db	'Enter width (1..320): '
	db	0
	db	'Error: 1..320.'
	db	10
	db	0
	db	'Enter height (1..200): '
	db	0
	db	'Error: 1..200.'
	db	10
	db	0
	db	'Enter palette size (2..8): '
	db	0
	db	'Error: 2..8.'
	db	10
	db	0
	db	'Enter %d colors (R G B) separated by spaces:'
	db	10
	db	0
	db	'Color %d: '
	db	0
	db	'%d %d %d'
	db	0
	db	'Error: Need 3 numbers (0..255).'
	db	10
	db	0
	db	'Enter t precision (3..5) [default 5]: '
	db	0
	db	'QBT1'
	db	0
	db	'wb'
	db	0
	db	'Error: Cannot create file '
	db	39
	db	'%s'
	db	39
	db	'.'
	db	10
	db	0
	db	10
	db	'Success! File '
	db	39
	db	'%s'
	db	39
	db	' created.'
	db	10
	db	0
	db	'Size: %dx%d, Colors: %d, Pixel size: %d bits (%d bytes)'
	db	10
	db	0
	db	'rb'
	db	0
	db	'Error: Cannot open %s'
	db	10
	db	0
	db	'Error: Read error.'
	db	10
	db	0
	db	'QBT1'
	db	0
	db	'Error: Invalid format.'
	db	10
	db	0
	db	'Error: Out of memory.'
	db	10
	db	0
	db	'QBT1 MVP (Turbo C)'
	db	10
	db	0
	db	'Commands:'
	db	10
	db	0
	db	'  h - help'
	db	10
	db	0
	db	'  c - crerate'
	db	10
	db	0
	db	'  o - open'
	db	10
	db	0
	db	'  e - exit'
	db	10
	db	10
	db	0
	db	'> '
	db	0
	db	'e'
	db	0
	db	'h'
	db	0
	db	'c'
	db	0
	db	'o '
	db	0
	db	'Unknown command.'
	db	10
	db	0
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
	public	_main
	public	_print_help
	public	_cmd_open
	public	_view_image
	public	_create_image
	extrn	F_SCOPY@:far
	public	_decode_pixel
	public	_set_video_mode
	public	_p_bytes
	public	_raster_buffer
	public	_current_palette
	public	_current_file_header
	public	_current_header
	public	_vga
	extrn	_int86:far
	extrn	_getch:far
	extrn	__fmemset:far
	extrn	_strncmp:far
	extrn	_strlen:far
	extrn	_strcpy:far
	extrn	_strcmp:far
	extrn	_memcpy:far
	extrn	_memcmp:far
	extrn	_malloc:far
	extrn	_free:far
	extrn	_atol:far
	extrn	_sscanf:far
	extrn	_printf:far
	extrn	_gets:far
	extrn	_fwrite:far
	extrn	_fseek:far
	extrn	_fread:far
	extrn	_fputc:far
	extrn	_fopen:far
	extrn	_fclose:far
_s@	equ	s@
	end
