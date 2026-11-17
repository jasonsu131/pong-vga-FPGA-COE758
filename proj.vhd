library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.vga_pkg.ALL;

entity proj is
	port (
		-- 50 MHz board clock (C9)
		clk     : in  std_logic;

		-- Player switches
		SW0     : in  std_logic;   -- left player up    (N17)
		SW1     : in  std_logic;   -- left player down  (H18)
		SW2     : in  std_logic;   -- right player up   (L14)
		SW3     : in  std_logic;   -- right player down (L13)
	
		-- VGA sync, active low
		H       : out std_logic;   -- horizontal sync (C5)
		V       : out std_logic;   -- vertical sync   (D5)

		-- Pixel clock for the video DAC (A4)
		DAC_CLK : out std_logic;

		-- 8-bit colour channels to the DAC
		Rout    : out std_logic_vector(7 downto 0);
		Gout    : out std_logic_vector(7 downto 0);
		Bout    : out std_logic_vector(7 downto 0)
	);
end proj;

architecture Behavioral of proj is
    -- Divided clock
	signal clk_25mhz  : std_logic;
	 
    -- vga synchronous signals
    signal hcount     : integer range 0 to H_TOTAL - 1;
    signal vcount     : integer range 0 to V_TOTAL - 1;
    signal video_on   : std_logic;
    signal frame_tick : std_logic;

    -- game logic signals
    signal ball_x     : integer range -BALL to H_VISIBLE - 1;
    signal ball_y     : integer range     0 to V_VISIBLE - 1;
    signal p1_y       : integer range 0     to V_VISIBLE - 1;
    signal p2_y       : integer range 0     to V_VISIBLE - 1;
    signal goal       : std_logic;

begin
	
	u_clk_div : entity work.clk_div
    port map (
      clk_in  => clk,
      clk_out => clk_25mhz
    );

    DAC_CLK <= clk_25mhz;

    u_vga_sync : entity work.vga_sync
    port map (
      clk_25mhz  => clk_25mhz,
		hcount     => hcount,
		vcount     => vcount,
		hsync      => H,
		vsync      => V,
		video_on   => video_on,
		frame_tick => frame_tick
    );

    u_pixel_gen : entity work.pixel_gen
    port map (
        clk_25mhz => clk_25mhz,
        hcount    => hcount,
        vcount    => vcount,
        video_on  => video_on,
        ball_x    => ball_x,
        ball_y    => ball_y,
        p1_y      => p1_y,
        p2_y      => p2_y,
        goal      => goal,
        red       => Rout,
        green     => Gout,
        blue      => Bout
    );

    u_game_logic : entity work.game_logic
    port map (
        clk_25mhz  => clk_25mhz,
        frame_tick => frame_tick,
        SW0        => SW0,
        SW1        => SW1,
        SW2        => SW2,
        SW3        => SW3,
        ball_x     => ball_x,
        ball_y     => ball_y,
        p1_y       => p1_y,
        p2_y       => p2_y,
        goal       => goal 
    );
    
end Behavioral;