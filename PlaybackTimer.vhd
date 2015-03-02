LIBRARY	ieee;
USE		ieee.std_logic_1164.all;
USE 		ieee.numeric_std.all;

ENTITY PlaybackTimer IS
	PORT(
		Clock, Increment, Decrement, Reset : IN std_logic;
		
		H, HH, M, MM, S, SS : OUT std_logic_vector(3 downto 0)
	);
END;

ARCHITECTURE Boolean_Logic_Description OF PlaybackTimer IS
shared variable TempH, TempHH, TempM, TempMM, TempS, TempSS : std_logic_vector(3 downto 0) := "0000";


BEGIN
	process(Clock, Reset)
		constant zero: std_logic_vector(3 downto 0) := "0000";
		constant one: std_logic_vector(3 downto 0) := "0001";		
		constant five: std_logic_vector(3 downto 0) := "0101";
		constant nine: std_logic_vector(3 downto 0) := "1001";		
		
	begin	
	
	if (rising_edge(clock)) then
		if (Reset = '0') then
			TempH := zero;
			TempHH := zero;
			TempM := zero;
			TempMM := zero;
			TempS := zero;
			TempSS := zero;
		else
			if(Increment = '1') then
				if(TempS = five AND TempSS = nine) then
					if(TempM = five AND TempMM = nine) then
						if(TempHH = nine) then
							TempH := std_logic_vector(unsigned(TempH) + unsigned(one));
							TempHH := zero;
						else
							TempHH := std_logic_vector(unsigned(TempHH) + unsigned(one));
						end if;
						TempM := zero;
						TempMM := zero;
					elsif(TempMM = nine) then
						TempM := std_logic_vector(unsigned(TempM) + unsigned(one));
						TempMM := zero;
					else
						TempMM := std_logic_vector(unsigned(TempMM) + unsigned(one));						
					end if;
					TempS := zero;
					TempSS := zero;
				elsif(TempSS = nine) then
					TempS := std_logic_vector(unsigned(TempS) + unsigned(one));
					TempSS := zero;
				else
					TempSS := std_logic_vector(unsigned(TempSS) + unsigned(one));
				end if;
			elsif(Decrement = '1') then
--looks exactly like increment except replace carry condition with 00 instead of 59 and set carried value to 59 instead of 00	
				if(TempS = zero AND TempSS = zero) then
					if(TempM = zero AND TempMM = zero) then
						if(TempHH = zero) then
							TempH := std_logic_vector(unsigned(TempH) - unsigned(one));
							TempHH := nine;
						else
							TempHH := std_logic_vector(unsigned(TempHH) - unsigned(one));
						end if;
						TempM := five;
						TempMM := nine;
					elsif(TempMM = zero) then
						TempM := std_logic_vector(unsigned(TempM) - unsigned(one));
						TempMM := nine;
					else
						TempMM := std_logic_vector(unsigned(TempMM) - unsigned(one));						
					end if;
					TempS := five;
					TempSS := nine;
				elsif(TempSS = zero) then
					TempS := std_logic_vector(unsigned(TempS) - unsigned(one));
					TempSS := nine;
				else
					TempSS := std_logic_vector(unsigned(TempSS) - unsigned(one));
				end if;	
			end if;
		end if;
		H <= TempH;
		HH <= TempHH;
		M <= TempM;
		MM <= TempMM;
		S <= TempS;
		SS <= TempSS;
	end if;
	
	end process;
END;