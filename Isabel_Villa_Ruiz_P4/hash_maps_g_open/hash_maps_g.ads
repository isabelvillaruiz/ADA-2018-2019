generic
	type Key_Type is private;
	type Value_Type is private;
	with function "="(K1, K2: Key_Type) return Boolean;
	type Hash_Range is mod <>;
	with function Hash(K: Key_Type) return Hash_Range;
	Max: in Natural;
package Hash_Maps_G is
	type Map is limited private;

	procedure Get(M: in out Map;
		Key: in Key_Type;
		Value: out Value_Type;
		Success: out Boolean);

	Full_Map: exception;
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
	MAP_M: constant Natural := Max + 20;

	-- Hash Map
	type Status_Type is (Empty, Used, Deleted);
	type Cell is record
		Key: Key_Type;
		Value: Value_Type;
		Status: Status_Type := Empty;
	end record;

	type Map_Array is array (0..MAP_M - 1) of Cell;
	type Map_Array_A is access Map_Array;
	type Map is record
		P_Array: Map_Array_A := new Map_Array;
		Length: Natural := 0;
	end record;

	-- Cursor
	type Cursor is record
		M: Map;
		Element_I: Natural;
		Finished: Boolean := False;
	end record;
end Hash_Maps_G;
