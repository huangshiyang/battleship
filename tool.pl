% get the point [X,Y] value on the board
getPoint([X,Y],Board,Val):-
    nth(Y,Board,RowList),
    nth(X,RowList,Val).