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

DARROW            =>
C_INT             [0-9]+
C_BOOL            (t(?i:[rue])|f(?i:[alse]))
ID_TYPE           [A-Z][a-z|A-Z|0-9|_]*
ID_OBJECT         [a-z][a-z|A-Z|0-9|_]*
WHITE_SPACE       [\s\f\r\t\v]
DARROW            =>
C_INT             [0-9]+
C_BOOL            (t(?i:[rue])|f(?i:[alse]))
ID_TYPE           [A-Z][a-z|A-Z|0-9_]*
ID_OBJECT         [a-z][a-z|A-Z|0-9_]*
WHITE_SPACE       [\ \f\r\t\v]
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
{DARROW}		{ return (DARROW); }
"--"        {printf("IL Comment");inLineComment();}
"(*"        {printf("ML Comment");multiLineComment();}
"\""        {printf("String"); return getString();}
<<EOF>>     {yyterminate();}



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