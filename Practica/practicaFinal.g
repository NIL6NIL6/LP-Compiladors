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
#include <cctype>
#include <map>
#include <vector>
#include <utility>
#include <string>

using namespace std;

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

/// Returns if a given string is a number or not
bool is_number(const string& s) {
  string::const_iterator it = s.begin();
  while( it != s.end() && std::isdigit(*it)) { ++it; }
  return it == s.end();
}

/// Transforms an AST list of string into a vector<string>
std::vector<std::string> list2vector(AST* list) { 
  AST* word = list->down;
  std::vector<string> phrase(0);
  while (word != NULL) {
    phrase.push_back(word->kind);
    word = word->right;
  }
  return phrase;
}

/// Prints the content of a vector<string>
void printStringVector(std::vector<string>& phrase) {
  for (int i = 0; i < phrase.size(); i++) {
    std::cout << phrase[i] << " ";
  }
}

/// Prints all answers for a given ANSWER
void printAnswers(std::map<int,std::vector<string\>>& ans) {
  for (map<int,std::vector<string\>>::iterator it = ans.begin(); it != ans.end(); it++) {
    std::cout << it->first << ": ";
    printStringVector(it->second);
    std::cout << std::endl;
  }
}

/// Treats the conversation part of the AST
void treatQAC(AST* root, std::map<std::string,std::vector<std::string\>>& qst, std::map<string, std::map<int, std::vector<std::string>\>>& ans, std::map<std::string,std::pair<std::string,std::string\>>& cht) {
  while(root != NULL) {
    if (root->down->kind == "->") { /// It is a CHATBOT definition
      cht[root->kind] = std::make_pair(root->down->down->kind, root->down->down->right->kind);
    } else {
      bool allnumbers = true;
      AST* aux = root->down->down;
      while (allnumbers && aux != NULL) { /// Checks if it is a question or an answer
        allnumbers = is_number(aux->kind);
        aux = aux->right;
      }
      aux = root->down; /// Access the given QUESTION or ANSWER list
      if (allnumbers) { /// It is an ANSWER definition
        aux = aux->down; /// Access the first ANSWER
        std::map<int,std::vector<string\>> aux_ans;
        while (aux != NULL) {
          std::vector<string> words = list2vector(aux->down);
          aux_ans[std::stoi(aux->kind)] = list2vector(aux->down);
          aux = aux->right;
        }
        ans[root->kind] = aux_ans;
      } else { /// It is a QUESTION definition
        qst[root->kind] = list2vector(aux);
      }
    }
    root = root->right;
  }
}

/// Identifies every chatbot by its ID
void treatChatbots(AST* root, map<string,AST*>& chatbots) {
  while(root != NULL) {
    chatbots[root->kind] = root->down;
    root = root->right;
  }
}

/// Executes a chat
void executeChat(string id, string botname, string usrname, std::map<string,std::vector<string\>>& qst, std::map<string,std::map<int,std::vector<string>\>>& ans, std::map<string,std::pair<string,string\>>& cht) {
  if (cht.find(id) == cht.end()) { /// Check if id is the ID of a valid chat
    std::cout << id << " ISN'T AN EXISTING CHAT" << std::endl;
    return;
  }
  std::pair<string,string> relation = cht[id];
  if (qst.find(relation.first) == qst.end() || ans.find(relation.second) == ans.end()) { /// Check if the question and the answers exist
    std::cout << "EITHER " << relation.first << " ISN'T A QUESTION OR " << relation.second << " ISN'T AN ANSWER" << std::endl;
    return; 
  }

  std::cout << botname << " > " << usrname << ", "; /// Print of the question
  printStringVector(qst[relation.first]);
  std::cout << "?" << std::endl;

  printAnswers(ans[relation.second]); /// Print of the possible answers
  int entry;
  std::cout << usrname << " > ";
  std::cin \>> entry;
  while (ans[relation.second].find(entry) == ans[relation.second].end()) {
    std::cout << "PLEASE ENTER A CORRECT ANSWER" << std::endl;
    std::cout << usrname << " > ";
    std::cin \>> entry;
  }
}

/// Executes a given chatbot
void executeChatbot(AST* root, string botname, string usrname, std::map<string,std::vector<string\>>& qst, std::map<string,std::map<int,std::vector<string>\>>& ans, std::map<string,std::pair<string,string\>>& cht) {
  if (root->kind == "THEN") {
    root = root->down;
    while (root != NULL) { executeChatbot(root, botname, usrname, qst, ans, cht); root = root->right; }
  } else if (root->kind == "OR") {
    int size = 0;
    AST* aux = root->down;
    while (aux != NULL) { size++; aux = aux->right; } /// Get how many options there are
    int i = rand() % size; /// Choose randomly one of those options
    root = root->down;
    while (i > 0) { root = root->right; i--; }
    executeChatbot(root, botname, usrname, qst, ans, cht);
  } else {
    string id = root->kind;
    executeChat(id, botname, usrname, qst, ans, cht);
  }
}

/// Executes all the chatbots
void initExecution(AST* root, std::map<string,std::vector<string\>>& qst, std::map<string,std::map<int,std::vector<string>\>>& ans, std::map<string,std::pair<string,string\>>& cht, std::map<string,AST*> chbt) {
  std::srand(std::stoi(root->kind));
  root = root->right;
  while (root != NULL) {
    if (chbt.find(root->kind) == chbt.end()) {
      std::cout << "THERE IS NO CHATBOT WITH NAME " << root->kind << endl;
      return;
    }
    std::cout << root->kind << " > WHAT IS YOUR NAME ? " << std::endl;
    string usrname;
    std::cin \>> usrname;
    executeChatbot(chbt[root->kind], root->kind, usrname, qst, ans, cht);
    std::cout << root->kind << " > THANKS FOR THE CHAT " << usrname << "!" << std::endl;
    root = root->right;
  }
}

/// The execution of the program following the AST instructions
void execute(AST *a) {
  std::map<string,std::vector<string\>> questions; /// The map with all the questions defined by their ID
  std::map<string,std::map<int,vector<string>\>> answers; /// The map with all the answers defined by their ID
  std::map<string,std::pair<string,string\>> chats; /// The map of associations between questions and answers
  treatQAC(a->down->down, questions, answers, chats);

  std::map<string,AST*> chatbots;
  treatChatbots(a->down->right->down, chatbots);

  initExecution(a->down->right->right->down, questions, answers, chats, chatbots);
}

int main() {
  AST *root = NULL;
  ANTLR(chatbot(&root), stdin);
  ASTPrint(root);
  execute(root);
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
order: atom (| (THEN^ atom) (THEN! atom)*);
atom: (HASH! ID | OPPAR! chatconditions CLPAR!);
/// Executed chatbots
startchat: INTERACTION! NUM (ID)+ END! <<#0=createASTlist(_sibling);>>;
