library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.vga_pkg.ALL;

entity pixel_gen is
  port (
    clk_25mhz : in  std_logic;
    hcount    : in  integer range 0 to H_TOTAL - 1;
    vcount    : in  integer range 0 to V_TOTAL - 1;
    video_on  : in  std_logic;

    -- object positions (from game_logic later; constants for now)
    ball_x    : in  integer range -BALL to H_VISIBLE-1;
    ball_y    : in  integer range     0 to V_VISIBLE-1;
    p1_y      : in  integer range     0 to V_VISIBLE-1;
    p2_y      : in  integer range     0 to V_VISIBLE-1;
    goal      : in  std_logic;
    red       : out std_logic_vector(7 downto 0);
    green     : out std_logic_vector(7 downto 0);
    blue      : out std_logic_vector(7 downto 0)
  );
end pixel_gen;

architecture Behavioral of pixel_gen is
    signal rgb : colour_t := C_BLACK;
	 signal cx  : integer range -H_VISIBLE to H_VISIBLE;
    signal cy  : integer range -V_VISIBLE to V_VISIBLE;
    signal d2  : integer range 0 to 2 * H_VISIBLE * H_VISIBLE;

begin

    u_draw_field : process (clk_25mhz) begin
        if rising_edge (clk_25mhz) then
		      cx <= hcount - MIDDLE_H;
            cy <= vcount - MIDDLE_V;
            d2 <= cx * cx + cy * cy;
				
            -- black
            if video_on = '0' then
                rgb <= C_BLACK;

            -- yellow ball
            elsif hcount >= ball_x and hcount < ball_x + BALL and
                  vcount >= ball_y and vcount < ball_y + BALL then
                -- red if goal
                if goal = '1' then
                    rgb <= C_RED;
                else
                    rgb <= C_YELLOW;
                end if;

            -- L paddle blue
            elsif hcount >= P1_X and hcount < P1_X + PAD_W and
                  vcount >= p1_y and vcount < p1_y + PAD_H then
                  rgb <= C_BLUE;
            -- R paddle purple
            elsif hcount >= P2_X and hcount < P2_X + PAD_W and
                  vcount >= p2_y and vcount < p2_y + PAD_H then
                  rgb <= C_PURPLE; 
        
            -- field and borders    
            -- top  white border
            elsif vcount >= OUT_T and vcount < IN_T and hcount >= OUT_L and hcount < OUT_R then
                rgb <= C_WHITE;
            -- bottom white border
            elsif vcount >= IN_B and vcount < OUT_B and hcount >= OUT_L and hcount < OUT_R then
                rgb <= C_WHITE;
            -- left white border with gate
            elsif hcount < IN_L and hcount >= OUT_L and vcount >= OUT_T and vcount < OUT_B 
                  and not (vcount >= GATE_T and vcount < GATE_B) then
                  rgb <= C_WHITE;
            -- right white border with gate
            elsif hcount >= IN_R and hcount < OUT_R and vcount >= OUT_T and vcount < OUT_B 
                  and not (vcount >= GATE_T and vcount < GATE_B) then
                  rgb <= C_WHITE;
				-- line in the middle
            elsif hcount >= MIDDLE_H - 1 and hcount <= MIDDLE_H + 1
                  and (vcount >= IN_T and vcount < IN_B) then
                  rgb <= C_WHITE;
				elsif d2 < CIRCLE_R * CIRCLE_R and
                  d2 >= (CIRCLE_R - CIRCLE_T) * (CIRCLE_R - CIRCLE_T) then
						rgb <= C_WHITE;
            -- green field everywhere else
            else
              rgb <= C_GREEN;
            end if;
        end if;
    end process u_draw_field; 
    
    red   <= rgb(23 downto 16);
    green <= rgb(15 downto 8);
    blue  <= rgb(7  downto 0);

end Behavioral;