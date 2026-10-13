--Programme: Module de gestion du capteur ultrason pour logique_principale
--Description: Ce module est divisé en deux processus. Le premier permet d'envoyer un signal via trig pendant 10us
-- et ce, à chaque 20000us. Le deuxième permet de vérifier le signal reçu sur echo pour calculer la distance captée.
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

Library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ultrason is
	port(
		trig: out std_logic; 
		echo: in std_logic;
		clk: in std_logic;
		detected: out std_logic);
end ultrason;

architecture Bhv_ultrason of ultrason is
	constant clk_freq : integer := 50000000; --50MHz
	constant trig_high_duree: integer := 10; --en microsecondes
	constant vitesse_son: integer:= 340; --en m/s
	constant delai_mesure: integer:= 20000; --en microsecondes

	signal trig_counter: integer:= 0;
	signal pulse_counter: integer:= 0;
	signal measuring: boolean:= false; --booléen qui dit si on est en train de mesurer ou non
	signal distance: integer:=20;

begin
	--generer impulsion sur trig
	impulsion_trig: process(clk)
	begin
		if(rising_edge(clk)) then
			if trig_counter < (clk_freq *trig_high_duree/1000000) then --si trig n'est pas à 10us
				trig <= '1';
				trig_counter <= trig_counter+1;
			elsif trig_counter < ((clk_freq/1000000)*delai_mesure) then --quand trig atteint 10us, arrêter trig
				trig <= '0';
				trig_counter <= trig_counter+1;
			elsif trig_counter = ((clk_freq/1000000)*delai_mesure) then -- quand counter atteint 20000us, recommencer
				trig_counter <= 0;
			end if;
		end if;
	end process;

	--mesurer impulsion sur echo
	impulsion_echo: process(clk)
	begin
		if(rising_edge(clk)) then
			if (echo = '1' AND NOT measuring) then 
				measuring <= true;
			elsif (measuring) then
				if echo ='1' then
					pulse_counter <= pulse_counter+1;
				else
					distance <= ((pulse_counter*vitesse_son*100)/(2*clk_freq)); --distance en cm
					measuring <= false;
					pulse_counter <= 0;
				end if;
			end if;
		end if;
	end process;
	
	detected <= '1' when (distance < 10) else '0'; --le capteur détecte qqchose à moins de 10cm

end bhv_ultrason;