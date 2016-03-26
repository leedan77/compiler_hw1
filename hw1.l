%{
    #include <stdio.h>
    int lineCount=0; 
    int charCount=0;
    FILE *out;
    void print(FILE *fp, int lineNum, char* type){
        fprintf(fp, "#%d %s\n", lineNum, type);
    }
%}

DIGIT [0-9]
ID [a-zA-Z_][a-zA-Z0-9_]*
%x COMMENT
%x DATATYPE
%x FLOAT
%x VAR
%%

if|for|while|else printf("branch: %s\n", yytext);
"int"|"double"|"char" {
    printf("type: %s\n", yytext);
    BEGIN(VAR);
}
{DIGIT}+ {printf("get digit: %s\n", yytext);}
{ID} printf("get character: %s\n", yytext);
"+"|"-"|"*"|"/" printf("An operator: %s\n", yytext );
"{"|"}"|"("|")" printf("%s\n", yytext);   
"/*" {
    print(out, lineCount, "Comment");
    BEGIN(COMMENT);
}
\n  {lineCount++; printf("\n");}
[ \r\t\n\f\v] {}
. printf("unrecognize: %s\n", yytext); 

<COMMENT>{
     "*/"      {BEGIN(INITIAL);}
     [^*\n]+   // eat comment in chunks
     "*"       // eat the lone star
     \n        lineCount++;
}
<DATATYPE>{
    
}
<VAR>{
    
}

%%
int main(void) { 
    out = fopen("token.txt", "w");
    yylex();
    printf("line: %d\n", lineCount);
    fclose(out);
    return 0;
}

int yywrap(){
    return 1;
}

