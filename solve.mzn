
% Entrada

int: qtd_Itens           = 2;
int: qtd_Encomendas      = 5;
int: qtd_Destinatarios   = 2;
int: qtd_Centralizadoras = 2;
int: qtd_Produtores      = 2;
int: T                   = 4;

set of int: Itens           = 1..qtd_Itens;
set of int: Encomendas      = 1..qtd_Encomendas;
set of int: Destinatarios   = 1..qtd_Destinatarios;
set of int: Centralizadoras = 1..qtd_Centralizadoras;
set of int: Produtores      = 1..qtd_Produtores;

% Considerando que no pior caso tera um palete por encomenda
% Mas a funcao objetivo busca minimizar o numero de paletes
set of int: Paletes         = 1..qtd_Encomendas;

array[Itens] of set of int: S = [{1,2},{3,4,5}];

array[Encomendas] of int: dest = [1,2,1,2,2];
array[Encomendas] of int: peso = [1,1,3,3,2];

int: CapacidadePalete = 5;

array[Destinatarios] of set of int: cent = [{1},{2}];

array[Produtores, Itens] of int: qtd = [| 1, 0 | 0, 1 |];

% Variaveis

% qtd_Paletes nao vai ser variavel
%var int: qtd_Paletes;
int: qtd_Paletes == qtd_Encomendas;

array[Paletes] of var Produtores: Q;
array[Paletes] of var Centralizadoras: C;
array[Paletes] of var set of Encomendas: P;

% Restricoes

constraint forall(p1, p2 in Paletes)(
               if p1 != p2 then P[p1] intersect P[p2] = {} 
               else true endif );




constraint forall(p in Paletes)(
              forall (e in P[p])(
                C[p] in cent[dest[e]]
              )
           );

constraint array_union([P[p] | p in Paletes]) == Encomendas;

constraint forall(q in Produtores)(
              forall(i in Itens)(
                 sum(p in Paletes where Q[p] == q)
                    (card(P[p] intersect S[i])) <= qtd[q,i]*T
              )
           );

constraint forall(p in Paletes)(
                  %P[p] != {} /\ permitindo paletes vazios pra min
                  sum(e in P[p])(peso[e]) <= CapacidadePalete
            );
            
% funcao objetivo            
            
array[Paletes] of var int: palete_usado;
constraint forall(p in Paletes)(
                    palete_usado[p] == if P[p] == {} then 0
                                      else               1 endif
                 );
solve minimize sum(palete_usado);

output [ show(P) ] ++ [show(sum(palete_usado))];