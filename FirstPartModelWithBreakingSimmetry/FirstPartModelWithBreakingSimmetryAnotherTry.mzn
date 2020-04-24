include "globals.mzn";

% Inicio Entrada Dada para el Problema 

enum ACTORES;
array[int, int] of int: Escenas; 
array[int] of int: Duracion;

% Fin Entrada Dada para el Problema

int: rows = length(ACTORES); % rows: el número de filas de la matriz de Escenas (exclusivamente escenas)
int: cols = length(Duracion) + 1; % cols: el número de columnas que hay, el +1 indica la columna de costos de cada Actor
int: number_of_scenes = length(Duracion); % number_of_scenes: el número real de escenas (intuitivamente es el número de columnas -1, debido a que se quita la columna de costos de cada actor

array[1..number_of_scenes] of var 1..number_of_scenes: initial_sequence_scenes;
constraint alldifferent(initial_sequence_scenes);
constraint increasing(initial_sequence_scenes);

array[1..rows, 1..number_of_scenes] of 0..1: only_scenes_initial = array2d(1..rows, 1..number_of_scenes, [Escenas[i,j] | i in 1..rows, j in 1..number_of_scenes]);

array[1..rows] of int: individual_costs = [Escenas[i, cols] | i in 1..rows];

% El array de variables de decisión scenes_variable_order

array[1..number_of_scenes] of var 1..number_of_scenes: scenes_variable_order;
constraint alldifferent(scenes_variable_order);


array[1..number_of_scenes] of var int: variable_duration = [Duracion[scenes_variable_order[i]] | i in 1..number_of_scenes];

array[1..rows, 1..number_of_scenes] of var 0..1: only_scenes_decision_variable = array2d(1..rows, 1..number_of_scenes, [Escenas[i,scenes_variable_order[j]] | i in 1..rows, j in 1..number_of_scenes]);

constraint forall(i in 1..number_of_scenes-1) (if [only_scenes_decision_variable[j,i] | j in 1..rows] = [only_scenes_decision_variable[j,i+1] | j in 1..rows] then scenes_variable_order[i] < scenes_variable_order[i+1] endif);

function var int: getIndexOfFirstOcurrence(int: num, 
                               array[int] of var int: arr) = 
   min([if num = arr[i] then i else length(arr) endif | i in index_set(arr)]);
   
function var int: getIndexOfLastOcurrence(int: num, 
                               array[int] of var int: arr) = 
   max([if num = arr[i] then i else -length(arr) endif | i in index_set(arr)]);
 
function var set of int: getSetOfOne(array[int] of var int: arr) =
     getIndexOfFirstOcurrence(1, arr)..getIndexOfLastOcurrence(1, arr);

function array[int] of var set of int: getSetsOfOnes(array[int, int] of var int: matrix) =
  [getSetOfOne([matrix[i,j] | j in 1..number_of_scenes]) | i in 1..rows];

function array[int] of var int: getTotalTimes(array[int] of var set of int: set_times, array[int] of var int: duration) =
  [sum([duration[j] | j in set_times[i] where j > 0]) | i in 1..rows];

% var set of int: set1 = getSetOfOne([only_scenes_decision_variable[1,j] | j in 1..number_of_scenes]);

array[int] of var set of int: arr1 = getSetsOfOnes(only_scenes_decision_variable);

array[int] of var int: arr2 = getTotalTimes(arr1, variable_duration);

var int: f = sum([arr2[i] * individual_costs[i] | i in 1..rows]);

solve minimize f;

array[int] of var 0..1: arraysito = [only_scenes_decision_variable[j,6] | j in 1..length(ACTORES)];

output ["/////////////////////////////////////////////////// \n" ++ "Matriz y Orden de Escenas original (provisto en la Entrada): \n" ++ "  \(initial_sequence_scenes)\n" ++ show2d(only_scenes_initial) ++ "/////////////////////////////////////////////////// \n" ++ "Matriz y Orden de Escenas óptimo: \n" ++ "  \(scenes_variable_order)\n" ++ show2d(only_scenes_decision_variable)] ++ ["\(arr1)\n\(variable_duration)\n\(arr2)\n\(individual_costs)\n\(f)\n\(arraysito)"];

%output ["Solución: \nOrden de las Escenas: \(scenes_variable_order)\nCosto: \(f)"];