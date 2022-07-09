/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */

%option noyywrap


%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
  if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
    YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

extern int input(); // lex function
int tableIndex = 0;

int inLineComment() {
  register int c;

  while(1) {
    while((c = input()) != '\n' && c != EOF)
      ; /* eat up text of comment */

    if(c == '\n') {
      curr_lineno++;
      break;
    } 
    else if (c == EOF) {
      yylval.error_msg = (char*)"EOF in comment";
      return -1;
    }
  }
  
  return 0;
}

int multiLineComment() {
  register int c;

  while(1) {
    while((c = input()) != '*' && c != '\n' && c != EOF)
      ; /* eat up text of comment */

    if(c == '*') {
      while((c = input()) == '*')
        ;
      if (c == ')')
        break; /* found the end */
    }

    if(c == '\n')
      curr_lineno++;

    else if(c == EOF) {
      yylval.error_msg = (char*)"EOF in comment";
      return -1;
    }
  }

  return 0;
}

int setStringValue() {
  register int c;
  int i = 0;

  while(1) {
    c = input();

    if( (i + 1) >= MAX_STR_CONST ){
      yylval.error_msg = (char*)"String constant too long";
      return -1;
    }

    if( c == '\0' ) {
      yylval.error_msg = (char*)"String contains null character";
      return -1;
    }

    else if( c == '\\' ) {
      c = input();

      if( (i + 1) >= MAX_STR_CONST ){
        yylval.error_msg = (char*)"String constant too long";
        return -1;
      }

      if( c == 'b' )
        string_buf[i++] = '\b';

      else if( c == 't' )
        string_buf[i++] = '\t';

      else if( c == 'n' )
        string_buf[i++] = '\n';

      else if( c == 'f' ) 
        string_buf[i++] = '\f';

      else if( c == '\n')
        curr_lineno++;
      
      else 
        string_buf[i++] = (char) c;

      i++;
    } 

    else if( c == '\n' ) {
      yylval.error_msg = (char*)"Unterminated string constant";
      return -1;
    } 

    else if( c == EOF ) {
      yylval.error_msg = (char*)"EOF in string constant";
      return -1;
    } 

    else if( c == '"' )
      break;
    
    else {
      string_buf[i++] = (char) c;
    }
  }

  yylval.symbol = Entry(strncpy(string_buf, 0, i), i, tableIndex++);
  return 0;
}

%}

/*
 * Define names for regular expressions here.
 */

C_INT             [0-9]+
C_BOOL            (t(?i:[rue])|f(?i:[alse]))
ID_TYPE           [A-Z][a-z|A-Z|0-9|_]*
ID_OBJECT         [a-z][a-z|A-Z|0-9|_]*
WHITE_SPACE       [\s\f\r\t\v]
CLASS             (?i:class)
ELSE              (?i:else)
FI                (?i:fi)
IF                (?i:if)
IN                (?i:in)
INHERITS          (?i:inherits)
ISVOID            (?i:isvoid)
LET               (?i:let)
LOOP              (?i:loop)
POOL              (?i:pool)
THEN              (?i:then)
WHILE             (?i:while)
CASE              (?i:case)
ESAC              (?i:esac)
NEW               (?i:new)
OF                (?i:of)
NOT               (?i:not)

%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */

{WHITE_SPACE}     {}
"--"              { if( inLineComment() == -1 ) return (ERROR); }
"(*"              { if( multiLineComment() == -1 ) return (ERROR); }
"\""              { if( setStringValue() == -1 ) return (ERROR); return (STR_CONST); }
{C_INT}           { return (INT_CONST); }
{C_BOOL}          { return (BOOL_CONST); }
{CLASS}           { return (CLASS); }
{ELSE}            { return (ELSE); }
{FI}              { return (FI); }
{IF}              { return (IF); }
{IN}              { return (IN); }
{INHERITS}        { return (INHERITS); }
{ISVOID}          { return (ISVOID); }
{LET}             { return (LET); }
{LOOP}            { return (LOOP); }
{POOL}            { return (POOL); }
{THEN}            { return (THEN); }
{WHILE}           { return (WHILE); }
{CASE}            { return (CASE); }
{ESAC}            { return (ESAC); }
{NEW}             { return (NEW); }
{OF}              { return (OF); }
{ID_TYPE}         { return (TYPEID); }
{ID_OBJECT}       { return (OBJECTID); }
{NOT}             { return (NOT); }

"=>"              { return (DARROW); }
"<-"              { return (ASSIGN); }
"<="              { return (LE); }
"."               { return '.'; }
"("               { return '('; }
")"               { return ')'; }
"@"               { return '@'; }
"{"               { return '{'; }
"}"               { return '}'; }
";"               { return ';'; }
":"               { return ':'; }
"["               { return '['; }
"]"               { return ']'; }
"+"               { return '+'; }
"-"               { return '-'; }
"*"               { return '*'; }
"/"               { return '/'; }
"<"               { return '<'; }
"="               { return '='; }
"~"               { return '~'; }

<<EOF>>           { yyterminate(); }



 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
/*
main(){
  yylex();
}
*/