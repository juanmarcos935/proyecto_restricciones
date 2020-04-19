include "globals.mzn"; 
int: num_rows;
int: num_cols;
array[1..num_rows, 1..num_cols] of int: data;

% decision variables
array[1..num_cols] of var 1..num_cols: x; 

solve satisfy;

constraint
  all_different(x)
  % /\ more constraints on x  ....
;

output [
    "data:\n",
    show2d(data) ++ "\n" ++ 
    "x: \(x)\n",
    "new_data:\n",
    show2d(array2d(1..num_rows, 1..num_cols, [data[i,x[j]] | i in 1..num_rows,j in 1..num_cols])) ++ "\n"
];

% data
num_rows = 3;
num_cols = 6;
data = array2d(1..num_rows,1..num_cols,
  [
  0,1,0,0,0,0,
  0,1,1,1,0,1,
  0,0,0,0,1,1
  ]);