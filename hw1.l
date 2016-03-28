%{
    #include <stdio.h>
    #include <string.h>
    int lineCount=1; 
    int charCount=0;
    char id[256];
    int id_line;
    FILE *out;
    void print(FILE *fp, int lineNum, char* type){
        fprintf(fp, "#%d %s\n", lineNum, type);
    }
%}
str \".*\"
space [ \r\t\f\v]
DIGIT [0-9]
ID [a-zA-Z_][a-zA-Z0-9_]*
%x COMMENT
%x DATATYPE
%x FLOAT
%x NAME
%x DECLARE
%x INIT
%s FUNC

%%

if|for|while|else printf("branch: %s\n", yytext);
{DIGIT}+ {printf("get digit: %s\n", yytext);}
"+"|"-"|"*"|"/" printf("An operator: %s\n", yytext );
"/*" {
    print(out, lineCount, "Comment");
    BEGIN(COMMENT);
}
"int"|"double"|"char" {
    printf("type: %s\n", yytext);
    BEGIN(DECLARE);
}
{ID} printf("get character: %s\n", yytext);
\n  {lineCount++; printf("lineCnt: %d\n",lineCount);}
[ \r\t\f\v] {}

<COMMENT>{
     "*/"      {BEGIN(INITIAL);}
     [^*\n]+   // eat comment in chunks
     "*"       // eat the lone star
     \n        lineCount++;
}
<DATATYPE>{
    
}
<DECLARE>{
    {space}   printf("white space\n");     
    {ID} {
        strcpy(id, yytext);
        id_line = lineCount;
        printf("ID: %s\n", id);
    }
    "="{space} {
        BEGIN(INIT);
    }
    \n   lineCount++;
    ","  printf("#%d (declare)variable ID: %s\n", id_line, id);
    ;    {
        printf("#%d (declare)variable ID: %s\n", id_line, id);
        BEGIN(INITIAL);
    }
    "("{space}")" {
        printf("#%d (declare)function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
    "(" {
        printf("#%d (declare)function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
     
}
<INIT>{
    {DIGIT}+ printf("#%d value: %s\n", lineCount ,yytext);
    {str}   printf("#%d string: %s\n", lineCount ,yytext);  
    ";" BEGIN(0);
}
<FUNC>{
    ")"  {
        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(INITIAL);   
    }
}
"{"|"}"|"("|")" printf("%s\n", yytext);   
.   {printf("Unrec: %s\n",yytext);}
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

