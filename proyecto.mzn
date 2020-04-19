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

% Fin Entrada Dada para el Problema

array[1..number_of_scenes] of var 1..number_of_scenes: Array_Numeros_Escenas;
constraint alldifferent(Array_Numeros_Escenas);

array[1..rows, index_set(Array_Numeros_Escenas)] of var 0..1: Matriz_Var; % Matriz de decisión
array[1..rows] of var int: Costos_Var; % Costos de los actores

constraint forall(i in 1..rows, j in 1..cols-1) (Matriz_Var[i,j] = Escenas[i,j]); % Rellenamos matriz de decisión
constraint forall(i in 1..rows) (Costos_Var[i] = Escenas[i,cols]); % Obtenemos costos de los actores

function int: getIndexOfFirstOcurrence(int: num, 
                               array[int] of int: arr) = 
   min([if num = arr[i] then i else length(arr) endif | i in index_set(arr)]);
   
function int: getIndexOfLastOcurrence(int: num, 
                               array[int] of int: arr) = 
   max([if num = arr[i] then i else -length(arr) endif | i in index_set(arr)]);

function var int: getTotalTimeOfActorInSet(array[int] of int: actor_enrollment, array[int] of int: duration) =
   sum([duration[i] | i in getIndexOfFirstOcurrence(1, actor_enrollment)..getIndexOfLastOcurrence(1, actor_enrollment)]);

% function var int: costo_obra(array[int, int] of var int: matrix, array[int] of var int: cost) = 

array[int] of int: row1 = [Escenas[2,j] | j in 1..number_of_scenes];

var int: actor2 = getTotalTimeOfActorInSet(row1, Duracion);

output [show2d(Matriz_Var)] ++ ["Costos = \(Costos_Var) \nArray con numeros de escenas = \(Array_Numeros_Escenas)\n\(actor2)"];