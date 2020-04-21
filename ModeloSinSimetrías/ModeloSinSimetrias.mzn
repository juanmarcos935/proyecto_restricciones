include "globals.mzn";

% Inicio Entrada Dada para el Problema 

enum ACTORES;
array[int, int] of int: Escenas; 
array[int] of int: Duracion;

% Fin Entrada Dada para el Problema

int: rows = length(ACTORES);
int: cols = length(Duracion) + 1;
int: number_of_scenes = length(Duracion);

array[1..rows, 1..number_of_scenes] of 0..1: Escenas_Solamente = array2d(1..rows, 1..number_of_scenes, [Escenas[i,j] | i in 1..rows, j in 1..number_of_scenes]);

array[1..rows] of int: Costos = [Escenas[i, cols] | i in 1..rows];

array[1..number_of_scenes] of var 1..number_of_scenes: x;
constraint alldifferent(x);

array[1..number_of_scenes] of var int: Duracion_Var = [Duracion[x[i]] | i in 1..number_of_scenes];

array[1..rows, 1..number_of_scenes] of var 0..1: Escenas_Solamente_Var = array2d(1..rows, 1..number_of_scenes, [Escenas[i,x[j]] | i in 1..rows, j in 1..number_of_scenes]);

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
  [sum([duration[j] | j in set_times[i] where j > 0]) | i in 1..rows ];

var set of int: set1 = getSetOfOne([Escenas_Solamente_Var[1,j] | j in 1..number_of_scenes]);

array[int] of var set of int: arr1 = getSetsOfOnes(Escenas_Solamente_Var);

array[int] of var int: arr2 = getTotalTimes(arr1, Duracion_Var);

var int: f = sum([arr2[i] * Costos[i] | i in 1..rows]);

solve minimize f;

output [show2d(Escenas_Solamente) ++ "\(x)\n" ++ show2d(Escenas_Solamente_Var)] ++ ["\(arr1)\n\(Duracion_Var)\n\(arr2)\n\(Costos)\n\(f)"];