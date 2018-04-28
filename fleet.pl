createFleet(Fleet,GameMode):-
    ('b'==GameMode->
        write('Please place your fleet.'),nl,
        write('Place mode: Manually(a) or Randomly(b)'),nl,
        read(PlaceMode),
        ('a'==PlaceMode->
            write('Place your Carrier (size 5)'),nl,
            placeShip([],TmpFleet1,5),
            write('My fleet:'),nl,
            printFleet(TmpFleet1),
            write('Place your Battleship (size 4)'),nl,
            placeShip(TmpFleet1,TmpFleet2,4),
            write('My fleet:'),nl,
            printFleet(TmpFleet2),
            write('Place your Cruiser (size 3)'),nl,
            placeShip(TmpFleet2,TmpFleet3,3),
            write('My fleet:'),nl,
            printFleet(TmpFleet3),
            write('Place your Submarine (size 3)'),nl,
            placeShip(TmpFleet3,TmpFleet4,3),
            write('My fleet:'),nl,
            printFleet(TmpFleet4),
            write('Place your Destroyer (size 2)'),nl,
            placeShip(TmpFleet4,Fleet,2),
            write('My fleet:'),nl,
            printFleet(Fleet)
        ;'b'=PlaceMode->
            randomPlace(Fleet),
            write('My fleet:'),nl,
            printFleet(Fleet)
        ;
            write('Unknown place mode'),nl,
            createFleet(Fleet)
        )
    ;'a'==GameMode->
        randomPlace(Fleet)
    ).

placeShip(Fleet,NewFleet,N):-
    write('Horizontally(h) or Vertically(v)'),nl,
    read(Mode),
    (('h'==Mode;'v'==Mode)->
        write('Place at [X,Y]:'),nl,
        read(Input),
        checkPlace(Input,Mode,N,ValidInput),
        generateShipCoords(ShipCoords,ValidInput,Mode,N),
        (checkConflict(Fleet,ShipCoords)->
            Ship={ShipCoords,[]},
            NewFleet=[Ship|Fleet]
        ;   
            write('The ships cannot overlap, please retry'),nl,
            placeShip(Fleet,NewFleet,N)
        )
    ;
        write('Unknown direciton'),nl,
        placeShip(Fleet,NewFleet,N)
    ).

validPlace([X,Y],Mode,N):-
    number(X),number(Y),
    X>0,Y>0,Boundary#=12-N,
    ('h'==Mode->
        X<Boundary,
        Y<11
    ;'v'==Mode->
        X<11,
        Y<Boundary
    ).

checkPlace(Input,Mode,N,Valid):-
    validPlace(Input,Mode,N),
    Valid=Input.
checkPlace(Input,Mode,N,Valid):-
    \+validPlace(Input,Mode,N),
    Boundary#=11-N,
    ('h'=Mode->
        write('Please place at [X,Y], X is 1 to '),
        write(Boundary),write(' and Y is 1 to 10.'),nl
    ;
        write('Please place at [X,Y], X is 1 to 10 and Y is 1 to '),
        write(Boundary),write('.'),nl
    ),
    read(NewInput),
    checkPlace(NewInput,Mode,N,Valid).

checkConflict([],_).
checkConflict([Ship|Ships],GeneratedCoords):-
    {ShipCoords, _HitPoint} = Ship,
    conflictFree(ShipCoords,GeneratedCoords),
    checkConflict(Ships,GeneratedCoords).

conflictFree(_,[]).
conflictFree(ShipCoords,[GeneratedCoord|Coords]):-
    \+member(GeneratedCoord,ShipCoords),
    conflictFree(ShipCoords,Coords).

generateShipCoords(ShipCoords,Input,Mode,N):-
    ('h'=Mode->
        horizontalCoords(ShipCoords,Input,N)
    ;
        verticalCoords(ShipCoords,Input,N)
    ).

horizontalCoords([],_Input,0).
horizontalCoords([[NewX,NewY]|Coords],[X,Y],N):-
    N>0,NewN#=N-1,
    NewX#=X-2+N,
    NewY#=Y-1,
    horizontalCoords(Coords,[X,Y],NewN).

verticalCoords([],_Input,0).
verticalCoords([[NewX,NewY]|Coords],[X,Y],N):-
    N>0,NewN#=N-1,
    NewX#=X-1,
    NewY#=Y-2+N,
    verticalCoords(Coords,[X,Y],NewN).

randomPlace(Fleet):-
    randomPlaceShip([],TmpFleet1,5),
    randomPlaceShip(TmpFleet1,TmpFleet2,4),
    randomPlaceShip(TmpFleet2,TmpFleet3,3),
    randomPlaceShip(TmpFleet3,TmpFleet4,3),
    randomPlaceShip(TmpFleet4,Fleet,2).

randomPlaceShip(Fleet,NewFleet,N):-
    random(0,2,Mode),
    Boundary#=12-N,
    (0==Mode->
        Direction='h',%horizontal
        random(1,Boundary,X),
        random(1,11,Y)
    ;
        Direction='v',%vertical
        random(1,11,X),
        random(1,Boundary,Y)
    ),
    generateShipCoords(ShipCoords,[X,Y],Direction,N),
    (checkConflict2(Fleet,ShipCoords)->
        Ship={ShipCoords,[]},
        NewFleet=[Ship|Fleet]
    ;
        randomPlaceShip(Fleet,NewFleet,N)
    ).

checkConflict2([],_).
checkConflict2([Ship|Ships],GeneratedCoords):-
    {ShipCoords, _HitPoint} = Ship,
    conflictFree(ShipCoords,GeneratedCoords),
    checkConflict2(Ships,GeneratedCoords).