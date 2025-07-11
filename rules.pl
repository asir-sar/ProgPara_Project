
:- consult(facts).

% --- Atomic Filters ---
has_director(ID, Dir) :- director(ID, Dir).
has_genre(ID, Genre) :- movie_genre(ID, Genre).
has_actor(ID, Actor) :- cast(ID, Actor, _).
released_in(ID, Year) :- movie(ID, _, _, _, _, Year, _, _, _).
rating_above(ID, Threshold) :- movie(ID, _, _, _, _, _, _, _, Rating), Rating >= Threshold.
rating_below(ID, Threshold) :- movie(ID, _, _, _, _, _, _, _, Rating), Rating =< Threshold.
runtime_above(ID, Minutes) :- movie(ID, _, _, _, _, _, _, Runtime, _), Runtime >= Minutes.
has_keyword(ID, Keyword) :- keyword(ID, Keyword).
original_language(ID, Lang) :- movie(ID, _, _, Lang, _, _, _, _, _).
is_adult(ID) :- movie(ID, _, _, _, true, _, _, _, _).
movie_name(ID, Name) :- movie(ID, Name, _, _, _, _, _, _, _).

% --- Pattern-based multi-condition matcher ---
matches_all(_, []).
matches_all(ID, [Cond | Rest]) :-
    (   Cond = has_director(Dir)         -> has_director(ID, Dir)
    ;   Cond = has_genre(Genre)          -> has_genre(ID, Genre)
    ;   Cond = has_actor(Actor)          -> has_actor(ID, Actor)
    ;   Cond = released_in(Year)         -> released_in(ID, Year)
    ;   Cond = rating_above(Thresh)      -> rating_above(ID, Thresh)
    ;   Cond = rating_below(Thresh)      -> rating_below(ID, Thresh)
    ;   Cond = runtime_above(Min)        -> runtime_above(ID, Min)
    ;   Cond = has_keyword(KW)           -> has_keyword(ID, KW)
    ;   Cond = original_language(Lang)   -> original_language(ID, Lang)
    ;   Cond = is_adult                  -> is_adult(ID)
    ;   Cond = movie_name(Name)          -> movie_name(ID, Name)
    ),
    matches_all(ID, Rest).

% --- Main query rule ---
query_movies(Conditions, ID) :-
    movie(ID, _, _, _, _, _, _, _, _),
    matches_all(ID, Conditions).

% --- Result composer ---
movie_details(ID, Title, Year, Genres, Cast, Director, Keywords) :-
    movie(ID, Title, _, _, _, Year, _, _, _),
    findall(G, movie_genre(ID, G), Genres),
    findall(A, cast(ID, A, _), Cast),
    (director(ID, Director) -> true ; Director = 'Unknown'),
    findall(K, keyword(ID, K), Keywords).