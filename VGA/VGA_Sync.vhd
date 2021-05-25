library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Snake_Globals.all;
--------------------------------------------------------------------
-- Description
--------------
-- VGA_Sync controls the HS and VS signals for the VGA interface
-- as well as the x- and y-position of the current pixel.
-- H_Sync and V_Sync signals can directly be forwarded to VGA.
-- If Drawable is set, X_Pos and Y_Pos will contain coordinates for
-- a pixel that is visible on the screen and can be colored.
-- If Drawable is not set, RGB have to be 0 as we are currently
-- in the front- or backporch phase
--------------------------------------------------------------------

--------------------------------------------------------------------
--                 Entity of VGA_Sync
--------------------------------------------------------------------
entity VGA_Sync is
	port (
		CLK	 	: in std_logic;						-- Clock
		Reset   	: in std_logic;						-- Reset for simulation
		H_Sync	: out std_logic;						-- Used during horizontal front and back porch (for every line)
		V_Sync	: out std_logic;						-- Used during vertical front and back porch (once per frame)
		X_Pos		: out integer range 0 to 799;		-- Current X-Position
		Y_Pos		: out integer range 0 to 524;		-- Current Y-Position
		Drawable : out std_logic						-- 1 = Pixel at position X_Pos / Y_Pos can be colored and visible on the screen
	);
end VGA_Sync;

--------------------------------------------------------------------
--                 Architecture of Beh_VGA_Sync
--------------------------------------------------------------------

architecture Beh_VGA_Sync of VGA_Sync is
begin
	process (all) begin
		if rising_edge(CLK) then
			if X_Pos = (HVA + HFP + HSP + HBP) then -- End of line reached
				X_Pos <= 0;
				if Y_Pos = (VVA + VFP + VSP + VBP) then -- End of frame reached
					Y_Pos <= 0;
				else
					Y_Pos <= Y_Pos + 1;
				end if;
			else
				X_Pos <= X_Pos + 1;
			end if;
			
			-- Horizontal sync, happens for every line
			if (X_Pos <= (HVA + HFP)) or (X_Pos > HVA + HFP + HSP) then
				H_Sync <= '1';
			else
				H_Sync <= '0';
			end if;
			
			-- Vertical sync, happens for every frame
			if (Y_Pos <= (VVA + VFP)) or (Y_Pos > VVA + VFP + VSP) then
				V_Sync <= '1';
			else
				V_Sync <= '0';
			end if;
			
			-- Set Drawable signal
			if X_Pos <= HVA and Y_Pos <= VVA then
				Drawable <= '1';
			else
				Drawable <= '0';
			end if;
			
			if Reset = '1' then
				H_Sync <= '0';
				V_Sync <= '0';
				X_Pos <= 0;
				Y_Pos <= 0;
				Drawable <= '0';
			end if;
		end if;
	end process;
end Beh_VGA_Sync;
