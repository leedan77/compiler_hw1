%{
    #include <stdio.h>
    #include <string.h>
    int lineCount=1; 
    int charCount=0;
    char id[256];
    int id_line;
    int declare_flag = 0;
    FILE *out;
    void print(FILE *fp, int lineNum, char* type){
        fprintf(fp, "#%d %s\n", lineNum, type);
    }
%}
str \".*\"
char \'.\'
space [ \r\t\f\v]
DIGIT [0-9]
ID [a-zA-Z_][a-zA-Z0-9_]*
OP "+"|"-"|"*"|"/"|"<"|">"|"="|"<="|">="|"=="|"%" 
%x COMMENT
%x DATATYPE
%x FLOAT
%x NAME
%x DECLARE
%x INIT
%x STATEMENT
%x HEADER
%x FUNC_OR_VAR
%s FUNC


%%

"#" BEGIN(HEADER);
{str} printf("#%d string: %s\n", lineCount, yytext);
{char} printf("#%d char: %s\n", lineCount, yytext);
if|for|while|else printf("#%d branch: %s\n", lineCount, yytext);
{DIGIT}+ {printf("#%d value: %s\n", lineCount, yytext);}
"//".+  {printf("#%d one line comment: %s\n", lineCount, yytext);}
{OP} printf("#%d An operator: %s\n",lineCount, yytext );
"/*" {
    printf("#%d block comment start\n", lineCount);
    BEGIN(COMMENT);
}
"int"|"double"|"char" {
    printf("#%d data type: %s\n", lineCount, yytext);
    declare_flag = 1;
}
return {
    printf("#%d keyword: %s\n", lineCount, yytext);
}
{ID} { 
    strcpy(id, yytext);
    id_line = lineCount;
    BEGIN(FUNC_OR_VAR);
}
\n  {lineCount++; } 
{space} {}

<HEADER>{
    ">" BEGIN(0);
    \"  BEGIN(0);
    \n  {lineCount++; BEGIN(0);}
    .+   {printf("#%d Header: %s\n", lineCount, yytext);}
}

<COMMENT>{
     "*/"      {
        printf("#%d block comment end\n", lineCount);
        BEGIN(INITIAL);
     }
     [^*\n]+   // eat comment in chunks
     "*"       // eat the lone star
     \n        lineCount++;
}

<DECLARE>{
    {space} {} 
    {ID} {
        strcpy(id, yytext);
        id_line = lineCount;
        BEGIN(FUNC_OR_VAR);
       // printf("ID: %s\n", id);
    }
    "="{space} {
        printf("#%d (declare)variable ID: %s\n", id_line, id);
        ECHO;
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
        ECHO;
        BEGIN(0); 
    }
    "(" {
        printf("#%d (declare)function ID: %s\n", id_line, id);
        ECHO;
        BEGIN(0); 
    }
     
}
<INIT>{
    {ID} {
        strcpy(id, yytext);
        id_line = lineCount;
        BEGIN(FUNC_OR_VAR);
    }
    {DIGIT}+ printf("#%d value: %s\n", lineCount ,yytext);
    {str}   printf("#%d string: %s\n", lineCount ,yytext);  
    ";" BEGIN(0);
}
<STATEMENT>{
    {space} {}
    "="{space} {

        BEGIN(INIT);
    }
    \n   lineCount++;
    ","  printf("#%d variable ID: %s\n", id_line, id);
    ;    {
        printf("#%d variable ID: %s\n", id_line, id);
        BEGIN(INITIAL);
    }
    "("{space}")" {
        printf("%s\n", yytext);
        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
    "(" {
        printf("%s\n", yytext);
        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
}
<FUNC_OR_VAR>{
    [^(] {
        if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }
        printf("#%d variable ID: %s\n", id_line, id);
        BEGIN(0);
    }
    "("{space}")" {
        printf("%s\n", yytext);
         if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }

        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
    "(" {
        printf("%s\n", yytext);
        if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }

        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
        
}
"{"|"}"|"("|")"|";"|"," printf("%s\n", yytext);   
.   {printf("Unrec: %s\n",yytext);}
%%
int main(void) { 
    out = fopen("token.txt", "w");
    yylex();
    printf("total line: %d\n", lineCount);
    fclose(out);
    return 0;
}

int yywrap(){
    return 1;
}

