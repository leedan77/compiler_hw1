/* C subset:
 * Variable declaration/initialization
 * Int, double, float, char
 * Simple statement
 * for loop, if else, while loop
 * Comment, Comment block
 * Operator
 * Header
 * Char or String
 */


%{
    #include <stdio.h>
    #include <string.h>
    int lineCount=1; 
    int charCount=0;
    char id[256];
    int id_line;
    int declare_flag = 0;
    void print(FILE *fp, int lineNum, char* type){
        fprintf(fp, "#%d %s\n", lineNum, type);
    }
%}
PLUS_MINUS "+"|"-"
STR \".*\"
CHAR \'.\'
SPACE [ \r\t\f\v]
FLOAT [0-9]+.[0-9]+
DIGIT [0-9]
ID [a-zA-Z_][a-zA-Z0-9_]*
OP "+"|"-"|"*"|"/"|"<"|">"|"="|"<="|">="|"=="|"%" 
%x COMMENT
%x HEADER
%x FUNC_OR_VAR


%%

"{"|"}"|"("|")"|";"|"," printf("#%d %s\n", lineCount, yytext);   
"#" BEGIN(HEADER);
{STR} printf("#%d string: %s\n", lineCount, yytext);
{CHAR} printf("#%d char: %s\n", lineCount, yytext);
if|for|while|else printf("#%d branch: %s\n", lineCount, yytext);
{PLUS_MINUS}?{FLOAT} {printf("#%d float: %s\n", lineCount, yytext);}
{PLUS_MINUS}?{DIGIT}+ {printf("#%d integer: %s\n", lineCount, yytext);}
"//".+  {printf("#%d one line comment: %s\n", lineCount, yytext);}
{OP} printf("#%d An operator: %s\n",lineCount, yytext );
"/*" {
    printf("#%d block comment start\n", lineCount);
    BEGIN(COMMENT);
}
"int"|"double"|"char"|"float" {
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
{SPACE} {}

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

<FUNC_OR_VAR>{
    [^(] {
        if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }
        printf("#%d variable ID: %s\n", id_line, id);
        BEGIN(0);
    }
    "("{SPACE}")" {
        printf("#%d %s\n", lineCount, yytext);
         if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }

        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
    "(" {
        printf("#%d %s\n", lineCount, yytext);
        if (declare_flag){
            printf("(declared)");
            declare_flag = 0;
        }

        printf("#%d function ID: %s\n", id_line, id);
        BEGIN(0); 
    }
        
}
.   {printf("Unrec: %s\n",yytext);}
%%
int main(void) { 
    yylex();
    printf("total line: %d\n", lineCount);
    return 0;
}

int yywrap(){
    return 1;
}

