library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Snake_Globals.all;

--------------------------------------------------------------------
--                 Entity of VGA_Text
--------------------------------------------------------------------
entity VGA_Text is
	generic (
		Text_Length	: integer := 11; -- Length of the string
		Text_Pos		: in Point2D_t := (X => 0, Y => 0) -- Upper left corner of where the text should be put
	);
	port (
		CLK			: in std_logic;
		Reset			: in std_logic;
		Text_Cont	: in string (1 to Text_Length); -- Text to display
		X_Pos			: in integer range 0 to 799; -- Current VGA X position
		Y_Pos			: in integer range 0 to 524; -- Current VGA Y position
		Pixel_On		: out std_logic -- 1 = Turn pixel on to draw text
	);
end VGA_Text;

--------------------------------------------------------------------
--                 Architecture of Beh_VGA_Text
--------------------------------------------------------------------
architecture Beh_VGA_Text OF VGA_Text is
	signal Address 		: integer range 0 to 2047 := 0;			-- The row to select from ROM
	signal Font_Row		: std_logic_vector(7 downto 0);			-- The row returned by ROM
	signal Next_Font_Row	: std_logic_vector(7 downto 0);			-- The row returned by ROM
	signal Bit_Pos    	: integer range 0 to 7 := 0;
	signal Prefetch_Cnt 	: integer range 0 to 7 := 7;
begin
	Font_ROM: entity work.Font_ROM port map (
		CLK => CLK,
		Address => Address,
		Font_Row => Next_Font_Row
	);
	
	process(all)
		variable Char_Code : integer range 0 to 127 := 0;
		variable Char_Pos	 : integer range 0 to Text_Length := 0;
	begin
		if rising_edge(CLK) then
			Pixel_On <= '0';
			
			-- Set the correct address 3 cycles before we hit the target pixel
			if X_Pos >= Text_Pos.X - 3 and X_Pos < Text_Pos.X + (8 * Text_Length) - 3 and Y_Pos - Text_Pos.Y >= 0 then
				if Prefetch_Cnt = 7 then
					Prefetch_Cnt <= 0;
					if Char_Pos < Text_Length then
						Char_Pos := Char_Pos + 1;
						Char_Code := character'pos(Text_Cont(Char_Pos));
						Address <= Char_Code * 16 + (Y_Pos - Text_Pos.Y);
					end if;
				else
					Prefetch_Cnt <= Prefetch_Cnt + 1;
				end if;
			else
				Prefetch_Cnt <= 7;
				Char_Pos := 0;
			end if;
			
			-- The ROM clocked in the correct font data in the last cycle,
			-- so in this cycle (1 pixel before target pixel)
			-- we can set it for the drawing on the next cycle
			if X_Pos = Text_Pos.X + (8 * (Char_Pos - 1)) - 1 then
				Font_Row <= Next_Font_Row;
			end if;
			
			-- X ist im Text
			if X_Pos >= Text_Pos.X and X_Pos < Text_Pos.X + (8 * Text_Length) and Y_Pos >= Text_Pos.Y and Y_Pos < Text_Pos.Y + 16 then
				-- Pro cycle den bit counter von 0 - 7 durchzaehlen
				-- Bei 7 kommt der naechste Buchstabe
				if Bit_Pos = 7 then
					Bit_Pos <= 0;
				else
					Bit_Pos <= Bit_Pos + 1;
				end if;
				
				-- Set Pixel_On to the current value in Font_Row
				-- 1 = Pixel in text, 0 = Pixel not in text
				-- Bit position is inverted because bit 7 is the first bit
				Pixel_On <= Font_Row(7 - Bit_Pos);
			else
				Bit_Pos <= 0;
			end if;
			
			if Reset = '1' then
				Bit_Pos <= 0;
				Address <= 0;
				Char_Code := 0;
				Char_Pos := 0;
			end if;
		end if;
	end process;

end Beh_VGA_Text;
