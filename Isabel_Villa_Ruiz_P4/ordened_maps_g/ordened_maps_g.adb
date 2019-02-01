with Ada.Text_IO;

package body Ordened_Maps_G is

	procedure Binary_Search(M: in Map;
		Key: in Key_Type;
		Indice: out Positive;
		Found: out Boolean) is

		LFT: Natural;
		RGT: Natural;
		MID: Natural;
	begin

		LFT := 1;			-- posicion inicial del array
		RGT := M.Length;  -- largo del array
		Found := False;
		--El R siempre tendrá que ser mayor para que se cumpla la condicion de
			--busqueda.

		while LFT <= RGT and not Found  loop
			MID := (LFT + RGT) / 2;
			Found := Key = M.P_Array(MID).Key;
			if Found then
				--Si encontramos el array salimos
				Indice := MID;
			else
				if Key < M.P_Array(MID).Key then
					RGT := MID - 1;
				else
					LFT := MID + 1;
				end if;
			end if;
		end loop;

		if not Found then
			if M.Length /= 0 then
				if Key < M.P_Array(MID).Key then
					Indice := MID;
				else
					Indice := MID + 1;
				end if;
			else
				Indice := 1;
			end if;
		end if;
	end Binary_Search;

	procedure Get(M: in Map;
		Key: in Key_Type;
		Value: out Value_Type;
		Success : out Boolean) is

		Indice: Positive;
	begin
		Binary_Search(M, Key, Indice, Success);
		if Success = True then
			Value := M.P_Array(Indice).Value;
		end if;
	end Get;

	procedure Put(M: in out Map;
		Key: in Key_Type;
		Value: in Value_Type) is

		Indice: Positive;
		Found: Boolean;
	begin
		Binary_Search(M, Key, Indice, Found);
		if Found = True then
			M.P_Array(Indice).Value := Value;
			--Si lo encontramos, actualizamos su valor.
		else
			--En caso negativo, hacemos hueco a la nueva entrada
			if M.Length < Max then
				for I in reverse Indice..M.Length loop --Empexamos desde el final
					--Movemos todo uno a la "derecha" del array( hacia el fondo)
					M.P_Array(I + 1).Value := M.P_Array(I).Value;
					M.P_Array(I + 1).Key := M.P_Array(I).Key;
				end loop;
				--En el hueco liberado metemos nuestro nuevo valor y key
				M.P_Array(Indice).Key := Key;
				M.P_Array(Indice).Value := Value;
				M.Length := M.Length + 1;
			else
				--El array esta lleno!
				raise Full_Map;
			end if;
		end if;
	end Put;

	procedure Delete(M: in out Map;
		Key: in Key_Type;
		Success: out Boolean) is

		Indice: Positive;
	begin
		Binary_Search(M, Key, Indice, Success);
		if Success = True then
			for I in Indice..M.Length - 1 loop
				M.P_Array(I).Value := M.P_Array(I + 1).Value;
				M.P_Array(I).Key := M.P_Array(I + 1).Key;
			end loop;
			M.Length := M.Length - 1;
		end if;
	end Delete;

	function Map_Length(M: in Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	function First(M: in Map) return Cursor is
		C: Cursor;
	begin
		C.M := M;
		if M.Length /= 0 then
			C.Has_Element := True;
		end if;

		return C;
	end First;

	procedure Next(C: in out Cursor) is
	begin
		if Has_Element(C) then
			if C.Element_I < C.M.Length then
				C.Element_I := C.Element_I + 1;
			else
				C.Has_Element := False;
			end if;
		end if;
	end Next;

	function Has_Element(C: in Cursor) return Boolean is
	begin
		return C.Has_Element;
	end Has_Element;

	function Element(C: in Cursor) return Element_Type is
	begin
		if Has_Element(C) then
			return (Key => C.M.P_Array(C.Element_I).Key, Value => C.M.P_Array(C.Element_I).Value);
		else
			raise No_Element;
		end if;
	end Element;
end Ordened_Maps_G;
