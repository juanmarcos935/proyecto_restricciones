include "globals.mzn";

% Inicio Entrada Dada para el Problema 

enum ACTORES = {Actor1, Actor2, Actor3};

int: number_of_scenes = 6;
int: rows = length(ACTORES);
int: cols = number_of_scenes + 1;

array[1..rows, 1..cols] of int: Escenas = [|0,1,0,0,0,0,10
                                           |0,1,1,1,0,1,20
                                           |0,0,0,0,1,1,15|]; 
           
array[1..number_of_scenes] of int: Duracion = [2,1,1,1,3,4];

array[1..rows, 1..number_of_scenes] of 0..1: Escenas_Solamente = array2d(1..rows, 1..number_of_scenes, [Escenas[i,j] | i in 1..rows, j in 1..number_of_scenes]);

% Fin Entrada Dada para el Problema

array[1..number_of_scenes] of var 1..number_of_scenes: x;
constraint alldifferent(x);
constraint increasing(x);

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



output [show2d(Escenas_Solamente) ++ "\(x)\n" ++ show2d(Escenas_Solamente_Var)];