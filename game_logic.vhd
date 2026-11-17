library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.vga_pkg.ALL;

entity game_logic is
  port (
    clk_25mhz  : in  std_logic;
    frame_tick : in  std_logic;
    SW0        : in  std_logic;
    SW1        : in  std_logic;
    SW2        : in  std_logic;
    SW3        : in  std_logic;
    ball_x     : out integer range -BALL to H_VISIBLE;  -- can go off-screen through a gate
    ball_y     : out integer range 0 to V_VISIBLE - 1;
    p1_y       : out integer range 0 to V_VISIBLE - 1;
    p2_y       : out integer range 0 to V_VISIBLE - 1;
    goal       : out std_logic
  );
end game_logic;

architecture Behavioral of game_logic is
    signal dx       : integer range -SPD to SPD := SPD;
    signal dy       : integer range -SPD to SPD := SPD;

    signal ball_x_i : integer range -BALL to H_VISIBLE := MIDDLE_H;
    signal ball_y_i : integer range 0 to V_VISIBLE - 1 := MIDDLE_V;
    signal p1_y_i   : integer range 0 to V_VISIBLE - 1 := MIDDLE_V - PAD_H / 2;
    signal p2_y_i   : integer range 0 to V_VISIBLE - 1 := MIDDLE_V - PAD_H / 2;
    signal goal_i   : std_logic := '0';

    signal lfsr : std_logic_vector(15 downto 0) := x"ACE1";   -- any non-zero start
begin
    -- update game logic each frame tick
    u_game : process (clk_25mhz) begin
        if rising_edge (clk_25mhz) then
            if frame_tick = '1' then
                -- paddle controls 
                -- p1 up
                if SW0 = '1' and p1_y_i - 3 >= IN_T then
                    p1_y_i <= p1_y_i - 3;
                end if;
                -- p1 down
                if SW1 = '1' and p1_y_i + PAD_H + 3 <= IN_B then
                    p1_y_i <= p1_y_i + 3;
                end if;
                -- p2 up
                if SW2 = '1' and p2_y_i - 3 >= IN_T then
                    p2_y_i <= p2_y_i - 3;
                end if;
                -- p2 down
                if SW3 = '1' and p2_y_i + PAD_H + 3 <= IN_B then
                    p2_y_i <= p2_y_i + 3;
                end if;
                
                -- ball movement and bounce
                if goal_i = '0' then
                    -- top border
                    if (dy < 0 and ball_y_i + dy < IN_T) or
                       (dy > 0 and ball_y_i + BALL + dy > IN_B) then
                        dy <= -dy;
                    else
                        ball_y_i <= ball_y_i + dy;
                    end if;
                    -- horizontal border or paddles
                    if (dx < 0 and ball_x_i + dx < IN_L) or
                       (dx > 0 and ball_x_i + BALL + dx > IN_R) then
                        if ball_y_i >= GATE_T and ball_y_i + BALL <= GATE_B then
                            goal_i   <= '1';
                            ball_x_i <= ball_x_i + dx;
                        else
                            dx <= -dx;
                        end if;
                    elsif
                       -- p1 paddle
                       (dx < 0 and ball_x_i + dx < P1_X + PAD_W and ball_x_i >= P1_X + PAD_W and
                        ball_y_i + BALL > p1_y_i and ball_y_i < p1_y_i + PAD_H) or
                       -- p2 paddle
                       (dx > 0 and ball_x_i + BALL + dx > P2_X and ball_x_i + BALL <= P2_X and
                        ball_y_i + BALL > p2_y_i and ball_y_i < p2_y_i + PAD_H) then
                        dx <= -dx;
                    else
                        ball_x_i <= ball_x_i + dx;
                    end if;
                end if;
                
                -- GOAL!
                -- uses pseudo random generator to choose ball spawn and direction
                if goal_i = '1' then
                    if ball_x_i + dx <= -BALL or ball_x_i + dx >= H_VISIBLE then
                        ball_x_i <= MIDDLE_H;
                        ball_y_i <= MIDDLE_V - 128 + to_integer(unsigned(lfsr(7 downto 0)));
                        if lfsr(8) = '1' then
                            dx <= SPD;
                        else
                            dx <= -SPD;
                        end if;
                        if lfsr(9) = '1' then
                            dy <= SPD;
                        else
                            dy <= -SPD;
                        end if;
                        goal_i <= '0';
                    else
                        ball_x_i <= ball_x_i + dx;
                        ball_y_i <= ball_y_i + dy;
                    end if;
                end if;

            end if;
        end if;
    end process u_game;

    p1_y   <= p1_y_i;
    p2_y   <= p2_y_i;
    ball_x <= ball_x_i;
    ball_y <= ball_y_i;
    goal   <= goal_i;

    -- free-running pseudo-random generator (taps 16,14,13,11 = max length)
    rng : process (clk_25mhz)
    begin
      if rising_edge(clk_25mhz) then
        lfsr <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));
      end if;
    end process rng;
end Behavioral;