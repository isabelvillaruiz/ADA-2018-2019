--Isabel Villa Ruiz
-- Version EXTENSION


with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;


procedure Chat_Admin is


    package LLU renames Lower_Layer_UDP;
    package ASU renames Ada.Strings.Unbounded;
    package ACL renames Ada.Command_Line;
    package ATIO renames ADA.Text_IO;
    package CM renames Chat_Messages;
    package CC renames Client_Collections;

    use type CM.Message_Type;

    Usage_Error : exception;

    Server_EP: LLU.End_Point_Type;
    Admin_EP: LLU.End_Point_Type;
    Puerto : Integer;
    Maquina : ASU.Unbounded_String;

    Password :ASU.Unbounded_String;

    IP : ASU.Unbounded_String;
    Nick_Name : ASU.Unbounded_String;

    Nick_To_Ban : ASU.Unbounded_String;

    Message : CM.Message_Type;
    Buffer:  aliased LLU.Buffer_Type(1024);
    Data: ASU.Unbounded_String;

    P_Writers : CC.Collection_Type;
    P_Readers: CC.Collection_Type;

    Expired : Boolean;

    Option : Integer;


    procedure Menu is


        Final : Boolean;

    begin
        --IMPRESION DE MENU POR TERMINAL
        ATIO.New_Line;
        ATIO.Put_Line ("Options:");
        ATIO.Put_Line ("1 Show writters collection");
        ATIO.Put_Line ("2 Ban writer");
        ATIO.Put_Line ("3 Shutdown server");
        ATIO.Put_Line ("4 Quit");

        --Opcion por terminal
        Option := Integer'Value(ATIO.Get_Line);
        ATIO.Put_Line ("Your option is " & Integer'Image(Option));
        ATIO.New_Line;
        --OPCION DEL MENU SELECCIONADA
        case Option is
          when 1 =>
              LLU.Reset(Buffer);

              --ATIO.Put_Line("Hei");
              CM.Message_Type'Output(Buffer'Access,CM.Collection_Request);
              LLU.End_Point_Type'Output(Buffer'Access, Admin_EP);
              ASU.Unbounded_String'Output(Buffer'Access, Password);
              LLU.Send(Server_EP, Buffer'Access);

              loop
              -- reinicializa el buffer para empezar a utilizarlo
                  LLU.Reset(Buffer);

                  LLU.Receive(Admin_EP, Buffer'Access, 5.0, Expired);

                  if not Expired then
                      --ATIO.Put_Line("Data: ");
                      Message := CM.Message_Type'Input(Buffer'Access);
                      if Message = CM.Collection_Data then
                        Data := ASU.Unbounded_String'Input(Buffer'Access);
                        ATIO.Put_Line(ASU.To_String(Data));
                        Final := True;
                      end if;
                  else
                      ATIO.Put_Line("Incorrect Password");
                      --Ver si cuando la contraseña no es, debe petar
                  end if;

                  if Final = True then
                      Exit;
                  end if;

              end loop;

              Menu;
          when 2 =>

              LLU.Reset(Buffer);
              ATIO.Put_Line("Nick to ban? ");
              Nick_To_Ban := ASU.To_Unbounded_String (ATIO.Get_Line);

              CM.Message_Type'Output(Buffer'Access,CM.Ban);
              ASU.Unbounded_String'Output(Buffer'Access, Password);
              ASU.Unbounded_String'Output(Buffer'Access, Nick_To_Ban);
              LLU.Send(Server_EP, Buffer'Access);

              -- reinicializa el buffer para empezar a utilizarlo

              Menu;

          when 3 =>

            LLU.Reset(Buffer);

            --ATIO.Put_Line("Hei");
            CM.Message_Type'Output(Buffer'Access,CM.Shutdown);
            ASU.Unbounded_String'Output(Buffer'Access, Password);
            LLU.Send(Server_EP, Buffer'Access);

            ATIO.Put_Line("Server Shutdown sent");

            Menu;
          when 4 =>
            LLU.Finalize;
          when others =>
            ATIO.Put_Line("Error in the selection");
            Menu;
          end case;
    end Menu;


begin

    --Comprobacion de que los argumentos sean 3.
    if ACL.Argument_Count /= 3 then
        raise Usage_Error;
    end if;

    --Argumentos
    Maquina := ASU.To_Unbounded_String(ACL.Argument(1));
    Puerto := Integer'Value(ACL.Argument(2));
    Password := ASU.To_Unbounded_String(ACL.Argument(3));

    IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));

    Server_EP := LLU.Build( ASU.To_String(IP), Puerto);

    LLU.Bind_Any(Admin_EP);

    Menu;
exception
	when Usage_Error =>
		ATIO.Put_Line("usage: chat_admin <server_host> <server_port> <pasword>");
		LLU.Finalize;
end Chat_Admin;
