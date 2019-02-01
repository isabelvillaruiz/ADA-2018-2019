with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
--maps_g_array

package body Maps_G is


    --Tiene Key type, Value type, Max lenght, y "=" que ni idea de que es!

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is

    Indice: Positive;
    begin

        Indice := 1;
        Success := False;
        while not Success and Indice <= Max_Length Loop
            if M.P_Array(Indice).Full then
                if M.P_Array(Indice).Key = Key then
                    Value := M.P_Array(Indice).Value;
                    Success := True;
                end if;
            end if;
            Indice := Indice + 1;
        end loop;

    end Get;

--Modificar el Put para que haga lo que realmente necesito.
   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is

      Indice: Positive;
      Found : Boolean;
      Success : Boolean;

   begin
      -- Si ya existe Key, cambiamos su Value
      Indice := 1;
      Found := False;
      Success := False;

          while not Found and Indice <= Max_Length loop
              if M.P_Array(Indice).Full then
                  if M.P_Array(Indice).Key = Key then
                      M.P_Array(Indice).Value := Value;
                      Found := True;
                  end if;
             end if;
             Indice := Indice + 1;
          end loop;

      -- Si no hemos encontrado Key añadimos al principio
            if not Found then
                --Si mi numero actual es menor del maximo procedo a meter nuevo
                if M.Length < Max_Length then
                    Indice := 1;
                    while not Success and Indice <= Max_Length loop
                        if M.P_Array(Indice).Full = False then
                            --para poder accerder al espacio del indice en el array
                            M.P_Array(Indice).Key := Key;
    						M.P_Array(Indice).Value := Value;
    						M.P_Array(Indice).Full := True;
            				M.Length := M.Length + 1;
                            Success := True;
                        else
                            Indice := Indice + 1;
                        end if;
                    end loop;
                    --Revisar si quiero que me lo añada por el principio o por el final.
                else
                    raise Full_Map;
                end if;
            end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is

      Indice: Positive;
   begin

      Indice := 1;
      Success := False;

      while not Success and Indice <= Max_Length loop
         if M.P_Array(Indice).Key = Key then
            M.P_Array(Indice).Full := False;
            Success := True;
            M.Length := M.Length - 1;
         else
             Indice := Indice + 1;
         end if;
      end loop;

   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length; --Devuelve el Lenght del puntero y ya.
   end Map_Length;



   function First(M: Map) return Cursor is
       Found: Boolean := False;
       Indice: Positive;
   begin
       Indice := 1;
       if M.Length /= 0 then
           while not Found and Indice <= Max_Length loop
               if M.P_Array(Indice).Full = True then
                   Found := True;
               else
                   Indice := Indice + 1;
               end if;
           end loop;

           return (M => M, E_Indice => Indice);
       else
           return (M => M, E_Indice => 0); -- Si no lo encuentra manda 0;
       end if;
   end First;

    procedure Next(C: in out Cursor) is
        Found: Boolean;
    begin
        Found := False;

        if C.E_Indice /= 0 then
            C.E_Indice := C.E_Indice + 1;
            while not Found and C.E_Indice <= Max_Length loop
                if C.M.P_Array(C.E_Indice).Full = True then
                    Found := True;
                else
                    C.E_Indice := C.E_Indice + 1;
                end if;
            end loop;
            if not Found then
                C.E_Indice := 0; -- Final del array
            end if;
        end if;
    end Next;

    function Element(C: Cursor) return Element_Type is
    begin
        if C.E_Indice /= 0 then
            return (Key => C.M.P_Array(C.E_Indice).Key, Value => C.M.P_Array(C.E_Indice).Value);
        else
            raise No_Element;
        end if;
    end Element;



function Has_Element(C: Cursor) return Boolean is
begin
   return C.E_Indice /= 0;
end Has_Element;

end Maps_G;
