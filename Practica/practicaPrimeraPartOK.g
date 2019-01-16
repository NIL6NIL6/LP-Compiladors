#header
<<
#include <string>
#include <iostream>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
>>

<<
#include <cstdlib>
#include <cmath>
// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
  attr->kind = text;
  attr->text = "";
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a,int n) {
 AST *c=a->down;
 for (int i=0; c!=NULL && i<n; i++) c=c->right;
 return c;
} 

/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a,string s)
{
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") cout<<"("<<a->text<<")";
  cout<<endl;

  AST *i = a->down;
  while (i!=NULL && i->right!=NULL) {
    cout<<s+"  \\__";
    ASTPrintIndent(i,s+"  |"+string(i->kind.size()+i->text.size(),' '));
    i=i->right;
  }
  
  if (i!=NULL) {
      cout<<s+"  \\__";
      ASTPrintIndent(i,s+"   "+string(i->kind.size()+i->text.size(),' '));
      i=i->right;
  }
}

/// print AST 
void ASTPrint(AST *a)
{
  while (a!=NULL) {
    cout<<" ";
    ASTPrintIndent(a,"");
    a=a->right;
  }
}

// Crea una llista d'AST
AST* createASTlist(AST* n) {
  AST* as = new AST;
  as->kind = "list";
  as->text = "";
  as->right = NULL;
  as->down = n;
  return as;
}

int main() {
  AST *root = NULL;
  ANTLR(chatbot(&root), stdin);
  ASTPrint(root);
}
>>

#lexclass START
#token QUESTION "QUESTION"
#token ANSWERS "ANSWERS"
#token CONVERSATION "CONVERSATION"
#token CHATBOT "CHATBOT"
#token INTERACTION "INTERACTION"
#token OR "OR"
#token THEN "THEN"
#token END "END"
#token NUM "[0-9]+"
#token ID "[0-9a-zA-Z]+"
#token OPCLA "\["
#token CLCLA "\]"
#token OPPAR "\("
#token CLPAR "\)"
#token COMMA "\,"
#token SEMICOLON "\;"
#token ARROW "\-\>"
#token INTERROGATION "\?"
#token HASH "\#"
#token SPACE "[\:\ \n]" << zzskip();>>

chatbot: conversations chats startchat <<#0=createASTlist(_sibling);>>;
/// Conversations
conversations:(conversationtypes)+ <<#0=createASTlist(_sibling);>>;
conversationtypes: ID^ (QUESTION! question | ANSWERS! answer | CONVERSATION! conversation);
/// Question
question: (ID)+ INTERROGATION! <<#0=createASTlist(_sibling);>>;
/// Answer
answer: (answerpicker1 | answerpicker2);
answerpicker1: (answers1)+ <<#0=createASTlist(_sibling);>>;
answers1: NUM^ answerbody SEMICOLON!;
answerpicker2: OPCLA! (answers2) (COMMA! answers2)* CLCLA! <<#0=createASTlist(_sibling);>>;
answers2: OPPAR! NUM^ COMMA! answerbody CLPAR!;
answerbody: (ID)+ <<#0=createASTlist(_sibling);>>;
/// Conversation
conversation: HASH! ID ARROW^ HASH! ID;
/// Chatbots
chats: (CHATBOT! chatter)+ <<#0=createASTlist(_sibling);>>;
chatter: ID^ chatconditions;
chatconditions: order ( | (OR^ order) (OR! order)*);
order: atom (THEN^ atom)*;
atom: (HASH! ID | OPPAR! chatconditions CLPAR!);
/// Executed chatbots
startchat: INTERACTION! NUM (ID)+ END! <<#0=createASTlist(_sibling);>>;
