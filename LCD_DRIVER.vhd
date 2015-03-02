LIBRARY 	ieee;
USE 		ieee.std_logic_1164.all;
use 		ieee.std_logic_arith.all; 
use 		ieee.std_logic_unsigned.all; 

-----------------------------------------------------------------------------------------------------
ENTITY LCD_DRIVER IS
	PORT ( 		
				E 		: out std_logic ;						-- E (Enable) signal to the LCD display
				RW 		: out std_logic ;						-- Read(1)/Write(0) signal to the LCD display, set to 0 when writing characters commands, 1 when reading status
				RS 		: out std_logic ;
				Ready	: out std_logic ;
				DataOut	: out std_logic_vector(7 downto 0) ;	-- ascii or command data out to LCD display
				
				Clk 	: in std_logic ;						-- 25MHz clock driving state machine
				Reset	: in std_logic ;						-- Reset (logic 0) to initialise the state machine and to force initialisation of the LCD display
				Start 	: in std_logic ;							-- start Signal (logic 0) to the State machine to write char to the LCD display
				DataOrCommand : in std_logic ;					-- 1 = data, 0 = command
				DataIn	: in std_logic_vector(7 downto 0) 		-- ascii or command data in from switches
		);
END ;

-----------------------------------------------------------------------------------------------------
	
ARCHITECTURE behaviour OF LCD_DRIVER IS 

-- define a set of names and state values for the states that the state machine can be in 
-- used for signals Next_State and Current_State below

	CONSTANT S0 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000" ;
	CONSTANT S1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001" ;
	CONSTANT S2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010" ;
	CONSTANT S3 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011" ;
	CONSTANT S4	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100" ;
	CONSTANT S5 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101" ;
	CONSTANT S6 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110" ;
	CONSTANT S7 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111" ;
	CONSTANT S8 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000" ;
	
-- signals connecting processes in the circuit together

    Signal Next_state 		: STD_LOGIC_VECTOR(3 DOWNTO 0);			-- Next state records which state the machine will go to next when the CLK occurs, can be assigned one of the names defined above
	Signal Current_state  	: STD_LOGIC_VECTOR(3 DOWNTO 0);		-- current state records the current state of the state machine, can be assigned one of the names defined above
	
-- signals associated with 2ms Timer
	Signal StartLCDClk, EndLCDClk 	: std_logic ;
	
BEGIN

-----------------------------------------------------------------------------------------------------------------------------
-- concurrent process#3 : counter to simulate time delay of at least 5ms (min 125,000 clock cycles at 25Mhz)	
-- this is used to ensure a delay between writing data to the LCD display. The longest command takes 4.1 ms during initialisation according to 
-- LCD data sheet
-----------------------------------------------------------------------------------------------------------------------------

   Process(Clk, StartLCDClk)
		variable timeLCDClk : integer range 0 to 128000 ;
	BEGIN
		if(StartLCDClk = '1') then
			timeLCDClk  := 125000 ;	
		elsif (rising_edge(Clk) and (timeLCDClk /= 0)) then
			timeLCDClk := timeLCDClk - 1 ;
		end if;
			
		if(timeLCDClk = 0) then
			EndLCDClk <= '1' ;				-- if time elapsed, signal it
		else
			EndLCDClk <= '0' ;
		end if ;
	END Process;	
	
---------------------------------------------------------------------------------------------------------------------
-- concurrent process #2: state registers
-- this process RECORDS the current state of the system.
-- it can be reset to the IDLE state S0 when presented with the signal 'Reset' 
--
-- Otherwise on the rising edge of the CLK the system will always transfer the value of Next_State 
-- signals to Current-State signal and change the state of the state machine
-- The decision about what is the Next-State is made by another process below
----------------------------------------------------------------------------------------------------------------------

   Process(Clk)
	BEGIN
		if (rising_edge(Clk)) then				-- state can change only on low-to-high transition of clock
			if(Reset = '0') then
				Current_state <= S0 ;			-- return to state S0			
			else
				Current_state <= Next_State;
			end if ;
		end if;
	END Process;	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- concurrent process#1: Combinatorial Logic to define the signals that drive the next state based only on the current state and signal Start
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	Process(Current_state, Start, EndLCDClk)
    BEGIN
		Next_State <= S0 ;								-- default next state value overridden below (prevent latches being inferred for Next State and keeps it combinatorial logic
		
		if( Current_state = S0) then					-- if we are in the idle state (doing nothing)
			if(Start = '0')  then						-- if we get the signal to begin writing to the LCD display
				Next_State <= S1 ;						-- Signal to state register that our next state should be S1 otherwise stay in S0
			end if ;
			
		elsif(current_state = S1) then			
			Next_State <= S2 ;	

		elsif(current_state = S2) then					
			Next_State <= S3 ;							

		elsif(current_state = S3) then					
			Next_State <= S4 ;		
		
		elsif(current_state = S4) then					
			Next_State <= S5 ;	
			
		elsif(current_state = S5) then					
			Next_State <= S6 ;		

		elsif(current_state = S6) then					
			Next_State <= S7 ;
			
		elsif(current_state = S7) then					
			Next_State <= S8 ;						
		
		elsif(current_state = S8) then					
			if(EndLCDClk /= '1') then						-- if 4ms timer has NOT elapsed stay here, default is to return to S0
				Next_State <= S8 ;					 	
			end if ;
		end if;
	end process ;
				
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- concurrent process #3: Combinatorial Logic to define the signals that drive the outputs to the LCD display based only on the current state
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	Process(Current_state, DataOrCommand, DataIn )
    BEGIN
		RS <= DataOrCommand ;
		DataOut <= DataIn ;
		StartLCDClk <= '0';									-- disable 4ms timer clock
    
		if(Current_state = S0)	then
			E <= '0' ;
			RW <= '1' ;
			Ready <= '1' ;
			StartLCDClk <= '1';								-- load 4ms timer clock
		elsif(Current_state = S1)	then
			E <= '0' ;
			RW <= '0' ;
			Ready <= '0' ;
		elsif(Current_state = S2)	then
			E <= '1' ;
			RW <= '0' ;	
			Ready <= '0' ;
		elsif(Current_state = S3)	then
			E <= '1' ;
			RW <= '0' ;	
			Ready <= '0' ;			
		elsif(Current_state = S4)	then
			E <= '1' ;
			RW <= '0'; 
			Ready <= '0' ;
		elsif(Current_state = S5)	then
			E <= '1' ;
			RW <= '0' ;	
			Ready <= '0' ;			
		elsif(Current_state = S6)	then
			E <= '1' ;
			RW <= '0' ;
			Ready <= '0' ;
		elsif(Current_state = S7)	then
			E <= '1' ;
			RW <= '0' ;
			Ready <= '0' ;
		else						-- state S8
			E <= '0' ;
			RW <= '0' ;
			Ready <= '0' ;				
		end if ;
	END Process ;
END ;