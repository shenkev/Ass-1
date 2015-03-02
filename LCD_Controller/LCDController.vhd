LIBRARY ieee;
USE ieee.std_logic_1164.all;

USE IEEE.NUMERIC_STD.ALL ;



ENTITY LCDController IS
	PORT( 	
		Clk 				: IN STD_LOGIC ;
		Reset_L 			: IN STD_LOGIC ;
		WriteString 	: IN STD_LOGIC ;							-- signal to the LCD_ controller telling it to write one string the LCD display (Currently set to push button PB1)
		MessageNumber	: IN std_logic_vector(3 downto 0);	-- integer is a new type in VHDL the range 0-15 means it is represented as a 34it unsigned quantity
																			-- this input is used to control which of 8 possible messages are displaye don the LCD display
																			-- currently it is wired to the switches SW0-2 on the DE2 board. Setting these 3 switches choses a message
		LcdReady 		: IN STD_LOGIC ;							-- signal from LCD controller to indicate it is ready to accept a character/command
		DataIn			: IN STD_LOGIC_VECTOR(7 downto 0);	-- data from message rom
								
		LcdStart 		: OUT STD_LOGIC ;							-- signal to LCD controller to write one single character, 0 = START, 1 = NO START
		DataOrCommand 	: OUT STD_LOGIC ;							-- indicates whether we are writing a command or an ASCII character to the display, 0 = command, 1 = data
		AddressOut 		: OUT std_logic_vector(9 downto 0);	-- the address in the memory of the ASCII character/command to be written to LCD diplay
		
		Ready				: OUT STD_LOGIC							-- signal to indicate that the LCD controller is ready to accept new write string commands
																			-- this signal would be used by whatever logic might be driving this controller.
	);
END;

ARCHITECTURE MealyModel OF LCDController IS

-- define a set of names and state values for the states that the state machine can be in 
-- used for signals Next_State and Current_State below

	CONSTANT RESET 									: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000" ;
	CONSTANT INITIALISING_DISPLAY 				: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001" ;
	CONSTANT WAITING_FOR_LCD_INITIALISATION 	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010" ;
	CONSTANT IDLE 										: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011" ;
	CONSTANT WRITING_STRING							: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100" ;
	CONSTANT WAITING_FOR_LCD						: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101" ;
	CONSTANT WAITING_FOR_WRITE_STRING_REMOVAL	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110" ;
		
-- signals connecting processes in the circuit together, i.e. state maching signals

   Signal Next_state 		: STD_LOGIC_VECTOR(3 DOWNTO 0);			-- Next state records which state the machine will go to next when the CLK occurs, can be assigned one of the names defined above
	Signal Current_state  	: STD_LOGIC_VECTOR(3 DOWNTO 0);			-- current state records the current state of the state machine, can be assigned one of the names defined above
	
	-----------------------------------------------------------------------------------------------------------------
	-- create a new data type called aString which is an array of 31 elements (0 to 30), where each 
	-- element is an unsigned 8 bit value  ideal for holding an ASCII character
	--
	--	Also create a new data type aStringArray which is an array of 8 'aString's 
	-- i.e. a two dimensional array of 16 x 30 characters where each character is 8 bits of unsigned data (i.e. ASCII)
	-----------------------------------------------------------------------------------------------------------------

	-- some signals
	
	signal Char_Count						: std_logic_vector(4 downto 0) ;		-- this signal is a 5 bit value that holds a index to a 32 char string 
	signal CountUp, CounterReset		: std_logic ;								-- controls the Char_Count signal
	
BEGIN
---------------------------------------------------------------------------------------------------------------------
-- concurrent process #1: state registers of a state machine
-- this process RECORDS the current state of the system.
-- it can be reset to the RESET state when presented with the signal 'Reset' 
--
-- Otherwise on the rising edge of the CLK the system will always transfer the value of Next_State 
-- signals to Current-State signal and change the state of the state machine
-- The decision about what is the Next-State is made by another process below
----------------------------------------------------------------------------------------------------------------------
   Process(Reset_L, Clk, Next_State)
	BEGIN
		if (rising_edge(Clk)) then			-- state can change only on low-to-high transition of clock
			if(Reset_L = '0') then			-- synchronous reset
				Current_state <= RESET ;
			else
				Current_state <= next_state;
			end if;
		end if ;
	END Process;	

----------------------------------------------------------------------------------------------------------------------	
-- concurrent process #2 : a counter
-- the value of this counter is used as the index into an array of characters within a message to select the character
-- to be send to the lcd display
-- is incremented after each character written
---------------------------------------------------------------------------------------------------------------------- 

   Process(Clk, CountUp, CounterReset)
	BEGIN
		if (falling_edge(Clk)) then
			if(CounterReset = '1') then				-- synchronous reset, i.e. effectively move to the start of a string/message
				Char_Count <= "00000";
			elsif(Countup = '1') then					-- when told to increment, add 1 to effectively move to the next character in the message/string
				Char_Count <= std_logic_vector(unsigned(Char_Count) + 1)  ;
			end if ;
		end if;
	END Process;		
	
 -- concurrent process#3: Logic to define signals that drive the data flow controller and set the next state
	
	Process(Current_state, Clk, WriteString, LCDReady, Char_Count, MessageNumber, DataIn)
	BEGIN
	--
	-- define default for all the signals driven by this process - override as necessary
	--
		DataOrCommand <= '1' ;			-- default = writing ASCII Data
		AddressOut <= '0' & MessageNumber & Char_Count ;				
		LcdStart <= '1' ;					-- default is no write operation to the LCD driver state machine
		CountUp <= '0' ;					-- default is no count
		CounterReset <= '0' ;			-- defult is no counter reset
		Next_State <= IDLE ;				-- default next state is IDLE
		Ready <= '0';						-- default for LCD controller is NOT ready
		
		
		------------------------------------------------------------------------------------------------------------------
		-- Enter this state after reset
		-- first we must initialise the LCD display by writing a number of commands to it, e.g.
		-- enable display, turn on/off cursor, font size, number of lines of display (2) etc and define what width of the
		-- LCD display digital interface, e.g. use a 4 or an 8 bit interface (we will use 8 bit)
		------------------------------------------------------------------------------------------------------------------
						
		if(current_state = RESET) then				-- if we are in the reset state (i.e. we have received a reset input from the user)
		   CounterReset <= '1' ;						-- while in this state keep resetting the counter acting as the index to the next character so that we index to the 1st character in the string
			Next_State <= INITIALISING_DISPLAY ;	-- on next clock move to the initialising display state where we write the initialisation string to the LCD driver and display

		-----------------------------------------------------------------------------------------------------------------
		-- enter this state to begin writing the initialisation string after reset
		-----------------------------------------------------------------------------------------------------------------
		elsif(current_state = INITIALISING_DISPLAY) then
			DataOrCommand <= '0' ;										-- this is a signal to indicate that we are now writing a command to the lcd display, not an ASCII char
			AddressOut <=  b"10000" & Char_Count ;					-- present an initialisation character to display driver			
			
			-- we have to make sure LCD driver/display is ready before we issue the start
			
			if(LcdReady = '1') then												-- make sure LCD driver logic ready to receive a char from this controller state machine
				if(DataIn /= X"00") then		-- as long as we have not got to the end of the initialisation string marked with a NUL
					LcdStart <= '0' ;												-- send a start command to lcd driver which in turn presents it to the display
					Next_State <= WAITING_FOR_LCD_INITIALISATION ;		-- now wait for the LCD driver to be ready for the next character
				else
					Next_State <= IDLE;									-- otherwise if we reach the end of the initialisation string we are done and we Idle
				end if ;
			else																-- otherwise if the LCD driver/display is not yet ready
				Next_State <= INITIALISING_DISPLAY;					-- stay in this state until LCD Ready						
			end if ;

		-----------------------------------------------------------------------------------------------------------------------
		-- enter here and wait for the display driver to acknowledge the character, written to the display
		-----------------------------------------------------------------------------------------------------------------------
		
		elsif(current_state = WAITING_FOR_LCD_INITIALISATION) then
			DataOrCommand <= '0' ;										-- still writing a command			
			AddressOut <=  b"10000" & Char_Count ;					-- present an initialisation character to display driver			
							
			if(LcdReady = '1') then										-- if LCD driver has finished sending to lcd display
				Countup <= '1' ;											-- send a signal to increment counter acting as the index to the initialisation string
				Next_State <= INITIALISING_DISPLAY ;				-- go to previous state and keep repeating characters
			else
				Next_State <= WAITING_FOR_LCD_INITIALISATION;	-- if LCD has not finished, stay here
			end if ;
		
		---------------------------------------------------------------------------------------------------------------
		-- enter this IDLE state and wait until PB0/PB1 is pressed
		---------------------------------------------------------------------------------------------------------------
		
		elsif(current_state = IDLE) then
			CounterReset <= '1' ;
			Ready <= '1';														-- LCD controller is only ready when int he idle state
			if(WriteString = '0')  then									-- if we get the signal from PB0 go write the message, it will keep writing it as long as we hold this down
				Next_State <= WRITING_STRING;								-- Got the write string signal, but first wait for it to be removed to avoid repeated writes
			else
				Next_State <= IDLE ;											-- if no signal from PB0 stay in the idle state
			end if ;
		
		---------------------------------------------------------------------------------------------------------------
		-- wait for the PB0/PB1 button to be removed
		---------------------------------------------------------------------------------------------------------------
--		elsif(current_state = WAITING_FOR_WRITE_STRING_REMOVAL) then
--			if(WriteString = '0') then									-- if signal from PB0 still present, wait here
--				Next_State <= WAITING_FOR_WRITE_STRING_REMOVAL ;
--			else	
--				Next_State <= WRITING_STRING ;							-- otherwise go write the string
--			end if ;
			
		----------------------------------------------------------------------------------------------------------------
		-- enter this state when we present the 1st character and signal LCD driver to start
		----------------------------------------------------------------------------------------------------------------
		elsif(current_state = WRITING_STRING) then
			AddressOut <=  '0' & MessageNumber & Char_Count ;					-- present an initialisation character to display driver			

			if(DataIn < X"20" OR DataIn > X"7F") then
				DataOrCommand <= '0' ;										-- this is Command data			
			else
				DataOrCommand <= '1' ;										-- this is ASCII data
			end if ;
				
			if(LcdReady = '1') then											-- make sure LCD driver logic ready to receive next character
				if(DataIn /= X"00") then									-- as long as we have not got to the end of the string marked with a NUL
					LcdStart <= '0' ;											-- signal the LCD driver module to start writing this character
					Next_State <= WAITING_FOR_LCD ;						-- now go to a state waiting for the LCD to be ready for the next character
				else
					Next_State <= IDLE;										-- if we reach the end of the string, return to Idle
				end if ;
			else
				Next_State <= WRITING_STRING;								-- stay here until LCD Ready						
			end if ;
		
		elsif(current_state = WAITING_FOR_LCD) then
			if(DataIn < X"20" OR DataIn > X"7F") then
				DataOrCommand <= '0' ;										-- this is Command data			
			else
				DataOrCommand <= '1' ;										-- this is ASCII data
			end if ;
			
			if(LcdReady = '1') then
				Countup <= '1' ;
				Next_State <= WRITING_STRING ;
			else
				Next_State <= WAITING_FOR_LCD;
			end if ;
		end if ;
	end Process ;
end ;	