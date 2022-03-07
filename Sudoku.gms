*=============================================================================
* File      : Sudoku.gms
* Author    : auke.greijdanus@gmail.com
* Date      : 20-2-2022 22:09:02
* Remarks   : Sudoku solver using backtracking
*=============================================================================
$eolcom //

sets
s /1*81/
i /1*9/
j /1*9/
t /1*9/
link(s,i,j)
;

table sudoku(i,j)
  1 2 3 4 5 6 7 8 9
1     6 3   7
2     4           5
3 1         6   8 2
4 2   5   3   1   6
5       2     3
6 9       7       4
7   5
8   1
9     8 1   9   4
;

parameters
open(s,i,j)
squareNumber(i,j)
count /1/
tried(s,t)
nextTry
curBlock(s);

scalars
curS /1/
solved /0/;

loop((i,j),
squareNumber(i,j) = count; count = count+1;                           // Link square i,j to square number
);

open(s,i,j)${not sudoku(i,j) and ord(s)=squareNumber(i,j)} = ord(s);  // List of open squares

loop(s,                                                               // Construct set of dependent squares relative to current square
 loop(j$sum(i,ord(s)=squareNumber(i,j)), link(s,i,j) = yes;);         // Link relevant columns to current square
 loop(i$sum(j,ord(s)=squareNumber(i,j)), link(s,i,j) = yes;);         // Link relevant rows to current square
 curBlock(s) = sum((i,j),[ceil(ord(i)/3)**2 * ceil(ord(j)/3)]${ord(s)=squareNumber(i,j)});                    // Get current (unique) block value
 link(s,i,j)${[ceil(ord(i)/3)**2 * ceil(ord(j)/3)]${ceil(ord(i)/3)**2 * ceil(ord(j)/3) = curBlock(s)}}=yes;   // Link relevant block to current square
);


count = 0
while(curS < 82,                                                      // If 81th square is filled then sudoku is solved
 loop(s${ord(s)=curS and sum((i,j),open(s,i,j))},                     // Loop over open squares
  loop((t,i,j),
   if(ord(t) = sudoku(i,j)$link(s,i,j), tried(s,t) = ord(t));         // Construct unique list of given and tried numbers relevant for current square
  );

  nextTry=smin(t${ord(t)-tried(s,t)},ord(t)-tried(s,t));              // Pick lowest value of possible candidates (ord(t) [1-9], minus tried), is +Inf in case ord(t)-tried = 0. To do: also solve with smax to check for another solution (currently not working)
  tried(s,t)${ord(t) = nextTry} = nextTry;                            // Add candidate to tried list
  if(sum(t,tried(s,t)) = 45, tried(s,t) = 0);                         // If no more candidates for current square, empty tried list
  if(nextTry <= 9, sudoku(i,j)$open(s,i,j) = nextTry);                // If nextTry number is valid, insert it in sudoku table
  );

 curS = curS+1;                                                       // Increment S

 if(nextTry > 9,                                                      // If there is no candidate (nextTry = +Inf value):
 curS = smax(s$sum(t,tried(s,t)),ord(s));                             // Go back to last square with candidate(s)
 sudoku(i,j)$sum(s${ord(s)>=curS},open(s,i,j)) = 0;                   // Reset tried numbers from last cell with candidate(s)
 );

 count = count +1
 if(count = 100000, break)                                            // Prevent from eternal looping in case sudoku is not valid
);

option sudoku:0
if(count = 100000, display "No solution exists"; else display sudoku);
*============================   End Of File   ================================
