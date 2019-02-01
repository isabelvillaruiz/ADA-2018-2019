--client_collections.adb


with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Maps;
with Ada.Unchecked_Deallocation;



package Client_Collections is

    package ASU renames Ada.Strings.Unbounded;
    package LLU renames Lower_Layer_UDP;
    package ATIO renames Ada.Text_IO;

    use type LLU.End_Point_Type;


--Desde fuera, solo podremos declarar variables del tipo qe aparezcan en el private.
--Solo podemos declararnos variables del tipo principal del nombre es decir
--Del tipo Collection_Type.

type Collection_Type is limited private;
Client_Collection_Error: exception;


procedure Add_Client (Collection: in out Collection_Type;
    EP: in LLU.End_Point_Type;
    Nick: in ASU.Unbounded_String;
    Unique: in Boolean);

procedure Delete_Client (Collection: in out Collection_Type;
    Nick: in ASU.Unbounded_String);

function Search_Client (Collection: in Collection_Type;
    EP: in LLU.End_Point_Type)
return ASU.Unbounded_String;

procedure Send_To_All (Collection: in Collection_Type;
P_Buffer: access LLU.Buffer_Type);
--Se le pasa el puntero que apunta al buffer.


function Collection_Image (Collection: in Collection_Type)
return String;


private

    type Cell;
    type Cell_A is access Cell;

    type Cell is record
        Client_EP: LLU.End_Point_Type;
        Nick: ASU.Unbounded_String;
        Next: Cell_A;
    end record;

    type Collection_Type is record
        P_First: Cell_A;
        Total: Natural := 0;
    end record;

end Client_Collections;
