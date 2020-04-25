include "globals.mzn";

% ---------------------------------- Beginning of Input Data for the Problem ---------------------------------- %

enum ACTORES;
array[int, int] of int: Escenas; 
array[int] of int: Duracion;

% ---------------------------------- End of Input Data for the Problem ---------------------------------- %

% ---------------------------------- Beginning of Solution to Problem ---------------------------------- %

int: rows = length(ACTORES); % rows: the number of rows of the Scenes matrix (provided by the number of Actors)
int: cols = length(Duracion) + 1; % cols: number of columns, the additional 1 indicates the column of Costs of the Actors
int: number_of_scenes = length(Duracion); % number_of_scenes: the real number of scenes (it is the number of columns minus 1, because we don't take the column of Costs of the Actors), int: number_of_scenes = cols - 1;

array[1..number_of_scenes] of var 1..number_of_scenes: initial_sequence_scenes; % Only for showing in output
constraint alldifferent(initial_sequence_scenes); % Only for showing in output (temporary)
constraint increasing(initial_sequence_scenes); % Original sequence of scenes given in input

array[1..rows, 1..number_of_scenes] of 0..1: only_scenes_initial = array2d(1..rows, 1..number_of_scenes, [Escenas[i,j] | i in 1..rows, j in 1..number_of_scenes]); % Initial Scenes (without Cost's column) given in Input

array[1..rows] of int: individual_costs = [Escenas[i, cols] | i in 1..rows];

% This array is very important, it is the decision variables array: scenes_variable_order. Thanks to this array we can move and variate the order of the scenes, and Solver can find the matrix that feases the constraints and the objective function of minimizing cost

array[1..number_of_scenes] of var 1..number_of_scenes: scenes_variable_order;
constraint alldifferent(scenes_variable_order); % Trivial Constraint that all scenes must be different

array[1..number_of_scenes] of var int: variable_duration = [Duracion[scenes_variable_order[i]] | i in 1..number_of_scenes]; % This array of duration variates in function of the scenes variable order array. Probably useful in output

array[1..rows, 1..number_of_scenes] of var 0..1: only_scenes_decision_variable = array2d(1..rows, 1..number_of_scenes, [Escenas[i,scenes_variable_order[j]] | i in 1..rows, j in 1..number_of_scenes]); % This is where the magic begins, because this is the variable decision matrix and it moves and swaps columns in function of the scenes variable order array.

function var int: getIndexOfFirstOcurrence(int: num, 
                               array[int] of var int: arr) = 
   min([if num = arr[i] then i else length(arr) endif | i in index_set(arr)]);
% This function gets the position of the first ocurrence of an specific element in an array, for example, given element 1 and array [0, 0, 1, 0, 1, 1], it returns 3

function var int: getIndexOfLastOcurrence(int: num, 
                               array[int] of var int: arr) = 
   max([if num = arr[i] then i else -length(arr) endif | i in index_set(arr)]);
% This function gets the position of the last ocurrence of an specific element in an array, for example, given element 1 and array [0, 0, 1, 0, 1, 1], it returns 6

function var set of int: getSetOfOne(array[int] of var int: arr) =
     getIndexOfFirstOcurrence(1, arr)..getIndexOfLastOcurrence(1, arr);
% Using the above 2 functions, this function gets the interval (in set notation) of one Actor (given his participation in essay array), for example, given array [0, 0, 1, 0, 1, 1] it returns 3..6

function array[int] of var set of int: getSetsOfOnes(array[int, int] of var int: matrix) =
  [getSetOfOne([matrix[i,j] | j in 1..number_of_scenes]) | i in 1..rows];
% Using above function, returns an array that has all intervals for all actors, given the matrix of 0s and 1s that models the scene ordering. For example, for Trivial1.dzn, it returns [1..1, 2..6, 5..6] (for the Matrix given in input)

function array[int] of var int: getTotalTimes(array[int] of var set of int: set_times, array[int] of var int: duration) =
  [sum([duration[j] | j in set_times[i] where j > 0]) | i in 1..rows];
% This function returns the array that has all the total times staying in set of each actor. This allows to model the function to minimize: the cost, which is total time of actor in set multiplied by individual cost of each actor.

array[int] of var set of int: array_of_intervals_of_each_actor_in_set = getSetsOfOnes(only_scenes_decision_variable);
% This part gets the intervals of the decision variable matrix: the matrix that moves in function of the variable decision array of the scenes order.

array[int] of var int: total_time_in_set_for_each_actor = getTotalTimes(array_of_intervals_of_each_actor_in_set, variable_duration);
% This gets the total time of each actor in function of the intervals obtained by the decision variable matrix.

var int: f = sum([total_time_in_set_for_each_actor[i] * individual_costs[i] | i in 1..rows]);
% This is the objective function to minimize

solve minimize f;
% Minimize objective function

% ---------------------------------- Ending of Solution to Problem ---------------------------------- %

% ---------------------------------- Beginning of Breaking-Symmetry Constraints ---------------------------------- %

constraint forall(i in 1..number_of_scenes-1) (if [only_scenes_decision_variable[j,i] | j in 1..rows] = [only_scenes_decision_variable[j,i+1] | j in 1..rows] then scenes_variable_order[i] < scenes_variable_order[i+1] endif); % Possible Breaking Symmetry: if column[i] is equal to column[i+1] then we got 2 symmetric solutions: 
% the one that appears scene_variables_order[i] first than scene_variables_order[i+1] and the other one that has scene_variables_order[i+1] appearing first than appears scene_variables_order[i]
% We can break this symmetry by preserving the one solution that has scene_variables_order[i] first than scene_variables_order[i+1], imposing an order scene_variables_order[i] < scene_variables_order[i+1]

constraint forall(i in 1..number_of_scenes-1, j in i+1..number_of_scenes) (if [only_scenes_decision_variable[k,i] | k in 1..rows] = [only_scenes_decision_variable[k,j] | k in 1..rows] then scenes_variable_order[i] < scenes_variable_order[j] endif); % Possible Breaking Symmetry: if some column[i] is equal to some column[j] (where j > i), then we
% only preserve the solution where scene_variables_order[i] < scene_variables_order[j]

function int: getNumberOfZeroColumnsInMatrix(array[int,int] of int: arr, int: n_scenes, int: n_rows) = 
  sum([if [arr[j,i] | j in 1..n_rows] = [0 | j in 1..n_rows] then 1 else 0 endif| i in 1..n_scenes]);

int: number_of_zero_columns = getNumberOfZeroColumnsInMatrix(only_scenes_initial, number_of_scenes, rows);

function array[1..number_of_zero_columns] of int: getWhichColumnsAreZeroColumns(array[int,int] of int: arr, int: n_scenes, int: n_rows) =
  [i | i in 1..n_scenes where [arr[j,i] | j in 1..n_rows] = [0 | j in 1..n_rows]];

array[1..number_of_zero_columns] of int: array_of_zero_columns = getWhichColumnsAreZeroColumns(only_scenes_initial, number_of_scenes, rows);

constraint forall(i in 1..number_of_zero_columns) (scenes_variable_order[i] = array_of_zero_columns[i]); % This constraint models that if there is 1 or more than 1 "zero columns" (columns that are all zeros) they will be placed at the beginning of the scheduling, so the solver can ignore all the solutions where he puts the "zero columns" at the end.

% ---------------------------------- Ending of Breaking-Symmetry Constraints ---------------------------------- %

% ---------------------------------- Beginning of Output ---------------------------------- %

%output ["/////////////////////////////////////////////////// \n" ++ "Matriz y Orden de Escenas original (provisto en la Entrada): \n" ++ "  \(initial_sequence_scenes)\n" ++ show2d(only_scenes_initial) ++ "/////////////////////////////////////////////////// \n" ++ "Matriz y Orden de Escenas óptimo: \n" ++ "  \(scenes_variable_order)\n" ++ show2d(only_scenes_decision_variable)] ++ ["\(array_of_intervals_of_each_actor_in_set\n\(variable_duration)\n\(total_time_in_set_for_each_actor)\n\(individual_costs)\n\(f)\n\(number_of_zero_columns)\n\(array_of_zero_columns)"];

output ["Solución: \nOrden de las Escenas: \(scenes_variable_order)\nCosto: \(f)"];

% ---------------------------------- Ending of Output ---------------------------------- %