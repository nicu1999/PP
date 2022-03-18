
nor2(X, Y) :- neg(X) , neg(Y).
neg(Z):- call(Z), !, fail.
neg(X).