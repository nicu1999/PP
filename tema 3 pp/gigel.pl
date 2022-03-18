:- ensure_loaded('chat.pl').
% Returneaza true dacă regula dată ca argument se potriveste cu
% replica data de utilizator. Replica utilizatorului este
% reprezentata ca o lista de tokens. Are nevoie de
% memoria replicilor utilizatorului pentru a deduce emoția/tag-ul
% conversației.
% rule([ce, faci, '?'], [[bine, tu, '?']], [], [], [])
% match_rule([salut, ce, faci, '?'], _, rule([ce, faci, '?'], [[bine, tu, '?']], [], [], [])).
% match_rule([ma, uit, la, un, film], _, rule([ma, Z, la, _, X], [[ce, X, '?']], [], [], [])).
% match_rule([salut, ce, faci, '?'], _, rule(EXPRESIE, _, _, _, _))
match_rule(TOKENS, _, rule(EXPRESIE, _, _, _, _)) :- 
intersection(TOKENS, EXPRESIE, EXPRESIE).

% Primeste replica utilizatorului (ca lista de tokens) si o lista de
% reguli, iar folosind match_rule le filtrează doar pe cele care se
% potrivesc cu replica dată de utilizator.

% find_matching_rules([esti, om, '?'], rules([esti], [rule([esti, X],
%[[nu, cred, ca, pot, fi, X, sunt, doar, un, robot],[tu, esti, X]], [], [], []),
%rule([esti, X, '?'], [[sunt, la, fel, de, X, ca, tine],
%[X, '?', nu, cred, dar, tu, '?']], [], [], [])]), _UserMemory, OUT_RULES)

find_matching_rules(REPLICA, rules(_, IN_RULES), _, OUT_RULES) :- 
findall(X, (member(X, IN_RULES), match_rule(REPLICA, _, X)), OUT_RULES).

% Intoarce in Answer replica lui Gigel. Selecteaza un set de reguli
% (folosind predicatul rules) pentru care cuvintele cheie se afla in
% replica utilizatorului, in ordine; pe setul de reguli foloseste
% find_matching_rules pentru a obtine un set de raspunsuri posibile.
% Dintre acestea selecteaza pe cea mai putin folosita in conversatie.
%
% Replica utilizatorului este primita in Tokens ca lista de tokens.
% Replica lui Gigel va fi intoarsa tot ca lista de tokens.
%
% UserMemory este memoria cu replicile utilizatorului, folosita pentru
% detectarea emotiei / tag-ului.
% BotMemory este memoria cu replicile lui Gigel și va si folosită pentru
% numararea numarului de utilizari ale unei replici.
%
% In Actions se vor intoarce actiunile de realizat de catre Gigel in
% urma replicii (e.g. exit).
%
% Hint: min_score, ord_subset, find_matching_rules
% select_answer([salut, ce, faci, '?'], _, _, ANSWER, ACTIONS).


select_answer(INPUT, _, BOTMEMORY, ANSWER, ACTIONS) :- 
rules(KEY, Y), intersection(INPUT, KEY, KEY),
find_matching_rules(INPUT, rules(KEY, Y), _, OUT_RULES),
member(rule(_, F, ACTIONS, _, _), OUT_RULES), 
findall((PROP, VAL), (member(A, F), get_answer(A, BOTMEMORY, VAL), unwords(A, PROP)), OUT),
min_element(OUT, P), words(P, ANSWER).

% Esuează doar daca valoarea exit se afla in lista Actions.
% Altfel, returnează true.
handle_actions(EXIT_LIST) :- (\+ member(exit, EXIT_LIST)).


% Caută frecvența (numărul de apariți) al fiecarui cuvânt din fiecare
% cheie a memoriei.
% e.g
% ?- find_occurrences(memory{'joc tenis': 3, 'ma uit la box': 2, 'ma uit la un film': 4}, Result).
% Result = count{box:2, film:4, joc:3, la:6, ma:6, tenis:3, uit:6, un:4}.
% Observați ca de exemplu cuvântul tenis are 3 apariți deoarce replica
% din care face parte a fost spusă de 3 ori (are valoarea 3 în memorie).
% Recomandăm pentru usurința să folosiți înca un dicționar în care să tineți
% frecvențele cuvintelor, dar puteți modifica oricum structura, această funcție
% nu este testată direct.
find_occurrences(_UserMemory, _Result) :- fail.

% Atribuie un scor pentru fericire (de cate ori au fost folosit cuvinte din predicatul happy(X))
% cu cât scorul e mai mare cu atât e mai probabil ca utilizatorul să fie fericit.
get_happy_score(_UserMemory, _Score) :- fail.
%findall(X, (member(X, _UserMemory), happy(X)), HAPPYINSTANCE),
%lenght(HAPPYINSTANCE, _Score).

% Atribuie un scor pentru tristețe (de cate ori au fost folosit cuvinte din predicatul sad(X))
% cu cât scorul e mai mare cu atât e mai probabil ca utilizatorul să fie trist.
get_sad_score(_UserMemory, _Score) :- fail.

% Pe baza celor doua scoruri alege emoția utilizatorul: `fericit`/`trist`,
% sau `neutru` daca scorurile sunt egale.
% e.g:
% ?- get_emotion(memory{'sunt trist': 1}, Emotion).
% Emotion = trist.
get_emotion(_UserMemory, _Emotion) :- fail.

% Atribuie un scor pentru un Tag (de cate ori au fost folosit cuvinte din lista tag(Tag, Lista))
% cu cât scorul e mai mare cu atât e mai probabil ca utilizatorul să vorbească despre acel subiect.
get_tag_score(_Tag, _UserMemory, _Score) :- fail.

% Pentru fiecare tag calculeaza scorul și îl alege pe cel cu scorul maxim.
% Dacă toate scorurile sunt 0 tag-ul va fi none.
% e.g:
% ?- get_emotion(memory{'joc fotbal': 2, 'joc box': 3}, Tag).
% Tag = sport.
get_tag(_UserMemory, _Tag) :- fail.
