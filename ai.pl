:-include(tool).

%TODO smart AI
% totally random.
aiChoice(Board,[RandX,RandY]):-
    random(1,11,X),
    random(1,11,Y),
    getPoint([X,Y],Board,Val),
    ('~'==Val->
        RandX#=X-1,
        RandY#=Y-1
    ;
        aiChoice(Board,[RandX,RandY])
    ).