library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
	port (
		clk_in  : in std_logic;
		clk_out : out std_logic
	);
end clk_div;

architecture Behavioral of clk_div is
	signal clk_temp : std_logic := '0';

begin
  process (clk_in) begin
	if rising_edge(clk_in) then 
		clk_temp <= not clk_temp; 
	end if;
  end process;
  
  clk_out <= clk_temp;

end Behavioral;