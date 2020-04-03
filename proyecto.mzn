enum ACTORES = {Actor1, Actor2, Actor3};

int: number_of_scenes = 6;
int: rows = length(ACTORES);
int: cols = number_of_scenes + 1;

array[1..rows, 1..cols] of int: Escenas = [|0,1,0,0,0,0,10
                                           |0,1,1,1,0,1,20
                                           |0,0,0,0,1,1,15|]; 
           
array[1..number_of_scenes] of int: Duracion = [2,1,1,1,3,4];

array[1..rows, 1..cols-1] of var 0..1: Matriz_Var;
array[1..rows] of var int: Costos_Var;

constraint forall(i in 1..rows, j in 1..cols-1) (Matriz_Var[i,j] = Escenas[i,j]);
constraint forall(i in 1..rows) (Costos_Var[i] = Escenas[i,cols]);

array[1..6] of int: arre = [0, 0, 0, 0, 1, 1];

function array[int] of int: getIndexOf(int: ent, 
                               array[int] of int: int_array) = 
     [ if ent = int_array[i] 
              then i
           else length(int_array)+1 endif  
          | i in index_set(int_array) ]
   ;

array[int] of int: n = getIndexOf(1, arre);

int: m = min(n);

output["\(Matriz_Var)\n\(Costos_Var)\n\(n)\n\(m)"];
