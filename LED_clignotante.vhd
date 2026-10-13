--Programme: Module permettant de faire clignoter une LED pour logique_principale
--Description: Ce module permet de faire clignoter une LED selon l'intervalle désiré
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LED_clignotante is
    Port (
        clk : in std_logic;   
		  activated: in std_logic;            
        led_out : out std_logic               
    );
end LED_clignotante;

architecture Bhv_LED of LED_clignotante is
    signal counter : integer := 0;       
    signal led_state : std_logic; 
    constant clk_freq : integer := 50000000; -- 50MHz
    constant clignotement_intervalle : integer := 1; --1 seconde

begin
	process(clk) 
	begin
	if (rising_edge(clk)) then
		if (activated = '1') then --si le clignotement est activé
			counter <= counter + 1;
			if counter = (clk_freq * clignotement_intervalle) then --si on est arrivé à 1 seconde, reset counter et inverser état de la led
				counter <= 0;             
				led_state <= NOT led_state; --inverser l'état de la led
			end if;
		else --si activated ='0'
			counter <= 0;             
			led_state <= '0';
		end if;
	end if;
	end process;

	led_out <= led_state;

end Bhv_LED;