%shoot([X,Y],Player,UpdatedPlayer)
shoot([X,Y],{Board,CountSunk,Fleet},{NewBoard,NewCounter,NewFleet}):-
    checkShoot([X,Y],Fleet,Result,NewFleet),
    ('●'==Result->%hit
        updatePoint([X,Y],'●',Board,NewBoard),%hit
        NewCounter=CountSunk
    ;
    '★'==Result->%sink
        getShipCoordinate([X,Y],Fleet,CoordinateList),
        updateSinkShip(CoordinateList,'★',Board,NewBoard),%sink
        NewCounter#=CountSunk+1
    ).
shoot([X,Y],{Board,CountSunk,Fleet},{NewBoard,CountSunk,NewFleet}):-
    checkShoot([X,Y],Fleet,'■',NewFleet),%miss
    updatePoint([X,Y],'■',Board,NewBoard).%miss

%checkShoot([X,Y],Fleet,Result,NewFleet)
checkShoot([X,Y],[Ship|Ships],Result,NewFleet):-
    (checkSink([X,Y],Ship,NewShip)->
        Result='★'%sink
    ;
        checkHit([X,Y],Ship,NewShip),
        Result='●'%hit
    ),
    NewFleet=[NewShip|Ships].
checkShoot([X,Y],[Ship|Ships],Result,NewFleet):-
    checkMiss([X,Y],Ship),
    checkShoot([X,Y],Ships,Result,Tmp),
    NewFleet=[Ship|Tmp].
checkShoot([_X,_Y],[],'■',[]).%miss

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

%update the point [X,Y] on the board with sink(★),hit(●),miss(■)
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

%update all the points for the sunken ship to '★'
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