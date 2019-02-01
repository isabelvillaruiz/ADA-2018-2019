with Lower_Layer_UDP;

package Client_Handler is

package LLU renames Lower_Layer_UDP;


    procedure Chat_Handler (From: in LLU.End_Point_Type;
                              To: in LLU.End_Point_Type;
                              P_Buffer: access LLU.Buffer_Type);


end Client_Handler;
