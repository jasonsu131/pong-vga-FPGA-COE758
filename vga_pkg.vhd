library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package vga_pkg is
  constant H_VISIBLE : integer := 640;
  constant H_FRONT   : integer := 16;
  constant H_SYNC    : integer := 96;
  constant H_BACK    : integer := 48;
  constant H_TOTAL   : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK;  -- 800

  constant V_VISIBLE : integer := 480;
  constant V_FRONT   : integer := 10;
  constant V_SYNC    : integer := 2;
  constant V_BACK    : integer := 33;
  constant V_TOTAL   : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK;  -- 525

  constant HS_START  : integer := H_VISIBLE + H_FRONT;
  constant HS_END    : integer := HS_START + H_SYNC;
  constant VS_START  : integer := V_VISIBLE + V_FRONT;
  constant VS_END    : integer := VS_START + V_SYNC;

  -- field
  constant BORDER   : integer := 8;     -- border thickness in pixels
  constant MARGIN   : integer := 16;   -- green strip outside the border
  constant GATE_T   : integer := 180;   -- gate opening in the side borders
  constant GATE_B   : integer := 300;   -- (first row past the gate)
  constant MIDDLE_V : integer := V_VISIBLE / 2;   -- (first row past the gate)
  constant MIDDLE_H : integer := H_VISIBLE / 2;   -- (first row past the gate)
  constant CIRCLE_R : integer := 60;                       -- outer radius
  constant CIRCLE_T : integer := 3;                        -- line thickness
  
  -- outer and inner edges of the white frame
  constant OUT_L    : integer := MARGIN;                   -- 16
  constant IN_L     : integer := MARGIN + BORDER;          -- 24
  constant OUT_R    : integer := H_VISIBLE - MARGIN;       -- 624
  constant IN_R     : integer := OUT_R - BORDER;           -- 616
  constant OUT_T    : integer := MARGIN;                   -- 16
  constant IN_T     : integer := MARGIN + BORDER;          -- 24
  constant OUT_B    : integer := V_VISIBLE - MARGIN;       -- 464
  constant IN_B     : integer := OUT_B - BORDER;           -- 456

  -- paddles
  constant PAD_W    : integer := 10;
  constant PAD_H    : integer := 60;
  constant P1_X     : integer := 40;    -- left paddle's left edge
  constant P2_X     : integer := 590;   -- right paddle's left edge

  -- ball
  constant BALL     : integer := 20;    -- ball is 10x10
  constant SPD      : integer := 3;     -- ball speed is 3 pixles per frame tick

  subtype colour_t is std_logic_vector(23 downto 0);   -- R(23..16) G(15..8) B(7..0)

  constant C_BLACK  : colour_t := x"000000";
  constant C_WHITE  : colour_t := x"FFFFFF";
  constant C_GREEN  : colour_t := x"00FF00";
  constant C_YELLOW : colour_t := x"FFFF00";
  constant C_RED    : colour_t := x"FF0000";
  constant C_BLUE   : colour_t := x"0000FF";
  constant C_PURPLE : colour_t := x"800080";
  constant C_PINK   : colour_t := x"FF00FF";
end package;