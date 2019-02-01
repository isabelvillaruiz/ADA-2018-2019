--Isabel Villa Ruiz, 2018
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Strings.Maps;
--Los siguientes paquetes no tienen "rename".
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Word_Lists;
with Ada.Characters.Handling;


procedure words is
  package ACL renames Ada.Command_Line;
  package ASU renames Ada.Strings.Unbounded;
  package ATIO renames Ada.Text_IO;

  --VARIABLES

  Usage_Error : exception; --Error de uso tipo Exception
  File_Error : exception;

  Option : Integer;
  File : ASU.Unbounded_String;
  New_Word : ASU.Unbounded_String;
  Count : Natural;
  Word : ASU.Unbounded_String;

  List : Word_Lists.Word_List_Type;

  --PROCEDIMIENTOS

  procedure Split_Lines ( Src : in out ASU.Unbounded_String; Token :out ASU.Unbounded_String ;
   List: in out Word_Lists.Word_List_Type) is


    Position : Integer;
    Final : ASU.Unbounded_String;
    Word : ASU.Unbounded_String;
  --Begin de Split_Lines;
  begin
    Position := ASU.Index(Src, Ada.Strings.Maps.To_Set(" ,.-()':;""[]{}_/\$%&=?¿!¡*"));

    while Position /= 0 loop

        Token := ASU.Head (Src, Position-1);

        if ASU.To_String(Token) /= "" then
            Word := ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Token)));
            Word_Lists.Add_Word(List,Word);
        end if;

        Final := ASU.Tail (Src, ASU.Length(Src)-Position);

        Position := ASU.Index(Final,Ada.Strings.Maps.To_Set(" ,.-()':;""[]{}_/\$%&=?¿!¡*") );
        Src := Final;

        if Position = 0 and ASU.Length(Final) /= 0 then
            Token:= Final;
            Word := ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Token)));
            Word_Lists.Add_Word(List,Word);
        end if;

    end loop;
    if Position = 0 and (ASU.Length(Src) /= 0) and  (ASU.To_String(Token) /= ASU.To_String(Src)) then
        Token:= Src;
        Word := ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower(ASU.To_String(Token)));
        Word_Lists.Add_Word(List,Word);
    end if;
  end Split_Lines ;



  procedure Create_List ( File_Name : in ASU.Unbounded_String) is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;

    Usage_Error: exception;

  --File_Name: ASU.Unbounded_String;
  File: ATIO.File_Type;

  Finish: Boolean;
  Line: ASU.Unbounded_String;
  Part: ASU.Unbounded_String;


  --BEGIN DE Create_List;
  begin

  -- ABRIR FICHERO DE TEXTO PASADO COMO ARGUMENTO

  begin
  ATIO.Open(File, ATIO.In_File, ASU.To_String(File_Name));

  Finish := False;

      --BUCLE LECTURA POR LINEAS Y SPLIT LINEAS
      while not Finish loop
        begin
            Line := ASU.To_Unbounded_String(ATIO.Get_Line(File));
            Split_Lines(Line,Part,List);

            exception
            when Ada.IO_Exceptions.End_Error =>
              Finish := True;
              ATIO.Close(File);
            end;
      end loop;

  exception
  when Ada.IO_Exceptions.Name_Error =>
    ATIO.Put_Line(ASU.To_String(File_Name) & ": file not found");
  end;
  end Create_List;


  procedure Menu is

  begin
      --IMPRESION DE MENU POR TERMINAL
      ATIO.New_Line;
      ATIO.Put_Line ("Options:");
      ATIO.Put_Line ("1 Add word");
      ATIO.Put_Line ("2 Delete word");
      ATIO.Put_Line ("3 Search word");
      ATIO.Put_Line ("4 Show all words");
      ATIO.Put_Line ("5 Quit");
      ATIO.Put_Line ("Your option?");
      --Opcion por terminal
      Option := Integer'Value(ATIO.Get_Line);
      ATIO.Put_Line ("Your option is " & Integer'Image(Option));
      --OPCION DEL MENU SELECCIONADA
      case Option is
        when 1 =>
          ATIO.Put_Line("Word?");
          New_Word := ASU.To_Unbounded_String (ATIO.Get_Line);
          Word_Lists.Add_Word(List,New_Word);
          ATIO.Put_Line("Word |" & ASU.To_String(New_Word) & "| added");
          Menu;
        when 2 =>
          ATIO.Put_Line("Word?");
          New_Word := ASU.To_Unbounded_String (ATIO.Get_Line);
          begin
			  Word_Lists.Delete_Word(List,New_Word);
			  ATIO.Put_Line("Word |" & ASU.To_String(New_Word) & "| deleted");
		  exception
			  when Word_Lists.Word_List_Error =>
			     ATIO.Put_Line("Word not found");
		  end;
          Menu;
        when 3 =>
          ATIO.Put_Line("Word?");
          New_Word := ASU.To_Unbounded_String (ATIO.Get_Line);
          Word_Lists.Search_Word(List,New_Word,Count);
          ATIO.New_Line;
          ATIO.Put_Line("|" & ASU.To_String(New_Word) & "| - " & Natural'Image(Count));
          ATIO.New_Line;
          Menu;
        when 4 =>
          Word_Lists.Print_All(List);
          Menu;
        when 5 =>
          ATIO.New_Line;
          begin
  	        Word_Lists.Max_Word(List,Word,Count);
  	        ATIO.Put_Line("The most frequent word: " & "|" & ASU.To_String(Word) & "| - " & Natural'Image(Count));
            ATIO.New_Line;
            Word_Lists.Delete_List(List);
    		  exception
    			when Word_Lists.Word_List_Error =>
    			  ATIO.Put_Line("No words");
    		  end;
        when others =>
          ATIO.Put_Line("Error in the selection");
          Menu;
        end case;
  end Menu;


--BEGIN PRINCIPAL


begin
if (ACL.Argument_Count /= 1) and (ACL.Argument_Count /= 2) then
    raise Usage_Error;
end if;
--EJECUCION CORRECTACON 2 ARGUMENTOS
if (ACL.Argument_Count = 2) and (ACL.Argument(1) = "-i") then
    File := ASU.To_Unbounded_String(ACL.Argument(2));
    Create_List(File);
    Menu;
elsif (ACL.Argument_Count = 2) and (ACL.Argument(1) /= "-i") then
    raise Usage_Error;
--EJECUCION CORRECTA CON UN ARGUMENTO
elsif (ACL.Argument_Count = 1) then
    if (ACL.Argument(1) = "-i") then
        raise Usage_Error;
    end if;
    File := ASU.To_Unbounded_String(ACL.Argument(1));
    Create_List(File);
    ATIO.New_Line;
    begin
		Word_Lists.Max_Word(List,Word,Count);
		ATIO.Put_Line("The most frequent word: " & "|" & ASU.To_String(Word) & "| - " & Natural'Image(Count));
		ATIO.New_Line;
        Word_Lists.Delete_List(List);
	exception
		when Word_Lists.Word_List_Error =>
			ATIO.Put_Line("No words");
	end;
end if;

exception
  when Usage_Error =>
    ATIO.Put_Line("Use: ");
    ATIO.Put_Line("       " & ACL.Command_Name & " <file>");
  --when File_Error =>
    --Menu;
  when Except: Others =>
    ATIO.Put_Line("Unexpected exception");
end words;
