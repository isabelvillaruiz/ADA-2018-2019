generic
	type Key_Type is private;
	type Value_Type is private;
	with function "="(K1, K2: Key_Type) return Boolean;
	type Hash_Range is mod <>;
	with function Hash(K: Key_Type) return Hash_Range;
	Max: in Natural;

package Hash_Maps_G is

	type Map is limited private;

	Full_Map: exception;

	procedure Get(M: in out Map;
		Key: in Key_Type;
		Value: out Value_Type;
		Success: out Boolean);

	procedure Put(M: in out Map;
		Key: in Key_Type;
		Value: in Value_Type);

	procedure Delete(M: in out Map;
		Key: in Key_Type;
		Success: out Boolean);

	function Map_Length(M: in Map) return Natural;

	--
	-- Cursor Interface for iterating over Map elements
	--
	type Cursor is limited private;

	function First(M: in Map) return Cursor;

	procedure Next(C: in out Cursor);

	function Has_Element(C: in Cursor) return Boolean;

	type Element_Type is record
		Key: Key_Type;
		Value: Value_Type;
	end record;

	No_Element: exception;
	-- Raises No_Element if Has_Element(C) = False;
	function Element(C: in Cursor) return Element_Type;


private

	-- Dyn_Dyn_List --Lista Enlazada con puntero al principio y final
		-- Facilitar Put.
	type Dyn_List_Cell;
	type Dyn_List_Cell_A is access Dyn_List_Cell;
	type Dyn_List_Cell is record
		Key: Key_Type;
		Value: Value_Type;
		Next: Dyn_List_Cell_A;
	end record;
	type Dyn_List is record
		P_First: Dyn_List_Cell_A;
		--P_Last: Dyn_List_Cell_A; -- Nota: Comentar
		--NO HACE FALTA LENGHT PORQ LO CUENTA EL MAP_ARRAY
	end record;

	-- Hash Map
	type Map_Array is array (Hash_Range) of Dyn_List;
	type Map_Array_A is access Map_Array;
	type Map is record
		P_Array: Map_Array_A := new Map_Array;
		Length: Natural := 0;
	end record;

	-- Cursor : Tiene que guardar:
	 		-- El Mapa creado.
			-- El indice de la posicion en la que está
			-- La lista dinamica de cada celda del map array

	type Cursor is record
		M: Map;
		Index: Hash_Range;
		Element_A: Dyn_List_Cell_A;
	end record;
end Hash_Maps_G;
