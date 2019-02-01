--Isabel Villa Ruiz, 2018
with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;

with Ada.Unchecked_Deallocation;


package body Word_Lists is

  procedure Add_Word (List: in out Word_List_Type ; Word: in ASU.Unbounded_String) is

      P_Aux_Ultimo: Word_List_Type;
      P_Aux_Creador: Word_List_Type;
      Contador: Integer;

      P_Aux_Lector: Word_List_Type;
      Registro: ASU.Unbounded_String;
      Sig_Registro : Word_List_Type;

      Existe : Boolean;
      Final: Boolean;

  begin

    Existe := False;
    Final := False;

    if List = null then
      List := new Cell;
      List.Word := Word;
      List.Count := 1;
      List.Next := null;
      Contador := 1;

    else

        --NUEVA ENTRADA O SUMA AL CONTADOR
        P_Aux_Lector := List;
        Sig_Registro := P_Aux_Lector;

        --Esto cubre el caso de haber una entrada y ninguna mas despues

        while not Final loop
            if (ASU.To_String(Sig_Registro.Word)) = (ASU.To_String(Word)) then
                Sig_Registro.Count := Sig_Registro.Count + 1;
                Existe := True;
            end if;
            if Sig_Registro.Next /= null then
                Sig_Registro := Sig_Registro.Next;
            elsif Sig_Registro.Next = null then
                Final:= True;
            end if;
        end loop;

        P_Aux_Ultimo := Sig_Registro;

        if Existe = False then

          P_Aux_Creador := new Cell;
          P_Aux_Creador.Word := Word;
          P_Aux_Creador.Count := 1;

          P_Aux_Ultimo.Next := P_Aux_Creador;
          P_Aux_Ultimo := P_Aux_Creador;
        end if;
    end if;


  end Add_Word;

--LIBERADOR DE MEMORIA
  procedure Free is new Ada.Unchecked_Deallocation(Cell,Word_List_Type);

  procedure Delete_Word (List: in out Word_List_Type; Word: in ASU.Unbounded_String) is

      P_Buscador : Word_List_Type;
      P_Anterior: Word_List_Type;
      P_Borrar : Word_List_Type;


      Final: Boolean;

  begin

      P_Buscador := List;
      P_Anterior := null;
      Final := False;

      while not Final loop
          if (ASU.To_String(P_Buscador.Word)) = (ASU.To_String(Word)) then
              if P_Anterior = null then
                  --La celda a borrar es la primera.
                  List := P_Buscador.Next;
                  P_Anterior := null;
                  Final := True;
                  P_Borrar := P_Buscador;
                  Free(P_Borrar);
              elsif P_Anterior /= null then
                  P_Anterior.Next := P_Buscador.Next;
                  P_Borrar := P_Buscador;
                  Free(P_Borrar);
              end if;
          end if;

          if P_Buscador.Next /= null then
              P_Anterior := P_Buscador;
              P_Buscador := P_Buscador.Next;
          elsif P_Buscador.Next = null then
              Final:= True;
          end if;
      end loop;

  end Delete_Word;


  procedure Delete_List (List: in out Word_List_Type) is

      P_Buscador : Word_List_Type;
      P_Borrar : Word_List_Type;

      Final: Boolean;

  begin
      P_Buscador := List;
      Final := False;

      while not Final loop
          if P_Buscador /= null then
              --La celda a borrar es la primera.
              List := P_Buscador.Next;
              P_Borrar := P_Buscador;
              Free(P_Borrar);
              P_Buscador := List;
          elsif P_Buscador = null then
              Final:= True;
          end if;
      end loop;

  end Delete_List;

  procedure Search_Word (List: in Word_List_Type; Word: in ASU.Unbounded_String ; Count: out Natural) is


    P_Aux_Lector: Word_List_Type;
    Sig_Registro : Word_List_Type;

    Existe : Boolean;
    Final: Boolean;


  begin
    --ATIO.Put_Line("Search Word selected");


    P_Aux_Lector := List;
    Sig_Registro := P_Aux_Lector;

    Existe := False;
    Final := False;

    --Esto cubre el caso de haber una entrada y ninguna mas despues

    while not Final loop
        if (ASU.To_String(Sig_Registro.Word)) = (ASU.To_String(Word)) then
            Existe := True;
            Count := Sig_Registro.Count;
        end if;
        if Sig_Registro.Next /= null then
            Sig_Registro := Sig_Registro.Next;
        elsif Sig_Registro.Next = null then
            Final:= True;
        end if;
    end loop;

    if Existe = False then
        Count := 0;
    end if;
  end Search_Word;


  procedure Max_Word (List: in Word_List_Type; Word: out ASU.Unbounded_String; Count: out Natural) is

      P_Aux_Lector: Word_List_Type;
      Sig_Registro : Word_List_Type;

      Final: Boolean;
      MaxNum : Natural;
      MaxWord : ASU.Unbounded_String;

      Word_List_Error: exception;

  begin

      P_Aux_Lector := List;
      Sig_Registro := P_Aux_Lector;

      Final := False;

      MaxNum := Sig_Registro.Count;
      MaxWord := Sig_Registro.Word;

      if Sig_Registro = null then
          raise Word_List_Error;
      end if;

      while not Final loop
          if  (Sig_Registro.Count) > (MaxNum) then
              MaxNum := Sig_Registro.Count;
              MaxWord := Sig_Registro.Word;
          end if;
          if Sig_Registro.Next /= null then
              Sig_Registro := Sig_Registro.Next;
          elsif Sig_Registro.Next = null then
              Final:= True;
          end if;
      end loop;

      Count := MaxNum;
      Word := MaxWord;

      exception
         when Word_List_Error =>
           ATIO.Put_Line("La lista está vacía");
      --Esto cubre el caso de haber una entrada y ninguna mas despues


  end Max_Word;



  procedure Print_All (List: in Word_List_Type) is

  --P_Lista: Word_List_Type;
  P_Aux_Lector: Word_List_Type;
  Registro: ASU.Unbounded_String;
  Sig_Registro : Word_List_Type;

  Final: Boolean;

  begin
    --ATIO.Put_Line("Print All selected");
    ATIO.New_Line;
    Final := False;

    P_Aux_Lector := List;
    Sig_Registro := P_Aux_Lector;

    if Sig_Registro = null then
        ATIO.Put_Line("No words");
    elsif Sig_Registro /= null then
        while not Final loop
            ATIO.Put_Line("|" & ASU.To_String(Sig_Registro.Word) & "| - " & Natural'Image(Sig_Registro.Count));
            if Sig_Registro.Next /= null then
                Sig_Registro := Sig_Registro.Next;
            elsif Sig_Registro.Next = null then
                Final:= True;
            end if;
        end loop;
    end if;
  end Print_All;



end Word_Lists;
