with Ada.Command_Line;
--with Ada.Text_IO;

package body Server_Args_Control is
	package ACL renames Ada.Command_Line;

	function Get_Max_Length_Maps(Num_Args: in Positive; Num_Min_AC: in Positive; Num_Max_AC: in Positive) return Natural is
		Max_Active_Clients: Integer;
	begin
		if ACL.Argument_Count /= Num_Args then
			return 0;
		end if;

		Max_Active_Clients := Integer'Value(ACL.Argument(2));
		if Max_Active_Clients < Num_Min_AC or Max_Active_Clients > Num_Max_AC then
			return 0;
		end if;

		--Ada.Text_IO.Put_Line(Natural'Image(Max_Active_Clients));
		return Max_Active_Clients;

	end Get_Max_Length_Maps;
end Server_Args_Control;
