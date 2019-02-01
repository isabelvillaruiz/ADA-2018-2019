--Isabel Villa Ruiz
-- Version EXTENSION


package body Client_Collections is


procedure Add_Client (Collection: in out Collection_Type;
    EP: in LLU.End_Point_Type;
    Nick: in ASU.Unbounded_String;
    Unique: in Boolean) is

        Add_Client_Error : exception;

        P_Aux_Ultimo: Collection_Type;
        P_Aux_Creador: Collection_Type;

        P_Aux_Lector: Collection_Type;
        Registro: ASU.Unbounded_String;
        Sig_Registro : Collection_Type;

        Existe : Boolean;
        Final: Boolean;


begin

        Existe := False;
        Final := False;

        if Collection.P_First = null then
          Collection.P_First := new Cell;
          Collection.P_first.Client_EP := EP;
          Collection.P_first.Nick := Nick;
          Collection.Total := Collection.Total + 1;
          Collection.P_First.Next := null;


        else
            --.Put_Line("No es el primero");
            --NUEVA ENTRADA O SUMA AL CONTADOR
            P_Aux_Lector := Collection;
            Sig_Registro := P_Aux_Lector;

            --Esto cubre el caso de haber una entrada y ninguna mas despues

            while not Final loop
                --ATIO.Put_Line(ASU.To_String(Sig_Registro.P_First.Nick));
                --ATIO.Put_Line(ASU.To_String(Nick));
                if (ASU.To_String(Sig_Registro.P_first.Nick)) = (ASU.To_String(Nick)) then
                    --ATIO.Put_Line(ASU.To_String(Sig_Registro.P_First.Nick));
                    --ATIO.Put_Line(ASU.To_String(Nick));
                    Existe := True;
                end if;
                if Sig_Registro.P_first.Next /= null then
                    Sig_Registro.P_first := Sig_Registro.P_first.Next;
                elsif Sig_Registro.P_first.Next = null then
                    Final:= True;
                    --Hemos llegado al comienzo de la lista.
                end if;
            end loop;

            --P_Aux_Ultimo.P_First := Sig_Registro.P_First;

            --ATIO.Put_Line("Existe: " & Boolean'Image(Existe));
            --ATIO.Put_Line("Unique: " & Boolean'Image(Unique));

            --Si no encuentra el nick repetido y el Unique es True: Es un cliente-writter nuevo!
            --Si encuentra el nick repetido y el Unique es False : Es un cliente-lector nuevo!
            if (Existe = False and Unique = True) or ( Existe = True  and Unique = False) then

              --ATIO.Put_Line("Nuevo");
              P_Aux_Creador.P_First := new Cell;
              P_Aux_Creador.P_First.Nick := Nick;
              P_Aux_Creador.P_First.Client_EP := EP ;
              Collection.Total := Collection.Total + 1;

              P_Aux_Creador.P_First.Next := Collection.P_First;
              Collection.P_First := P_Aux_Creador.P_First;

            elsif ((Existe = True and Unique = True)) then
                raise Client_Collection_Error;
            end if;
        end if;

        --
        ----PRUEBA QUE ME IMPRIME LA LISTA ENTERA
        --
        --Final := False;
        --
        --P_Aux_Lector := Collection;
        --Sig_Registro := P_Aux_Lector;
        --
        --ATIO.Put_Line("Imprimimos la lista:");
        --ATIO.New_Line;
        --if Sig_Registro.P_First = null then
        --    ATIO.Put_Line("No words");
        --elsif Sig_Registro.P_First /= null then
        --    while not Final loop
        --        ATIO.Put_Line("|" & ASU.To_String(Sig_Registro.P_first.Nick) & "|");
        --        if Sig_Registro.P_first.Next /= null then
        --            Sig_Registro.P_first := Sig_Registro.P_first.Next;
        --        elsif Sig_Registro.P_first.Next = null then
        --            Final:= True;
        --        end if;
        --    end loop;
        --end if;
        --ATIO.Put_Line("Total : |" & Natural'Image(Collection.Total) & "|");
end Add_Client;

--LIBERADOR DE MEMORIA
procedure Free is new Ada.Unchecked_Deallocation(Cell,Cell_A);

procedure Delete_Client (Collection: in out Collection_Type;
    Nick: in ASU.Unbounded_String) is

    P_Buscador : Collection_Type;
    P_Anterior: Collection_Type;
    P_Borrar : Collection_Type;

    Final: Boolean;
    Existe :Boolean;


begin


    P_Buscador := Collection;
    P_Anterior.P_First := null;
    Final := False;

    while not Final loop
        if (ASU.To_String(P_Buscador.P_First.Nick)) = (ASU.To_String(Nick)) then
            Existe := True;
            if P_Anterior.P_First = null then
                --La celda a borrar es la primera.
                Collection.P_First := P_Buscador.P_First.Next;
                P_Anterior.P_First := null;
                Final := True;
                P_Borrar.P_First := P_Buscador.P_First;
                Collection.Total := Collection.Total - 1;
                Free(P_Borrar.P_First);
            elsif P_Anterior.P_First /= null then
                P_Anterior.P_First.Next := P_Buscador.P_First.Next;
                P_Borrar.P_First := P_Buscador.P_First;
                Collection.Total := Collection.Total - 1;
                Free(P_Borrar.P_First);
            end if;
        end if;

        if P_Buscador.P_First.Next /= null then
            P_Anterior.P_First := P_Buscador.P_First;
            P_Buscador.P_First := P_Buscador.P_First.Next;
        elsif P_Buscador.P_First.Next = null then
            Final:= True;
        end if;

    end loop;

    if Existe = False then
        raise Client_Collection_Error;
    end if;

end Delete_Client;

function Search_Client (Collection: in Collection_Type;
    EP: in LLU.End_Point_Type) return ASU.Unbounded_String is


    P_Aux_Lector: Collection_Type;
    Sig_Registro : Collection_Type;

    Respuesta : ASU.Unbounded_String;

    Existe : Boolean;
    Final: Boolean;

begin

    P_Aux_Lector := Collection;
    Sig_Registro := P_Aux_Lector;

    Existe := False;
    Final := False;

    --Esto cubre el caso de haber una entrada y ninguna mas despues


    if Sig_Registro.P_first = null then
      raise Client_Collection_Error;
    else
      while not Final loop
          if Sig_Registro.P_First.Client_EP = EP then
              Existe := True;
              Respuesta := Sig_Registro.P_First.Nick;
              Final := True;
          end if;
          if Sig_Registro.P_First.Next /= null then
              Sig_Registro.P_First := Sig_Registro.P_First.Next;
          elsif Sig_Registro.P_First.Next = null then
              Final:= True;
          end if;
      end loop;
    end if;

    --ATIO.Put_Line(Boolean'Image(Existe));

    if Existe = False then
        raise Client_Collection_Error;
    else
        return Respuesta;
    end if;


end Search_Client;




procedure Send_To_All (Collection: in Collection_Type;
P_Buffer: access LLU.Buffer_Type) is

    --P_Lista: Word_List_Type;
    P_Aux_Lector: Collection_Type;
    Registro: ASU.Unbounded_String;
    Sig_Registro : Collection_Type;

    EP_to_send : LLU.End_Point_Type;

    Final: Boolean;

begin

    Final := False;

    P_Aux_Lector := Collection;
    Sig_Registro := P_Aux_Lector;

    if Sig_Registro.P_First = null then
        ATIO.Put_Line("No reader clients ");
    elsif Sig_Registro.P_First /= null then
        while not Final loop
            EP_to_send := Sig_Registro.P_First.Client_EP;
            LLU.Send(EP_to_send,P_Buffer);
            --Aqui va el Send.
            if Sig_Registro.P_First.Next /= null then
                Sig_Registro.P_First := Sig_Registro.P_First.Next;
            elsif Sig_Registro.P_First.Next = null then
                Final:= True;
            end if;
        end loop;
    end if;


end Send_To_All;
--Se le pasa el puntero que apunta al buffer.




function Collection_Image (Collection: in Collection_Type)
return String is

    EP : LLU.End_Point_Type;
    EP_Content : ASU.Unbounded_String;
    Nick : ASU.Unbounded_String;

    Position : Integer;
    Inicio :  ASU.Unbounded_String;
    Ip : ASU.Unbounded_String;
    Port: ASU.Unbounded_String;

    Element : ASU.Unbounded_String;
    Coll_Im : ASU.Unbounded_String;

    Puerto : ASU.Unbounded_String;
    Find: ASU.Unbounded_String;

    P_Aux_Lector: Collection_Type;
    Sig_Registro : Collection_Type;

    --Existe : Boolean;
    Final: Boolean;

begin

    --PRUEBA QUE ME IMPRIME LA LISTA ENTERA

    Final := False;

    P_Aux_Lector := Collection;
    Sig_Registro := P_Aux_Lector;

    --ATIO.Put_Line("Imprimimos la lista:");
    ATIO.New_Line;
    if Sig_Registro.P_First = null then
        ATIO.Put_Line("No words");
    elsif Sig_Registro.P_First /= null then
        while not Final loop
            EP := Sig_Registro.P_First.Client_EP;
            Nick := Sig_Registro.P_First.Nick;

            EP_Content := ASU.To_Unbounded_String(LLU.Image(EP));
            Inicio := EP_Content;

            --ATIO.Put_Line("EP:" & ASU.To_String(EP_Content));

            --Extraccion de la direccion IP
            Position := ASU.Index(Inicio, Ada.Strings.Maps.To_Set(":"));
            Inicio := ASU.Tail (Inicio, ASU.Length(Inicio)-Position-1);

            Position := ASU.Index(Inicio, Ada.Strings.Maps.To_Set(","));
            Ip := ASU.Head (Inicio, Position-1);

            --Extraccion del puerto.
            Inicio := ASU.Tail (Inicio, ASU.Length(Inicio)-Position-1);

            Position := ASU.Index(Inicio,":", Ada.Strings.Backward);
            Port := ASU.Tail(Inicio, Position);


            --ATIO.Put_Line(ASU.To_String(Inicio));
            --ATIO.Put_Line("ip:" & ASU.To_String(Ip));
            --ATIO.Put_Line("port:" & ASU.To_String(Port));

            --ATIO.Put_Line(ASU.To_String(EP_Content));

            Element := ASU.To_Unbounded_String(ASU.To_String(Ip) & ":" & ASU.To_String(Port) & " " & ASU.To_String(Nick) & ASCII.LF);

            Coll_Im := ASU.To_Unbounded_String((ASU.To_String(Coll_Im) & ASU.To_String(Element)));

            --ATIO.Put_Line(ASU.To_String(Coll_Im));


            if Sig_Registro.P_first.Next /= null then
                Sig_Registro.P_first := Sig_Registro.P_first.Next;
            elsif Sig_Registro.P_first.Next = null then
                Final:= True;
            end if;

        end loop;
    end if;

    --ATIO.Put_Line("Total : |" & Natural'Image(Collection.Total) & "|");


    return ASU.To_String(Coll_Im);

end Collection_Image;


end Client_Collections;
