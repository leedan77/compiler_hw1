%{
    #include <stdio.h>
    int lineCount=0; 
    int charCount=0;
    FILE *out;
    void print(FILE *fp, int lineNum, char* type){
        fprintf(fp, "#%d %s\n", lineNum, type);
    }
%}

%x COMMENT

%%

\n  lineCount++;

"/*" {
    print(out, lineCount, "Comment");
    BEGIN(COMMENT);
}

<COMMENT>{
     "*/"      {BEGIN(INITIAL);}
     [^*\n]+   // eat comment in chunks
     "*"       // eat the lone star
     \n        lineCount++;
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
