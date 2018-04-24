start:-newOcean(10,10,InitialBoard).

newOcean(0,Size,[]).
newOcean(N,Size,[L|Ls]):-
    N>0,NewN#=N-1,
    oceanCreateLine(Size,L),
    newOcean(NewN,Size,Ls).

oceanCreateLine(0,[]).  
oceanCreateLine(N,[~|L]):-
    N>0,NewN#=N-1,
    oceanCreateLine(NewN,L).  