:-include(tool).
:-include(shooting).
:-include(ai).
:-include(fleet).

start:-
    newOcean(10,10,InitialBoard),
    gameModeConfig(GameMode),
    createState(InitialBoard,Human,GameMode),
    createState(InitialBoard,AI,'a'),
    debugConfig(GameMode,{Human,AI}).

newOcean(0,_Size,[]).
newOcean(N,Size,[L|Ls]):-
    N>0,NewN#=N-1,
    oceanCreateLine(Size,L),
    newOcean(NewN,Size,Ls).

oceanCreateLine(0,[]).  
oceanCreateLine(N,['□'|L]):-%'□' for ocean
    N>0,NewN#=N-1,
    oceanCreateLine(NewN,L).  

gameModeConfig(GameMode):-
    write('Play mode: AI vs AI (a), or Human vs AI (b)'),nl,
    read(GameMode),
    (('a'==GameMode;'b'==GameMode)->
        nl
    ;
        write('Unknown mode'),nl,
        gameModeConfig(GameMode)
    ).

createState(InitialBoard,Player,GameMode) :-
    createFleet(Fleet,GameMode),
    Player={InitialBoard,0,Fleet}.

debugConfig(GameMode,{Human,AI}):-
    write('Normal mode(a) or debug mode(b)'),nl,
    read(DebugMode),
    (('a'==DebugMode;'b'==DebugMode)->
        gameLoop(GameMode,DebugMode,{Human,AI},'YES')
    ;
        write('Unknown mode'),nl,
        debugConfig(GameMode,{Human,AI})
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
    ('□'==Val->%empty ocean
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
gameLoop(GameMode,DebugMode,{Human,AI},'YES'):-
    {AIGameBoard,_AISunk,AIFleet}=AI,
    {HumanGameBoard,_HumanSunk,HumanFleet}=Human,%AI2
    %AI turn
    aiChoice(AIGameBoard,AIInput),
    
    shoot(AIInput,{AIGameBoard,_AISunk,HumanFleet},{AINewBoard,AINewSunk,HumanNewFleet}),
    gameEnded(AINewSunk,HumanNewFleet,AiWins),
    ('YES'==AiWins->
        gameLoop("q")
        ;
        nl
    ),

    write('My fleet:'),nl,
    printFleet(HumanNewFleet),
    write('My Ocean:'),nl,
    printBoard(AINewBoard),nl,

    %Human turn or AI2 turn
    ('b'==DebugMode->
        write('Enemy fleet:'),nl,
        printFleet(AIFleet)
    ),
    write('Enemy Ocean: '),nl,
    printBoard(HumanGameBoard), nl,

    ('a'==GameMode->
        %AI vs AI
        aiChoice(HumanGameBoard,AI2Input),
    
        shoot(AI2Input,{HumanGameBoard,_HumanSunk,AIFleet},{HumanNewBoard,HumanNewSunk,AINewFleet}),
        gameEnded(HumanNewSunk,AINewFleet,Ai2Wins),
        decide2continue(AiWins,Ai2Wins,Continue),
        sleep(0.01),
        gameLoop(GameMode,DebugMode,{{HumanNewBoard,HumanNewSunk,HumanNewFleet},{AINewBoard,AINewSunk,AINewFleet}},Continue)
        ;'b'==GameMode->
        %Human
        write('Shoot at [X,Y]:'),nl,
        read(Input),
        checkInput(HumanGameBoard,Input,ValidInput),
        (q==ValidInput->
            gameLoop("q")
        ;
            nl,
            [X,Y]=ValidInput,
            shoot([X,Y],{HumanGameBoard,_HumanSunk,AIFleet},{HumanNewBoard,HumanNewSunk,AINewFleet}),
            gameEnded(HumanNewSunk,AINewFleet,HumanWins),
            decide2continue(AiWins,HumanWins,Continue),
            gameLoop(GameMode,DebugMode,{{HumanNewBoard,HumanNewSunk,HumanNewFleet},{AINewBoard,AINewSunk,AINewFleet}},Continue)
        )
    ).

%end game
gameLoop(_Mode,_DebugMode,{Human,AI},'NO'):-
    {AIBoard,AISunk,AIFleet}=AI,
    {HumanBoard,HumanSunk,HumanFleet}=Human,
    write('Game ended'),nl,
    write('=========='),nl,
    write('My fleet:'),nl,
    printFleet(HumanFleet),
    write('My Ocean:'),nl,
    printBoard(AIBoard),nl,
    write('Enemy fleet:'),nl,
    printFleet(AIFleet),
    write('Enemy Ocean:'),nl,
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