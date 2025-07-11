:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(rules).
:- [facts].  % load facts if needed

:- http_handler(root(query), handle_query, []).

start_server :-
    http_server(http_dispatch, [port(8080)]).

handle_query(Request) :-
    catch(
        (
            http_parameters(Request, [ask(QueryAtom, [atom])]),
            atom_to_term(QueryAtom, Query, _),
            run_query(Query, Result),
            reply_json(Result)
        ),
        Error,
        (
            format(user_error, 'Error handling query: ~w~n', [Error]),
            reply_json(_{error: 'Invalid query or execution error', details: Error}, [status(400)])
        )
    ).


run_query((query_movies(Conditions, ID), movie_details(ID, Title, Year, Genres, Cast, Director, Keywords)), Result) :-
    findall(
        _{id: ID, title: Title, year: Year, genres: Genres, cast: Cast, director: Director, keywords: Keywords},
        (
            query_movies(Conditions, ID),
            movie_details(ID, Title, Year, Genres, Cast, Director, Keywords)
        ),
        Result
    ).
