

generic

   type Key_Type is private;
   type Value_Type is private;
   Max_Length : in Natural;
   with function "=" (K1, K2: Key_Type) return Boolean;

package Maps_G is

   type Map is limited private;


    --Get: Dada la tabla de simbolos y la clave, busca la clave en la TS y devuelve el valor.
   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;--Out
                  Success : out Boolean);--Out Si lo encutra True y si no la encuentra mete False.


   Full_Map : exception; -- Se utiliza en put.

    --Put: Recibe la Tabla. In
       -- * out porq la puede modificar.
    -- Si encuentra una Clave que ya existe, se cambia el valor de la clave.
    -- Si la clave no está, se introduce una nueva clave con su nuevo valor.
    -- Aunque tengamos una version dinamica, tiene un tamaño máximo.
    -- Cuando se alcanza el maximo de capacidad e intentamos introducir uno nuevo,
            --salta la excepcion Full_Map.


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);


    -- Delete: Si encuentro la clave se carga toda la entrada: Clave y Valor.
        --Si lo encuentra : True
        --Si no lo encuentra : False


   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;
        --El numero de entradas de la TS. (Numero de clientes.)

   --
   -- Cursor Interface for iterating over Map elements
   --
   type Cursor is limited private;
   function First (M: Map) return Cursor; -- Dada una TS te devuelve el primer cursor. Inicializa un cursor
                                          -- en la tabla de simbolos.
   procedure Next (C: in out Cursor);     -- Avanza el cursor. Lo avanza a la siguiente. Si esta en null no se puede avanzar.
   function Has_Element (C: Cursor) return Boolean; -- Tiene elemento ?  Se le pasa un cursor y devuelve si en el cursor
                                                                         -- esta apuntando a null o no.
   type Element_Type is record --
      Key:   Key_Type;
      Value: Value_Type;
   end record;
   No_Element: exception;

   -- Raises No_Element if Has_Element(C) = False;
   function Element (C: Cursor) return Element_Type; -- Devuelve algo del tipo Element Type.

private

   type Cell is record
      Key   : Key_Type;
      Value : Value_Type;
      Full : Boolean := False;
   end record;

   type Cell_Array is array (1..Max_Length) of Cell;
   type Cell_Array_A is access Cell_Array;

   type Map is record
       P_Array: Cell_Array_A := new Cell_Array;
       Length: Natural := 0;
   end record;

   type Cursor is record
       M: Map;
       E_Indice: Natural := 0; --Ahora se mueve por incide de array
   end record;

end Maps_G;
