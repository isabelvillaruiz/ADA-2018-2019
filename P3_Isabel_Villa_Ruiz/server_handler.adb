with Ada.Text_IO;
with Gnat.Calendar.Time_IO;
with Chat_Messages;


package body Server_Handler is

    Active_Clients: ACP.Map;
    Inactive_Clients: ICP.Map;

    use type Ada.Calendar.Time;


function EP_Format (EP: LLU.End_Point_Type) return ASU.Unbounded_String is

EP_Content: ASU.Unbounded_String;
Position : Integer;
Inicio :  ASU.Unbounded_String;
Ip : ASU.Unbounded_String;
Port: ASU.Unbounded_String;

begin

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

    return ASU.To_Unbounded_String("(" & ASU.To_String(Ip) & ":" & ASU.To_String(Port) & ")");

end EP_Format;

procedure Print_All_Inactive_Clients is
    --Inicializo el cursor al primero, y llamo a la funcion First de mi paquete instanciado ACP.
    Cursor_Inactive_Clients: ICP.Cursor := ICP.First(Inactive_Clients);
    Inactive_Client: ICP.Element_Type;
    T : ASU.Unbounded_String;
begin
    --Hay elemento en el cursor ?, mientra sea así coge el elemento me escribes su key-
    while ICP.Has_Element(Cursor_Inactive_Clients) = True loop
        Inactive_Client := ICP.Element(Cursor_Inactive_Clients);
        ATIO.Put(ASU.To_String(Inactive_Client.Key) & " ");
        T := ASU.To_Unbounded_String(Gnat.Calendar.Time_IO.Image(Inactive_Client.Value, "%d-%b-%y %T.%i"));
        ATIO.Put_Line(ASU.To_String(T));
        --Avanzamos el Cursor uno mas adelante.
        ICP.Next(Cursor_Inactive_Clients);
    end loop;

end Print_All_Inactive_Clients;

procedure Print_All_Active_Clients is
    --Inicializo el cursor al primero, y llamo a la funcion First de mi paquete instanciado ACP.
    Cursor_Active_Clients: ACP.Cursor := ACP.First(Active_Clients);
    Active_Client: ACP.Element_Type;
    T : ASU.Unbounded_String;
    EP : ASU.Unbounded_String;
begin
    --Hay elemento en el cursor ?, mientra sea así coge el elemento me escribes su key-
    while ACP.Has_Element(Cursor_Active_Clients) = True loop
        Active_Client := ACP.Element(Cursor_Active_Clients);
        ATIO.Put(ASU.To_String(Active_Client.Key) & " ");
        EP := EP_Format(Active_Client.Value.Client_EP_Handler);
        ATIO.Put(ASU.To_String(EP) & ": ");
        T := ASU.To_Unbounded_String(Gnat.Calendar.Time_IO.Image(Active_Client.Value.Last_Connection, "%d-%b-%y %T.%i"));
        ATIO.Put_Line(ASU.To_String(T));

        --Avanzamos el Cursor uno mas adelante.
        ACP.Next(Cursor_Active_Clients);
    end loop;

end Print_All_Active_Clients;


function Find_Oldest_Active_Client (Active_Clients: in ACP.Map) return ACP.Element_Type is
    --Inicializo el cursor al primero, y llamo a la funcion First de mi paquete instanciado ACP.
    Cursor_Active_Clients: ACP.Cursor := ACP.First(Active_Clients);
    Actual_Client: ACP.Element_Type;
    Oldest_Active_Client : ACP.Element_Type;
begin
    --Hay elemento en el cursor ?, mientra sea así coge el elemento me escribes su key-
    Oldest_Active_Client := ACP.Element(Cursor_Active_Clients);
    while ACP.Has_Element(Cursor_Active_Clients) = True loop
        Actual_Client := ACP.Element(Cursor_Active_Clients);
        --Si el que estoy cogiendo ahora es mas antiguo que el mas antiguo lo actualizamos!
        if Actual_Client.Value.Last_Connection < Oldest_Active_Client.Value.Last_Connection then
            Oldest_Active_Client := Actual_Client;
        end if;
        ACP.Next(Cursor_Active_Clients);
    end loop;
    return Oldest_Active_Client;
end Find_Oldest_Active_Client;


procedure Send_To_All_Client (Active_Clients: in ACP.Map;
                                Nick: in ASU.Unbounded_String;
                                Comment: in ASU.Unbounded_String;
                                Nick_Banned : in ASU.Unbounded_String) is
    --Inicializo el cursor al primero, y llamo a la funcion First de mi paquete instanciado ACP.
    Cursor_Active_Clients: ACP.Cursor := ACP.First(Active_Clients);
    Active_Client: ACP.Element_Type;
    Buffer: aliased LLU.Buffer_Type(1024);

begin
    --Hay elemento en el cursor ?, mientra sea así coge el elemento me escribes su key-

    --ATIO.Put_Line("Los clientes activos son:");
    --Print_All_Active_Clients(Active_Clients);

    while ACP.Has_Element(Cursor_Active_Clients) = True loop
        Active_Client := ACP.Element(Cursor_Active_Clients);
        if ASU.To_String(Active_Client.Key) /= ASU.To_String(Nick_Banned) then
            --ATIO.Put_Line("Enviando Mensaje Server a " & ASU.To_String(Active_Client.Key));
            -- MENSAJE TIPO SERVER
            LLU.Reset(Buffer);
            CM.Message_Type'Output(Buffer'Access,CM.Server);
            ASU.Unbounded_String'Output(Buffer'Access,Nick);
            ASU.Unbounded_String'Output(Buffer'Access, Comment);
            LLU.Send(Active_Client.Value.Client_EP_Handler, Buffer'Access);
        end if;
        --Avanzamos
        ACP.Next(Cursor_Active_Clients);
    end loop;
end Send_To_All_Client;




procedure Chat_Handler (From: in LLU.End_Point_Type;
                          To: in LLU.End_Point_Type;
                          P_Buffer: access LLU.Buffer_Type) is


    --Active_Clients: ACP.Map;
    --Inactive_Clients: ICP.Map;



    Usage_Error : exception;

    Client_EP_Receive: LLU.End_Point_Type;
    Client_EP_Handler: LLU.End_Point_Type;
    Nick_Name : ASU.Unbounded_String;
    --Max_Client : Integer;

    Active_Client_Record: Active_Client_Record_Type;
    Success: Boolean;
    Accepted : Boolean;
    Deleted : Boolean;
    Message : CM.Message_Type;
    Buffer:  aliased LLU.Buffer_Type(1024);
    Request: ASU.Unbounded_String;

    Oldest_Active_Client : ACP.Element_Type;

begin
    --LE LLEGA LO PRIMERO AQUI AL HANDLER

    Message := CM.Message_Type'Input(P_Buffer);
    case Message is

        when CM.Init =>
            --Si es Init:

            --Client_EP Receive & Handler
            Client_EP_Receive := LLU.End_Point_Type'Input (P_Buffer);
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);

            --NickName
            Nick_Name := ASU.Unbounded_String'Input (P_Buffer);

            ATIO.Put("INIT received from " & ASU.To_String(Nick_Name));
            --Debemos ver si es Escritor o Lector para saber en que lista meterlo.

            --AÑADIR CLIENTE
            ACP.Get(Active_Clients,Nick_Name,Active_Client_Record,Success);
            --ATIO.Put(">> salio del get: ");
            --ATIO.Put_Line(Boolean'Image(Success));

            if Success = True then
                --Ya existe este usuario.
                --Mandamos mensaje Welcome con Accepted = False;
                Accepted := False;
                ATIO.Put_Line(": IGNORED, nick already used");
            else
                --No existe el usuario con ese nick lo metemos.
                Active_Client_Record.Client_EP_Handler := Client_EP_Handler;
                Active_Client_Record.Last_Connection := Ada.Calendar.Clock;

                begin
                    ACP.Put(Active_Clients,Nick_Name,Active_Client_Record);
                    Accepted := True;
                    ATIO.Put_Line(": ACCEPTED");
                exception
                    --Full_Map hay que hacer hueco en la lista de clientes activos
                    when ACP.Full_Map =>
                        --Buscamos el mas viejo
                        Oldest_Active_Client := Find_Oldest_Active_Client(Active_Clients);
                        --Avisamos del baneo del cliente viejo
                        --Nick_Name := "server";
                        Send_To_All_Client(Active_Clients, ASU.To_Unbounded_String("server"),
                            ASU.To_Unbounded_String(ASU.To_String(Oldest_Active_Client.Key)
                            & " banned for being idle too long"),ASU.To_Unbounded_String(""));

                        --Borramos al mas viejo de la lista de activos
                        ACP.Delete(Active_Clients,Oldest_Active_Client.Key,Deleted);

                        if Deleted = True then
                            begin
                                ICP.Put(Inactive_Clients, Oldest_Active_Client.Key, Ada.Calendar.Clock);

                                --ATIO.Put_Line("los inactivos son: ");
                                --Print_All_Inactive_Clients(Inactive_Clients);
                                --ATIO.Put_Line("fin de los  inactivos");

                            exception
                                when ICP.Full_Map =>
                                --Full Map en Inactive
                                ATIO.Put_Line(": IGNORED, Inactive Client List Complete.");
                            end;
                        end if;
                        ACP.Put(Active_Clients,Nick_Name,Active_Client_Record);
                        Accepted := True;
                        ATIO.Put_Line(": ACCEPTED");
                end;
            end if;


            --ATIO.Put_Line("los inactivos son: ");
            --Print_All_Inactive_Clients;

            --ATIO.Put_Line("Los clientes activos son:");
            --Print_All_Active_Clients;
            -- MENSAJE WELCOME
            LLU.Reset(Buffer);
            --ATIO.Put_Line("Va a mandar el welcome");
            CM.Message_Type'Output(Buffer'Access,CM.Welcome);
            Boolean'Output(Buffer'Access,Accepted);
            LLU.Send(Client_EP_Receive,Buffer'Access);
            --Ada.Text_IO.Put_Line(">> Welcome enviado a cliente");

            if Success = False then
                --MENSAJE TIPO SERVER PARA COMUNICAR A LOS READERS DEL NUEVO USUARIO.
                Send_To_All_Client(Active_Clients, ASU.To_Unbounded_String("server"),
                ASU.To_Unbounded_String(ASU.To_String(Nick_Name) & " joins the chat"), Nick_Name);
            end if;


            --Active_Client_Record.Client_EP_Handler := Client_EP_Handler;
            --Active_Client_Record.Last_Connection := Ada.Calendar.Clock;

            --ACP.Put(Active_Clients,Nick_Name,Active_Client_Record);
            --ATIO.Put_Line(LLU.Image(Active_Client_Record.Client_EP_Handler));

            --COMRPROBACION Y POSTERIOS MENSAJE WELCOME
            --Print_All_Active_Clients(Active_Clients);

            --ACP.Get(Active_Clients,Nick_Name,Active_Client_Record,Success);
            --ATIO.Put(">> salio del get ");
            --ATIO.Put_Line(Boolean'Image(Success));




            -- reinicializa (vacía) el buffer
            --LLU.Reset (Buffer);


        when CM.Writer =>

            --Si es Writter:

            --Client_EP_Handler
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            --Nick Name
            Nick_Name := ASU.Unbounded_String'Input (P_Buffer);
            --Comentario
            Request := ASU.Unbounded_String'Input (P_Buffer);

            ATIO.Put("WRITER received from ");

            ACP.Get(Active_Clients,Nick_Name,Active_Client_Record,Success);

            if Success = True then
                if LLU.Image(Client_EP_Handler) = LLU.Image(Active_Client_Record.Client_EP_Handler) then
                --El cliente es de nuestra lista de clientes activos.
                ATIO.Put_Line(ASU.To_String(Nick_Name) & ": " & ASU.To_String(Request));

                --Actualizamos la fecha de uso del cliente.
                Active_Client_Record.Last_Connection := Ada.Calendar.Clock;
                ACP.Put(Active_Clients, Nick_Name, Active_Client_Record);

                --MENSAJE TIPO SERVER PARA COMUNICAR A LOS READERS DEL NUEVO USUARIO.
                Send_To_All_Client(Active_Clients, Nick_Name, Request, Nick_Name);
                -- reinicializa (vacía) el buffer
                else
                    ATIO.Put("unknown client. IGNORED");
                end if;
            else
                ATIO.Put_Line("unknown client. IGNORED");
            end if;

        when CM.Logout =>

            --Si es Logout:

            --Client_EP_Handler
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            --Nick Name
            Nick_Name := ASU.Unbounded_String'Input (P_Buffer);

            ATIO.Put("LOGOUT received from ");

            --Nick_Name := CC.Search_Client(P_Writers,Client_EP);
            --ATIO.Put_Line(ASU.To_String(Nick_Name));

            ACP.Get(Active_Clients,Nick_Name,Active_Client_Record,Success);

            if Success = True then
                if LLU.Image(Client_EP_Handler) = LLU.Image(Active_Client_Record.Client_EP_Handler) then

                    --El cliente es de nuestra lista de clientes activos.
                    ATIO.Put_Line(ASU.To_String(Nick_Name));

                    --Borramos al cliente de la lista de los activos y la añadimos a los inactivos
                    ACP.Delete(Active_Clients, Nick_Name, Success);
                    if Success then
                        ICP.Put(Inactive_Clients, Nick_Name, Ada.Calendar.Clock);
                        Send_To_All_Client(Active_Clients, ASU.To_Unbounded_String("server"),
                        ASU.To_Unbounded_String(ASU.To_String(Nick_Name) & " leaves the chat"),Nick_Name);
--                    else
--                        null; -- Note: It's not necessary
                    end if;
                else
                    ATIO.Put_Line("unknown client. IGNORED");
                end if;
            else
                ATIO.Put_Line("unknown client. IGNORED");
            end if;


        when others =>
          ATIO.Put_Line("Error in the selection");
    end case;

end Chat_Handler;

end Server_Handler;
