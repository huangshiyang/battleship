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

fleet(Fleet):-
    Ship1={
        [[3,2],[4,2],[5,2]],%Ship positions
        []%hit points
        },
    Ship2={
        [[4,4],[5,4],[6,4]],
        []
        },
    Fleet=[Ship1,Ship2].

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

shoot([X,Y],{Board,CountSunk,Fleet},{NewBoard,NewCounter,NewFleet}):-
    checkShoot([X,Y],Fleet,Result,NewFleet),
    ('h'==Result->
        updatePoint([X,Y],'h',Board,NewBoard),
        NewCounter=CountSunk
    ;
    's'==Result->
        getShipCoordinate([X,Y],Fleet,CoordinateList),
        updateSinkShip(CoordinateList,'s',Board,NewBoard),
        NewCounter#=CountSunk+1
    ).
shoot([X,Y],{Board,CountSunk,Fleet},{NewBoard,CountSunk,NewFleet}):-
    checkShoot([X,Y],Fleet,'m',NewFleet),
    updatePoint([X,Y],'m',Board,NewBoard).
checkShoot([X,Y],[Ship|Ships],Result,NewFleet):-
    (checkSink([X,Y],Ship,NewShip)->
        Result='s'
    ;
        checkHit([X,Y],Ship,NewShip),
        Result='h'
    ),
    NewFleet=[NewShip|Ships].
checkShoot([X,Y],[Ship|Ships],Result,NewFleet):-
    checkMiss([X,Y],Ship),
    checkShoot([X,Y],Ships,Result,Tmp),
    NewFleet=[Ship|Tmp].
checkShoot([_X,_Y],[],'m',[]).
checkHit([X,Y],Ship,NewShip):-
    {CoordinateList,HitList}=Ship,
    member([X,Y],CoordinateList),
    append(HitList,[[X,Y]],NewHitList),
    NewShip={CoordinateList,NewHitList}.
checkMiss([X,Y],Ship):-
    {CoordinateList,_HitList}=Ship,
    \+member([X,Y],CoordinateList).
checkSink([X,Y],Ship,NewShip):-
        {CoordinateList,HitList}=Ship,
        member([X,Y],CoordinateList),
        append(HitList,[[X,Y]],NewHitList),
        length(NewHitList,CountHit),
        length(CoordinateList,CountCoordinate),
        CountHit==CountCoordinate,
        NewShip={CoordinateList,NewHitList}.

% update the point [X,Y] on the board with 's','h','m'
updatePoint([X,Y],Result,Board,NewBoard):-
    replace(Board,Y,X,Result,NewBoard).
replace([L|Ls],0,Column,Value,[R|Ls]):-
    replaceColumn(L,Column,Value,R).
replace([L|Ls],Row,Column,Value,[L|Rs]):-
    Row>0,NewRow#=Row-1,
    replace(Ls,NewRow,Column,Value,Rs).
replaceColumn([_|Cs],0,Value,[Value|Cs]). 
replaceColumn([C|Cs],Column,Value,[C|Rs]):-
    Column>0,NewColumn#=Column-1,
    replaceColumn(Cs,NewColumn,Value,Rs).

% get the point [X,Y] value on the board
getPoint([X,Y],Board,Val):-
    nth(Y,Board,RowList),
    nth(X,RowList,Val).

%update all the points for the sink ship to 's'
updateSinkShip([P|Ps],Result,BoardIn,BoardOut):-
    [X,Y]=P,
    updatePoint([X,Y],Result,Board2,BoardOut),
    updateSinkShip(Ps,Result,BoardIn,Board2).
updateSinkShip([],_Result,Board,Board).

%get the coordinate list of the ship which contains [X,Y]
getShipCoordinate([_X,_Y],[],[]).
getShipCoordinate([X,Y],[Ship|_Ships],CoordinateList):-
    {CoordinateList,_}=Ship,
    member([X,Y],CoordinateList).
getShipCoordinate([X,Y],[Ship|Ships],CoordinateList2):-
    {CoordinateList1,_}=Ship,
    \+member([X,Y],CoordinateList1),
    getShipCoordinate([X,Y],Ships,CoordinateList2).

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