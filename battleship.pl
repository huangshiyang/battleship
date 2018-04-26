:-include(shooting).
:-include(tool).
:-include(ai).
:-include(fleet).

start:-
    newOcean(10,10,InitialBoard),
    createState(InitialBoard,Human),
    createState(InitialBoard,AI),
    gameConfig({Human,AI}).

newOcean(0,_SiValuee,[]).
newOcean(N,SiValuee,[L|Ls]):-
    N>0,NewN#=N-1,
    oceanCreateLine(SiValuee,L),
    newOcean(NewN,SiValuee,Ls).

oceanCreateLine(0,[]).  
oceanCreateLine(N,[~|L]):-
    N>0,NewN#=N-1,
    oceanCreateLine(NewN,L).  

createState(InitialBoard,Player) :-
    %createFleet(Fleet),%TODO randomly or manually create fleet
    fleet(Fleet),
    Player={InitialBoard,0,Fleet}.

gameConfig({Human,AI}):-
    write('Play mode: AI vs AI (a), or Human vs AI (b)'),
    nl,
    read(Mode),
    (('a'==Mode;'b'==Mode)->
        gameLoop(Mode,{Human,AI},'YES')
    ;
        write('Unknown mode'),nl,
        gameConfig({Human,AI})
    ).

%q to quit
validInput(q).
validInput([X,Y]):-number(X),number(Y),X>0,Y>0,X<11,Y<11.

checkInput(_,Input,Valid):-
    \+validInput(Input),
    write('Please shoot at [X,Y], X and Y are 1 to 10.'),
    nl,
    read(NewInput),
    checkInput(_,NewInput,Valid).
checkInput(Board,Input,Valid):-
    validInput(Input),
    getPoint(Input,Board,Val),
    ('~'==Val->
        [InX,InY]=Input,
        X#=InX-1,
        Y#=InY-1,
        Valid=[X,Y]
    ;
        [X,Y]=Input,
        write('Already shot at ['),write(X),write(','),write(Y),
        write('], please select other coordinates.'),
        nl,
        read(NewInput),
        checkInput(Board,NewInput,Valid)
    ).

gameLoop("q"):-write('Goodbye!').
gameLoop(Mode,{Human,AI},'YES'):-
    {AIGameBoard,_AISunk,AIFleet}=AI,
    {HumanGameBoard,_HumanSunk,HumanFleet}=Human,%AI2
    %AI turn
    aiChoice(AIGameBoard,AIInput),
    
    shoot(AIInput,AI,{AINewBoard,AINewSunk,AINewFleet}),
    gameEnded(AINewSunk,AIFleet,AiWins),

    write('My Ocean:'),nl,
    printBoard(AINewBoard),nl,

    %Human turn or AI2 turn
    write('AIs Ocean: '),nl,
    printBoard(HumanGameBoard), nl,

    ('a'==Mode->
        %AI vs AI
        aiChoice(HumanGameBoard,AI2Input),
    
        shoot(AI2Input,Human,{HumanNewBoard,HumanNewSunk,HumanNewFleet}),
        gameEnded(HumanNewSunk,HumanFleet,Ai2Wins),
        decide2continue(AiWins,Ai2Wins,Continue),
        sleep(0.1),
        gameLoop(Mode,{{HumanNewBoard,HumanNewSunk,HumanNewFleet},{AINewBoard,AINewSunk,AINewFleet}},Continue)
        ;'b'==Mode->
        %Human
        write('Shoot at [X,Y]:'),nl,
        read(Input),
        checkInput(HumanGameBoard,Input,ValidInput),
        (q==ValidInput->
            gameLoop("q")
        ;
            nl,
            [X,Y]=ValidInput,
            shoot([X,Y],Human,{HumanNewBoard,HumanNewSunk,HumanNewFleet}),
            gameEnded(HumanNewSunk,HumanFleet,HumanWins),
            decide2continue(AiWins,HumanWins,Continue),
            gameLoop(Mode,{{HumanNewBoard,HumanNewSunk,HumanNewFleet},{AINewBoard,AINewSunk,AINewFleet}},Continue)
        )
    ).

%end game
gameLoop(_Mode,{Human,AI},'NO'):-
    {AIBoard,AISunk,_}=AI,
    {HumanBoard,HumanSunk,_}=Human,
    write('Game ended'),nl,
    write('=========='),nl,
    write('My Ocean:'),nl,
    printBoard(AIBoard),nl,
    write('AIs Ocean:'),nl,
    printBoard(HumanBoard),nl,
    (AISunk>HumanSunk->
        write('You lose'),nl
    ;
        write('You win'),nl
    ),
    gameLoop("q").

gameEnded(Sunk,Fleet,Response):-
    length(Fleet,CountFleet),
    Sunk==CountFleet,
    Response='YES'.
gameEnded(Sunk,Fleet,Response):-
    length(Fleet,CountFleet),
    Sunk\=CountFleet,
    Response='NO'.

decide2continue('YES',_,'NO').
decide2continue(_,'YES','NO').
decide2continue('NO','NO','YES').

printBoard([]):-nl.
printBoard([Line|Lines]):-
    printLine(Line),
    printBoard(Lines).

printLine([]):-nl.
printLine([Char|Chars]):-
    write(Char),
    printLine(Chars).