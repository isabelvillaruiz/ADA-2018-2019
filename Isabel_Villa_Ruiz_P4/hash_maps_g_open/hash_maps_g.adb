-- Debug
with Ada.Text_IO;

package body Hash_Maps_G is
	-- Debug
	package ATIO renames Ada.Text_IO;

	procedure Search_Indice(M: in Map;
		Key: in Key_Type;
		Indice: out Natural;
		Indice_Found: out Boolean;
		Deleted_Indice: out Natural;
		Deleted_Found: out Boolean;
		Empty_Indice: out Natural) is
		Hash_Indice: Natural;
		Finished: Boolean;
	begin
		--Para pasar de modular a natural XD
		Hash_Indice := Natural'Value(Hash_Range'Image(Hash(Key)));
		-- ATIO.Put_Line("Hash Indice: " & Natural'Image(Hash_Indice));

		--Buscamos el indice correspondiente al Key.
		Indice_Found := False;
		Deleted_Found := False;

		Finished := False;
		Indice := Hash_Indice;

		while Indice < MAP_M  and not Finished loop

			case M.P_Array(Indice).Status is
				when Used =>

					if M.P_Array(Indice).Key = Key then
						Indice_Found := True;
						Finished := True;
					end if;

				when Deleted =>

					if not Deleted_Found then
						Deleted_Indice := Indice;
						Deleted_Found := True;
					end if;

				when Empty =>

					Empty_Indice := Indice;
					Finished := True;

				end case;

			if not Finished then
				--NEXT
				if Indice = MAP_M - 1 then
					Indice := 0;
				else
					Indice := Indice + 1;
				end if;

				if Indice = Hash_Indice then
					Finished := True;
				end if;
			end if;
		end loop;
	end Search_Indice;

	-- Map
	procedure Get(M: in out Map;
		Key: in Key_Type;
		Value: out Value_Type;
		Success: out Boolean) is
		Indice: Natural;
		Deleted_Found: Boolean;
		Deleted_Indice: Natural;
		Empty_Indice: Natural;
	begin
		Search_Indice(M, Key, Indice, Success, Deleted_Indice, Deleted_Found, Empty_Indice);
		if Success then
			-- ATIO.Put_Line("Get Indice: " & Natural'Image(Indice));
			Value := M.P_Array(Indice).Value;

			if Deleted_Found then
				-- ATIO.Put_Line("Move from " & Natural'Image(From) & " to " & Natural'Image(To));
				M.P_Array(Deleted_Indice).Key := M.P_Array(Indice).Key;
				M.P_Array(Deleted_Indice).Value := M.P_Array(Indice).Value;
				M.P_Array(Deleted_Indice).Status := Used;

				M.P_Array(Indice).Status := Deleted;

			end if;
		end if;
	end Get;

	procedure Put(M: in out Map;
		Key: in Key_Type;
		Value: in Value_Type) is
		Indice: Natural;
		Indice_Found: Boolean;
		Deleted_Found: Boolean;
		Deleted_Indice: Natural;
		Empty_Indice: Natural;
	begin
		Search_Indice(M, Key, Indice, Indice_Found, Deleted_Indice, Deleted_Found, Empty_Indice);
		if Indice_Found then
			-- ATIO.Put_Line("Put Indice: " & Natural'Image(Indice));
			M.P_Array(Indice).Value := Value;

			if Deleted_Found then
				-- ATIO.Put_Line("Move from " & Natural'Image(From) & " to " & Natural'Image(To));
				M.P_Array(Deleted_Indice).Key := M.P_Array(Indice).Key;
				M.P_Array(Deleted_Indice).Value := M.P_Array(Indice).Value;
				M.P_Array(Deleted_Indice).Status := Used;

				M.P_Array(Indice).Status := Deleted;
			end if;
		else
			if M.Length < Max then
				if Deleted_Found then
					Empty_Indice := Deleted_Indice;
				end if;
				-- ATIO.Put_Line("Put Empty Indice: " & Natural'Image(Empty_Indice));
				M.P_Array(Empty_Indice).Key := Key;
				M.P_Array(Empty_Indice).Value := Value;
				M.P_Array(Empty_Indice).Status := Used;
				M.Length := M.Length + 1;
			else
				raise Full_Map;
			end if;
		end if;
	end Put;

	procedure Delete(M: in out Map;
		Key: in Key_Type;
		Success: out Boolean) is
		Indice: Natural;
		Deleted_Found: Boolean;
		Deleted_Indice: Natural := Natural'First;
		Empty_Indice: Natural;
	begin
		Search_Indice(M, Key, Indice, Success, Deleted_Indice, Deleted_Found, Empty_Indice);
		if Success then
			-- ATIO.Put_Line("Delete Indice: " & Natural'Image(Indice));

			M.P_Array(Indice).Status := Deleted;
			M.Length := M.Length - 1;
		end if;
	end Delete;

	function Map_Length(M: in Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	-- Cursor
	function First(M: in Map) return Cursor is
		C: Cursor;
		Found: Boolean;
		Finished: Boolean;
	begin
		-- M
		C.M := M;

		-- Element_I
		Found := False;

		Finished := False;
		C.Element_I := Natural'First;
		while not Finished and C.Element_I < MAP_M loop
			if M.P_Array(C.Element_I).Status = Used then
				Found := True;
				Finished := True;
			end if;

			if not Found then
				--NEXT
				if C.Element_I = MAP_M - 1 then
					C.Element_I := 0;
					C.Finished := True;
					Finished := True;
				else
					C.Element_I := C.Element_I + 1;
				end if;

			end if;
		end loop;

		return C;
	end First;

	procedure Next(C: in out Cursor) is
		Found: Boolean;
		Finished: Boolean;
	begin
		if Has_Element(C) then
			if C.Element_I = MAP_M - 1 then
				C.Finished := True;
			else
				Found := False;

				Finished := False;
				--NEXT
				if C.Element_I = MAP_M - 1 then
					C.Element_I := 0;
				else
					C.Element_I := C.Element_I + 1;
				end if;
				while not Finished and C.Element_I < MAP_M loop
					if C.M.P_Array(C.Element_I).Status = Used then
						Found := True;
						Finished := True;
					end if;

					if not Found then
						--NEXT
						if C.Element_I = MAP_M - 1 then
							C.Element_I := 0;
						else
							C.Element_I := C.Element_I + 1;
						end if;
						if C.Element_I = 0 then
							C.Finished := True;
							Finished := True;
						end if;
					end if;
				end loop;
			end if;
		end if;
	end Next;

	function Has_Element(C: in Cursor) return Boolean is
	begin
		return not C.Finished;
	end Has_Element;

	function Element(C: in Cursor) return Element_Type is
	begin
		if Has_Element(C) then
			return (Key => C.M.P_Array(C.Element_I).Key, Value => C.M.P_Array(C.Element_I).Value);
		else
			raise No_Element;
		end if;
	end Element;
end Hash_Maps_G;
