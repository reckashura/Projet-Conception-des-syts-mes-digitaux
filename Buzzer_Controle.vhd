--Programme: Module de gestion d'un buzzer passif pour logique_principale
--Description: Ce module permet de faire «biper» un buzzer passif selon l'intervalle désiré
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Buzzer_Controle is
    Port (
        clk : in std_logic;                
        activated: in std_logic;
		  bip_intervalle: in integer;
		  buzzer_out : out std_logic         
    );
end Buzzer_Controle;

architecture Bhv_buzzer of Buzzer_Controle is
	signal counter2 : integer := 0; --counter pour créer l'intervalle de bip
	signal counter : integer := 0; --counter pour créer le signal variable  
	signal signal_out : std_logic := '0';    
	constant clk_freq: integer := 50000000; --50MHz

begin
	process(clk) 
	begin
		if rising_edge(clk) then
			if (activated = '1') then --si le buzzer est activé
				counter <= counter + 1;  
				counter2 <= counter2 +1;
				if (counter2 < (clk_freq *bip_intervalle)) then
					if counter = (clk_freq / 1000) then 
						signal_out <= NOT signal_out; --inversion de signal_out chaque ms (signal carré)
						counter <= 0; 
					end if; --entre clk_freq*bip_intervalle et clk_freq*bip_intervalle*2, c'est silencieux
				elsif (counter2 = (clk_freq *bip_intervalle*2)) then --recommencer le cycle
					signal_out <= '0';
					counter2 <= 0;
					counter <= 0;    
				end if;
			else --si activated ='0'
				counter <= 0;  
				counter2 <= 0;				
				signal_out <= '0'; 
         end if;
		end if;
	end process;

	buzzer_out <= signal_out; 

end Bhv_buzzer;