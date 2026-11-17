library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.vga_pkg.ALL;

entity vga_sync is
	port (
		clk_25mhz  : in  std_logic;
		hcount     : out integer range 0 to H_TOTAL-1;
		vcount     : out integer range 0 to V_TOTAL-1;
		hsync      : out std_logic := '0';
		vsync      : out std_logic := '0';
		video_on   : out std_logic := '0';
		frame_tick : out std_logic := '0'
	);
end vga_sync;

architecture Behavioral of vga_sync is
    signal hcount_i    : integer range 0 to H_TOTAL-1 := 0;
    signal vcount_i    : integer range 0 to V_TOTAL-1 := 0;

begin

	-- hcount and vcount counters 
	process (clk_25mhz) begin
        if rising_edge(clk_25mhz) then
		    if hcount_i = H_TOTAL - 1 then
		    	hcount_i <= 0;
		    	if vcount_i = V_TOTAL - 1 then
		    		vcount_i <= 0;
		    	else
		    		vcount_i <= vcount_i + 1;
		    	end if;
		    else
		    	hcount_i <= hcount_i + 1; 
		    end if;
	
		    -- sync region
		    if hcount_i >= HS_START and hcount_i < HS_END then
		    	hsync <= '0';
		    else
		    	hsync <= '1';
		    end if;
		
		    if vcount_i >= VS_START and vcount_i < VS_END then
		    	vsync <= '0';
		    else
		    	vsync <= '1';
		    end if;
	
		    -- visible region
		    if hcount_i < H_VISIBLE and vcount_i < V_VISIBLE then
		    	video_on <= '1';
		    else
		    	video_on <= '0';
		    end if;
	
		    -- end of frame
		    if hcount_i = 0 and vcount_i = V_VISIBLE then
		    	frame_tick <= '1';
		    else
		    	frame_tick <= '0';
		    end if;
        end if;
	end process;
	
    hcount <= hcount_i;
    vcount <= vcount_i;
end Behavioral;