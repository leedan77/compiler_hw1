#include <stdio.h>

int 
main
(
 )
{
    /* int Testing.... */
    int x = 5;
    int a_b;
    char c = "gan";
    char* a = "LKLK";
    char* b = a;
    printf("a: %s b: %s c:%d\n",a,b,*c);
    a = "QAQ";
    *a_b = 10;
    printf("a: %s b: %s c:%d\n",a,b,*c);
    return 0;
}
