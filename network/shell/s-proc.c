#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

int main(int argc, char **argv){
  FILE *f;
  unsigned char *code, *pcode;
  int i, l, flen;
  void (*fptr)(void);
  code=malloc(4096);
  if(argc!=2) { 
    printf("Печать и исполнение shell-кода : %s <файл>\n",
		 argv[0]); exit(1); 
  }
  if((f = fopen(argv[1],"rb"))==0) {
    printf("Ошибка при открытии файла");exit(1);
  }
  pcode=code;
  while(1) { 
    i=fread(pcode,1,1,f); 
    if(i==1) pcode++; 
    else break; 
  } 
  flen=pcode-code;
  fclose(f);
  printf("\nДлина shell-кода %d байтов: \n", flen);
  printf("\n shellcode[] = \n");
  l=10;				// 10 - число байт в строке
  for(i=0; i<flen; ++i){
    if(l>=10){
      if(i) printf("\"\n"); 
      printf("\t\""); l=0;
    }
    ++l;
    printf("\\x%02x", ((unsigned char *)code)[i]);
  }
  printf("\";\n\n");
  printf("Вызывается код...");
  void *prt=(void *)((long int)code&0xfffff000);
  mprotect(prt, 1024, 7);
  fptr=(void(*) (void)) code;
  (*fptr)();
}
