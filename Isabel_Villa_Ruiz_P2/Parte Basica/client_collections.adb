--client_collections.adb


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



procedure Delete_Client (Collection: in out Collection_Type;
    Nick: in ASU.Unbounded_String) is


begin
        ATIO.Put_Line("Hola");



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

    if Existe = False then
        raise Client_Collection_Error;
    end if;

return Respuesta;


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

    --En la parte de la extensión si está realizado esta funcion
    Respuesta2: String := "hola";

begin

    Respuesta2 := "hola";


return Respuesta2;

end Collection_Image;


end Client_Collections;
