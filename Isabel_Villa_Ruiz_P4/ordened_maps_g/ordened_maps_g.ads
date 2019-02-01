generic
	type Key_Type is private;
	type Value_Type is private;
	with function "=" (K1, K2: Key_Type) return Boolean;
	with function "<" (K1, K2: Key_Type) return Boolean;
	Max: in Natural;
package Ordened_Maps_G is
	
	type Map is limited private;

	procedure Get(M: in Map;
		Key: in Key_Type;
		Value: out Value_Type;
		Success : out Boolean);

	Full_Map : exception;
	procedure Put(M: in out Map;
		Key: in Key_Type;
		Value: in Value_Type);

	procedure Delete(M: in out Map;
		Key: in Key_Type;
		Success: out Boolean);

	function Map_Length(M: in Map) return Natural;

	type Cursor is limited private;
	function First(M: in Map) return Cursor;
	procedure Next(C: in out Cursor);
	function Has_Element(C: in Cursor) return Boolean;
	type Element_Type is record
		Key: Key_Type;
		Value: Value_Type;
	end record;
	No_Element: exception;
	function Element(C: in Cursor) return Element_Type;
private
	type Cell is record
		Key: Key_Type;
		Value: Value_Type;
	end record;
	type Cell_Array is array (1..Max) of Cell;
	type Cell_Array_A is access Cell_Array;
	type Map is record
		P_Array: Cell_Array_A := new Cell_Array;
		Length: Natural := 0;
	end record;

	type Cursor is record
		M: Map;
		Element_I: Positive := 1;
		Has_Element: Boolean := False;
	end record;
end Ordened_Maps_G;
