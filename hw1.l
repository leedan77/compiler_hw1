%{
    #include <stdio.h>
    int lineCount=0; 
%}

%%
\n { lineCount++; 
    printf("line:%d\n", lineCount); 
    printf("%d\n", yyleng);
}

%%
int main(void) { 
    yylex(); 
    return 0;
}

int yywrap(){
    return 1;
}
