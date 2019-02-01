with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
--maps_g_dyn

package body Maps_G is


    --Tiene Key type, Value type, Max lenght, y "=" que ni idea de que es!

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
   P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;

--Modificar el Put para que haga lo que realmente necesito.
   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
      P_Aux : Cell_A;
      Found : Boolean;
      --P_Aux_Creador : Cell_A;
   begin
      -- Si ya existe Key, cambiamos su Value
      P_Aux := M.P_First;
      Found := False;

          while not Found and P_Aux /= null loop
             if P_Aux.Key = Key then
                P_Aux.Value := Value;
                Found := True;
             end if;
             P_Aux := P_Aux.Next;
          end loop;

      -- Si no hemos encontrado Key añadimos al principio
            if not Found then
                --Si mi numero actual es menor del maximo procedo a meter nuevo
                if M.Length < Max_Length then
                    M.P_First := new Cell'(Key, Value, M.P_First);
    				M.Length := M.Length + 1;
                    --Revisar si quiero que me lo añada por el principio o por el final.
                else
                    raise Full_Map;
                end if;
            end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
      P_Previous : Cell_A;
   begin
      Success := False;
      P_Previous := null;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            --Para borrar cualquier otro.
            if P_Previous /= null then
               P_Previous.Next := P_Current.Next;
            end if;
            --Para borrar el primero.
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
            end if;
            Free (P_Current);
         else
            --Avanzamos
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length; --Devuelve el Lenght del puntero y ya.
   end Map_Length;



   function First (M: Map) return Cursor is
   begin
      return (M => M, Element_A => M.P_First);
   end First;

--Otra manera:
--   function First (M: Map) return Cursor is
--    C : Cursor;
--   begin
--        C.M := M;
--        C.Element_A := M.P_First;
--        return C;
--   end First;

   procedure Next (C: in out Cursor) is
   begin
      if C.Element_A /= null Then
         C.Element_A := C.Element_A.Next;
      end if;
   end Next;

   function Element (C: Cursor) return Element_Type is
   begin
      if C.Element_A /= null then
         return (Key   => C.Element_A.Key,
                 Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;

   function Has_Element (C: Cursor) return Boolean is
   begin
      if C.Element_A /= null then
         return True;
      else
         return False;
      end if;
   end Has_Element;




end Maps_G;
