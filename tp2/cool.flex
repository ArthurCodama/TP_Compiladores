/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
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

void inLinecomment() {
  register int c;

  while(1) {
    while((c = input()) != '\n' && c != EOF)
      ; /* eat up text of comment */

    if(c == '\n') {
      curr_lineno++;
      break;
    } 
    else if (c == EOF) {
      error( "EOF in comment" );
      break;
    }
  }
}

void multiLineComment() {
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
      error( "EOF in comment" );
      break;
    }
  }
}

char* getString() {
  register int c;
  int i = 0;

  while(1) {
    while((c = input()) != '"' && c != '\\' && c != '\n' && c != EOF){
      if( i > MAX_STR_CONST ){
        error( "String is too long" );
        break;
      }

      string_buf[i++] = (char) c;
    }

    if( c == '\\' ) {
      c = input();

      if( i > MAX_STR_CONST ){
        error( "String is too long" );
        break;
      }


      if( c == 'b' )
        string_buf[i] = '\b';

      else if( c == 't' )
        string_buf[i] = '\t';

      else if( c == 'n' )
        string_buf[i] = '\n';

      else if( c == 'f' ) 
        string_buf[i] = '\f';

      else if( c == '\n')
        curr_lineno++;
      
      
      i++;
    } 
    else if( c == '\n' ){
      error( "Non-scaped newline in comment" );
      break;
    } 
    else if( c == EOF ) {
      error( "EOF in comment" );
      break;
    } 
    else // c = '"'
      break;
  }

  return strncpy(string_buf, 0, i+1);
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
"--"              { printf("IL Comment"); inLineComment(); }
"(*"              { printf("ML Comment"); multiLineComment(); }
"\""              { printf("String"); return getString(); }

{C_INT}           { return (INT_CONST); }
{C_BOOL}          { return (BOOL_CONST); }
{WHITE_SPACE}     { return (WHITE_SPACE); }
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

"=>"              { return (DARROW); }
"<-"              { RETURN (ASSIGN); }
"."               { RETURN (POINT); }
"("               { RETURN (L_PAR); }
")"               { RETURN (R_PAR); }
"@"               { RETURN (AT); }
"{"               { RETURN (L_KEY); }
"}"               { RETURN (R_KEY); }
";"               { RETURN (SEMIC); }
":"               { RETURN (COLON); }
"["               { RETURN (L_BRA); }
"]"               { RETURN (R_BRA); }
"+"               { RETURN (PLUS); }
"-"               { RETURN (MINUS); }
"*"               { RETURN (ASTERISK); }
"/"               { RETURN (BAR); }
"<"               { RETURN (LT); }
"<="              { RETURN (LE); }
"="               { RETURN (EQ); }
"~"               { RETURN (NOT); }

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