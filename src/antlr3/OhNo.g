grammar OhNo;

options {
	backtrack = true;
	memoize = true;
	output = AST;
	ASTLabelType = CommonTree;
}

tokens {
ASSIGN                  = '='               ;
COLON                   = ':'               ;
COMMA                   = ','               ;
DEC                     = '--'              ;
DIV                     = '/'               ;
DOT                     = '.'               ;
EQUAL                   = '=='              ;
GREATER_OR_EQUAL        = '>='              ;
GREATER_THAN            = '>'               ;
INC                     = '++'              ;
LBRACK                  = '['               ;
LCURLY                  = '{'               ;
LESS_OR_EQUAL           = '<='              ;
LESS_THAN               = '<'               ;
LOGICAL_AND             = '&&'              ;
LOGICAL_NOT             = '!'               ;
LOGICAL_OR              = '||'              ;
LPAREN                  = '('               ;
MINUS                   = '-'               ;
MOD                     = '%'               ;
NOT_EQUAL               = '!='              ;
PLUS                    = '+'               ;
QUESTION                = '?'               ;
RBRACK                  = ']'               ;
RCURLY                  = '}'               ;
RPAREN                  = ')'               ;
SEMI                    = ';'               ;
MULT                    = '*'               ;

// types
BOOL                    = 'bool'            ;
INT                     = 'int'             ;
STRING                  = 'string'          ;
LIST                    = 'list'            ;
MAP                     = 'map'             ;
VOID                    = 'void'            ;
NULL                    = 'null'            ;

POINT                   = '=>'              ;

// keywords

ABSTRACT                = 'abstract'        ;
BREAK                   = 'break'           ;
CASE                    = 'case'            ;
CLASS                   = 'class'           ;
CONTINUE                = 'continue'        ;
DEFAULT                 = 'default'         ;
DO                      = 'do'              ;
ELSE                    = 'else'            ;
EXTENDS                 = 'extends'         ;
FALSE                   = 'false'           ;
FOR                     = 'for'             ;
IF                      = 'if'              ;
IMPLEMENTS              = 'implements'      ;
INTERFACE               = 'interface'       ;
NEW                     = 'new'             ;
PRIVATE                 = 'private'         ;
PROTECTED               = 'protected'       ;
PUBLIC                  = 'public'          ;
RETURN                  = 'return'          ;
STATIC                  = 'static'          ;
SUPER                   = 'super'           ;
SWITCH                  = 'switch'          ;
THIS                    = 'this'            ;
TRUE                    = 'true'            ;
WHILE                   = 'while'           ;

VAR_DEC;
TYPE_LIST;
FUNC_DEC;
ROOT_NODE;
BLOCK;
}

@parser::header {package edu.ua.ohno.lang;}
@lexer::header {package edu.ua.ohno.lang;}

//classes can only extend classes in the current or parent scope, a class cannot extend an internal class such as Tree.Node unless it is also a member of Tree.

prog: root* -> ^(ROOT_NODE root*)
	;

root
	: interface_dec
	| class_dec
	| func_dec
	| var_dec SEMI!
	| statement
	;


interface_dec
	: INTERFACE^ IDENT class_extends? interface_block
	;

interface_block
	: LCURLY (function_fingerprint)* RCURLY -> ^(BLOCK function_fingerprint*)
	;

function_fingerprint
	: return_type IDENT LPAREN type_arg_list? RPAREN SEMI -> ^(FUNC_DEC return_type IDENT type_arg_list?)
	;

type_arg_list
	: type_def IDENT (COMMA! type_def IDENT)*
	;

	
return_type
	: type_def
	| VOID
	;

type_def
	: INT
	| BOOL
	| STRING
	| LIST LESS_THAN type_def GREATER_THAN -> ^(LIST type_def)
	| MAP LESS_THAN type_def GREATER_THAN -> ^(LIST type_def)
	| user_type
	;

user_type
	: IDENT (DOT^ IDENT)*
	;


class_dec
	: ABSTRACT? CLASS IDENT class_implements? class_extends? class_block -> ^(CLASS IDENT ABSTRACT? class_implements? class_extends? class_block)
	;

class_implements
    : IMPLEMENTS IDENT -> ^(IMPLEMENTS IDENT)
    ;

class_extends
    : EXTENDS IDENT -> ^(EXTENDS IDENT)
    ;

class_block
    : LCURLY (class_statement | scope_dec)* RCURLY -> ^(BLOCK class_statement* scope_dec*)
    ;

class_statement
	: member_var_dec
	| method_dec
	| constructor_dec
	| class_dec
	;

scope_dec
	: (PRIVATE^ | PROTECTED^ | PUBLIC^) COLON! class_statement*
	;

member_var_dec
	: STATIC? type_def var_assn (COMMA var_assn)* SEMI -> ^(VAR_DEC STATIC? type_def var_assn+)
	;

method_dec
	: STATIC? return_type IDENT LPAREN type_arg_list? RPAREN block ->  ^(FUNC_DEC IDENT STATIC? return_type type_arg_list? block)
	;

constructor_dec
	: IDENT LPAREN type_arg_list? RPAREN block -> ^(FUNC_DEC IDENT type_arg_list? block)
	;

var_dec
	: type_def var_assn (COMMA var_assn)* -> ^(VAR_DEC type_def var_assn+)
	;
	
var_assn
	: IDENT (ASSIGN^ expr)?
	;
	
map_literal
	: LCURLY literal POINT^ expr (COMMA! literal POINT^ expr)* RCURLY!
	;

list_literal
	: LBRACK expr_list? RBRACK -> ^(LIST expr_list?)
	;
	
func_dec
	: return_type IDENT LPAREN type_arg_list? RPAREN block ->  ^(FUNC_DEC IDENT return_type type_arg_list? block)
	;

    
block
	: LCURLY (var_dec SEMI | func_dec | class_dec | statement)* RCURLY -> ^(BLOCK var_dec* func_dec* class_dec* statement*)
	;
	
statement
	: block
	| if_statement
	| while_statement
	| for_statement
	| switch_statement
	| return_statement SEMI!
	| expr SEMI!
 	| BREAK SEMI!
	| CONTINUE SEMI!
	| SEMI!
	;
	
if_statement
	: IF LPAREN expr RPAREN statement (ELSE statement)? -> ^(IF expr statement+)
	;

return_statement
	: RETURN expr?
	;

while_statement
	: WHILE LPAREN expr RPAREN statement -> ^(WHILE expr statement)
	;

for_statement
	: FOR LPAREN for_control RPAREN statement -> ^(FOR for_control statement)
	;
	
for_control
	: (expr_list | var_dec)? SEMI expr? SEMI expr_list?
	| type_def IDENT SEMI expr
	;

switch_statement
	: SWITCH LPAREN expr RPAREN LCURLY case_block* case_default RCURLY -> ^(SWITCH expr case_block* case_default)
	;
	
case_block
	: CASE literal COLON statement* -> ^(CASE literal statement*)
	;

case_default
	: DEFAULT COLON statement* -> ^(DEFAULT statement*)
	;
	
expr_list
	: expr (COMMA expr)* -> expr+
	;


expr 	
	: or_expr (ASSIGN^ or_expr)*
	;

or_expr 	
	: and_expr (LOGICAL_OR^ and_expr)*
	;
	
and_expr
	: eq_expr (LOGICAL_AND^ eq_expr)*
	;

eq_expr
	: ineq_expr ((NOT_EQUAL^|EQUAL^) ineq_expr)*
	;

ineq_expr
	: add_expr ((LESS_THAN^ | GREATER_THAN^ | LESS_OR_EQUAL^ | GREATER_OR_EQUAL^)  add_expr)*
	;
	
add_expr	
	: mult_expr ((PLUS^|MINUS^) mult_expr)*
	;
	
mult_expr
	: prefix_expr ((MULT^|DIV^|MOD^) prefix_expr)*
	;
	
prefix_expr
	: (PLUS^ | MINUS^ | LOGICAL_NOT^ | INC^ | DEC^)? postfix_expr
	;

postfix_expr
	: primary (INC | DEC)?
	;
	
primary
	: LPAREN! expr RPAREN!
	| literal
	| identifier
	| list_literal
	| map_literal
	| class_call
	| NEW IDENT (DOT^ IDENT)* func_call
	;

literal
    : NUMBER
    | STRING_LIT
    | TRUE
    | FALSE
    | NULL
    ;
    

NUMBER
    : '0' 
    | '1'..'9' '0'..'9'*
    ;
    
    
STRING_LIT
    : '"' (ESCAPE | ~('\\'|'"'))* '"'
    ;

class_call
	: SUPER (func_call | (DOT identifier))
	| THIS (DOT^ identifier)?
	; 

identifier
	: IDENT func_call? index_ref* (DOT identifier)?
	;

func_call
	: LPAREN! expr_list? RPAREN!
	;

fragment index_ref
	: LBRACK! expr RBRACK!
    | LCURLY! expr RCURLY!
    ;


IDENT
    : IDENT_HEAD (IDENT_TAIL)*
    ;

fragment IDENT_HEAD
    : '_'
    | 'A'..'Z'
    | 'a'..'z'
    ;

fragment IDENT_TAIL
    : IDENT_HEAD
    | '0'..'9'
    ;

//escape sequences for string literals
fragment ESCAPE
    : '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;

//discard whitespace and comments
WS
    : (' '|'\r'|'\t'|'\n')+ {skip();}
    ;

COMMENT	
    : '/*' ( options {greedy=false;} : . )* '*/' {skip();} 
    ;

LINE_COMMENT 
	: '//' ~('\n'|'\r')* '\r'? '\n' {skip();} 
    ;
