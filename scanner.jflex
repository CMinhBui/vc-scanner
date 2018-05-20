import java.io.*;

%%
%public
%class Scanner
%standalone

%unicode

%line
%column

%{
    StringBuilder string = new StringBuilder();

    private PrintWriter getOutputFile() {
        try {
            PrintWriter pw = new PrintWriter("output.txt");
            return pw;
        }
        catch (FileNotFoundException ex) {
            System.out.println("File not found");
        }
        return null;
    }

    PrintWriter pw = getOutputFile();
    
    private void printToken(String type) {
        String s = "line: " + yyline + " column: " + yycolumn + "\ttype: " + type + " token: " + yytext();
        pw.println(s);
    }

    private void printToken(String type, String string) {
        int column = yycolumn - string.length();
        String s = "line: " + yyline + " column: " + column + "\ttype: " + type + " token: " + string;
        pw.println(s);
    }
%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?

/* identifiers */
Identifier = [:jletter:][:jletterdigit:]*

/* keyword */
Keyword = "boolean" | "break" | "continue" | "else" | "for" | "float" | "if" | "int" | "return" | "void" | "while"

/* integer literals */
Digit = [0-9]
IntegerLiteral = {Digit}+

/* floating point literals */
FloatLiteral = {Digit}* {Fraction} {Exponent}? | {Digit}* \. | {Digit}* \.? {Exponent}

Fraction = \. {Digit}+
Exponent = [eE] [+-]? {Digit}+

/* string and character literals */
StringCharacter = [^\r\n\"\\]

/* boolean literal */
BooleanLiteral = "true" | "false"

/* spearators */
Separator = "(" | ")" | "{" | "}" | "[" | "]" | ";" | ","

/* Operators */
ArithmeticOperator = "+" | "-" | "*" | "/"
RelationalOperator = "<" | "<=" | ">" | ">="
EqualityOperator = "==" | "!="
LogicalOperator = "||" | "&&" | "!"
AssignmentOperator = "="

%state STRING
%%

<YYINITIAL> {
    /* keywords */
    {Keyword} { printToken("Keyword"); }

    /* boolean literals */
    {BooleanLiteral} { printToken("Boolean literal");}

    /* separators */
    {Separator} { printToken("Separator"); }

    /* operators */
    {ArithmeticOperator} { printToken("Arithmetic Operator"); }
    {RelationalOperator} { printToken("Relational Operator"); }
    {EqualityOperator} { printToken("Equality Operator"); }
    {LogicalOperator} { printToken("Logical Operator"); }
    {AssignmentOperator} { printToken("Assignment Operator"); }

    /* string literal */
    \" { yybegin(STRING); string.setLength(0); }

    /* numeric literals */
    {IntegerLiteral} { printToken("Integer literal"); }
    {FloatLiteral} { printToken("Float literal"); }

    /* comments */
    {Comment} { /* ignore */ }

    /* whitespace */
    {WhiteSpace} { /* ignore */ }

    /* identifiers */ 
    {Identifier} { printToken("Identifier"); }
}

<STRING> {

    \" { yybegin(YYINITIAL);  printToken("String literal", string.toString()); }

    {StringCharacter}+ { string.append( yytext() ); }

    /* escape sequences */
    "\\b" { string.append( '\b' ); }
    "\\t" { string.append( '\t' ); }
    "\\n" { string.append( '\n' ); }
    "\\f" { string.append( '\f' ); }
    "\\r" { string.append( '\r' ); }
    "\\\"" { string.append( '\"' ); }
    "\\'"  { string.append( '\'' ); }
    "\\\\" { string.append( '\\' ); }
    \\[0-3]?{Digit}?{Digit} { char val = (char) Integer.parseInt(yytext().substring(1),8);
                        				   string.append( val ); }
    
    /* error cases */
    \\. { throw new RuntimeException("Illegal escape sequence \""+yytext()+"\""); }
    {LineTerminator} { throw new RuntimeException("Unterminated string at end of line"); }
}

/* error fallback */
[^] { throw new RuntimeException("Illegal character \"" + yytext() + "\" at line "+yyline+", column "+yycolumn); }

<<EOF>>                          { pw.flush(); return 0;}