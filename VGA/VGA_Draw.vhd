library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Snake_Globals.all;
--------------------------------------------------------------------
-- Description
-- VGA_Draw sets the R, G, and B-Values for VGA based on the current
-- X- and Y-Position provided by VGA_Sync and the snakes current
-- position
--------------------------------------------------------------------

--------------------------------------------------------------------
--                 Entity of VGA_Draw
--------------------------------------------------------------------
entity VGA_Draw is
	port (
		CLK		: in std_logic;
		Reset		: in std_logic;
		Drawable        : in std_logic;
		X_Pos 		: in integer range 0 to 799;
		Y_Pos		: in integer range 0 to 524;
		R		: out std_logic_vector(3 downto 0);
		G		: out std_logic_vector(3 downto 0);
		B		: out std_logic_vector(3 downto 0);
		Text_On		: in std_logic
	);
end VGA_Draw;

--------------------------------------------------------------------
--                 Architecture of Beh_VGA_Draw
--------------------------------------------------------------------

architecture Beh_VGA_Draw OF VGA_Draw is	
begin
	process(all)
	begin
		if rising_edge(CLK) then
			R <= x"0";
			G <= x"0";
			B <= x"0";
			
			if Drawable = '1' then
				-- Implement drawing of RGB here
			end if;
			
			if Reset = '1' then
				R <= x"0";
				G <= x"0";
				B <= x"0";
			end if;
		end if;
	end process;

end Beh_VGA_Draw;
