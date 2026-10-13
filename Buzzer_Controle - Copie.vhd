library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Buzzer_Controle is
    Port (
        clk : in std_logic;                
        activated: in std_logic;
		  buzzer_out : out std_logic         
    );
end Buzzer_Controle;

architecture Bhv_buzzer of Buzzer_Controle is
	signal counter : integer := 0;           
	signal signal_out : std_logic := '0';    
	constant clk_freq: integer := 50; --50MHz
	constant bip_intervalle: integer := 10000000; --1 seconde

begin
    process(clk) 
    begin
        if rising_edge(clk) then
		if (activated = '1') then
                	counter <= counter + 1;  
			if counter = (clk_freq * bip_intervalle) then 
               			signal_out <= NOT signal_out; 
				counter <= 0; 
			end if;     
           	else
                	counter <= 0;             
                	signal_out <= '0'; 
            	end if;
        end if;
    end process;

    buzzer_out <= signal_out; 

end Bhv_buzzer;