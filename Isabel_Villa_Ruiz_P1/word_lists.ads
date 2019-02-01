--Isabel Villa Ruiz, 2018
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.IO_Exceptions;


package Word_Lists is

   package ASU renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;

   type Cell;

   type Word_List_Type is access Cell;

   type Cell is record
      Word: ASU.Unbounded_String;
      Count: Natural := 0;
      Next: Word_List_Type;
   end record;

   Word_List_Error: exception;

   procedure Add_Word (List: in out Word_List_Type;
		                 Word: in ASU.Unbounded_String);

   procedure Delete_Word (List: in out Word_List_Type;
			                 Word: in ASU.Unbounded_String);

   procedure Search_Word (List: in Word_List_Type;
			                 Word: in ASU.Unbounded_String;
			                 Count: out Natural);

   procedure Max_Word (List: in Word_List_Type;
	                    Word: out ASU.Unbounded_String;
		                 Count: out Natural);

   procedure Print_All (List: in Word_List_Type);

   procedure Delete_List (List: in out Word_List_Type);

end Word_Lists;
