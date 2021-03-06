with Ada.Unchecked_Deallocation;


with Ada.Text_IO;

package body Hash_Maps_G is

	package ATIO renames Ada.Text_IO;


	procedure Free is new Ada.Unchecked_Deallocation(Dyn_List_Cell, Dyn_List_Cell_A);


	-- Map
	procedure Get(M			: in out Map;
				  Key		: in Key_Type;
				  Value		: out Value_Type;
				  Success	: out Boolean) is

		Indice: Hash_Range;
		P_Aux: Dyn_List_Cell_A;

	begin
		Success := False;
		Indice := Hash(Key);
		--Ada.Text_IO.Put_Line("hola");
		P_Aux := M.P_Array(Indice).P_First;
		while not Success and P_Aux /= null loop
			if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;
	end Get;

	procedure Put(M			: in out Map;
				  Key		: in Key_Type;
				  Value		: in Value_Type) is

		Found: Boolean;
		Indice: Hash_Range;
		P_Aux: Dyn_List_Cell_A;
		--P_Aux_Creador: Dyn_List_Cell_A;
	begin

		Found := False;
		Indice := Hash(Key);
		--Ada.Text_IO.Put_Line("aqui");
		P_Aux := M.P_Array(Indice).P_First;

		while not Found and P_Aux /= null loop
			if P_Aux.Key = Key then
				P_Aux.Value := Value;
				Found := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;


		--RESOLUCION DE COLISIONES POR ENCADENAMIENTO:
			--Si hay un elemento en el incide que nos proporciona la funcion Hash:
				-- Se crea otra celda dentro de la lista dinamica de cada celda del array.

		if not Found then
			--Si mi numero actual es menor del maximo procedo a meter nuevo.
			if M.Length < Max then
				M.P_Array(Indice).P_First := new Dyn_List_Cell'(Key, Value, M.P_Array(Indice).P_First);
				--P_Aux_Creador := new Dyn_List_Cell'(Key, Value, null);
				--Comprobacion de si la lista estaba vacia. Es el primero o otro nuevo?

				--Actualizamos el nuevo "ultimo" de la lista
				--M.P_Array(Indice).P_Last := P_Aux_Creador;
				M.Length := M.Length + 1;
			else
				raise Full_Map;
			end if;
		end if;
	end Put;


	procedure Delete(M			: in out Map;
					 Key		: in Key_Type;
					 Success	: out Boolean) is

		P_Current: Dyn_List_Cell_A;
		P_Previous : Dyn_List_Cell_A;
		Indice: Hash_Range;

	begin

		Success := False;
		P_Previous := null;
		Indice := Hash(Key);
		P_Current := M.P_Array(Indice).P_First;


		while not Success and P_Current /= null loop
			if P_Current.Key = Key then
				Success := True;
				M.Length := M.Length - 1;

				--Cualquier otro
				if P_Previous /= null then
					P_Previous.Next := P_Current.Next;
				end if;

				--Para borrar el primero
				if M.P_Array(Indice).P_First = P_Current then
				   M.P_Array(Indice).P_First := M.P_Array(Indice).P_First.Next;
				end if;

				Free(P_Current);

			else
				--Avanzamos
				P_Previous := P_Current;
				P_Current := P_Current.Next;
			end if;
		end loop;
	end Delete;

	function Map_Length(M: in Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	-- Cursor
	function First(M: in Map) return Cursor is

		Found: Boolean := False;
		Indice: Hash_Range;
	begin
		Indice := Hash_Range'First;
		if M.Length /= 0 then
			--Inicializa el indice al primero del rango establecido 'First
			while not Found loop
				if M.P_Array(Indice).P_First /= null then
					Found := True;
				else
					Indice := Indice + 1;
				end if;
			end loop;
			return ( M => M , Index => Indice, Element_A => M.P_Array(Indice).P_first);
		else
			return ( M => M , Index => 0, Element_A => null);
		end if;
	end First;

	procedure Next(C: in out Cursor) is
		Found: Boolean;
		Indice: Hash_Range;
	begin
		if Has_Element(C) then
			C.Element_A := C.Element_A.Next;
			if C.Element_A = null then
				Found := False;
				Indice := C.Index + 1;
				if Indice /= Hash_Range'First then
					loop
						if C.M.P_Array(Indice).P_First /= null then
							Found := True;
							C.Index := Indice;
							C.Element_A := C.M.P_Array(Indice).P_First;
						end if;
						Indice := Indice + 1;
					exit when Found or Indice = Hash_Range'First;
					end loop;
				end if;

				if not Found then
				  C.Element_A := null; 
				end if;
			end if;
		end if;
	end Next;

	function Has_Element(C: in Cursor) return Boolean is
	begin
		if C.Element_A /= null then
           return True;
        else
           return False;
        end if;
	end Has_Element;

	function Element(C: in Cursor) return Element_Type is
	begin
		if C.Element_A /= null then
			return (Key => C.Element_A.Key,
			 		Value => C.Element_A.Value);
		else
			raise No_Element;
		end if;
	end Element;
end Hash_Maps_G;
