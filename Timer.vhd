LIBRARY	ieee;
USE		ieee.std_logic_1164.all;
USE 		ieee.numeric_std.all;

ENTITY Timer IS
	PORT(
		Clock, Load: IN std_logic;
		Mode: IN std_logic_vector(1 downto 0);
		Done: OUT std_logic
	
	);
END;

ARCHITECTURE Behavioural OF Timer IS
	SIGNAL Count : unsigned(25 downto 0);

BEGIN
	process(Clock)
		--modes are one = 1s two = 1/5 s three = 1/100 s
		constant one: std_logic_vector(1 downto 0) := "01";		
		constant two: std_logic_vector(1 downto 0) := "10";
		constant three: std_logic_vector(1 downto 0) := "11";			
	begin	
		if(rising_edge(Clock)) then
			if(Load = '1' AND Mode = one) then
				Count <= "10111110101111000010000000";
				--for testing
				--Count <= "00000000000000000000001111";
			elsif(Load = '1' AND Mode = two) then
				Count <= "00100110001001011010000000";
				--Count <= "00000000000000000000000111";
			elsif(Load = '1' AND Mode = three) then
				Count <= "00000001111010000100100000";
				--Count <= "00000000000000000000000011";
			elsif(Count > 0) then
				Count <= Count - 1;
			end if;
		end if;
	end process;
	
	process(Count)
	begin
		if(Count = 0) then
			Done <= '1';
		else
			Done <= '0';
		end if;
	end process;
END;