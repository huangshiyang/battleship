% get the point [X,Y] value on the board
getPoint([X,Y],Board,Val):-
    nth(Y,Board,RowList),
    nth(X,RowList,Val).

printFleet([]):-nl.
printFleet([Ship|Ships]):-
    printShip(Ship),
    printFleet(Ships).

printShip({[],_}):-nl.
printShip({[[X,Y]|Coords],_}):-
    NewX#=X+1,NewY#=Y+1,
    write('['),write(NewX),write(','),write(NewY),write('] '),
    printShip({Coords,_}).
    