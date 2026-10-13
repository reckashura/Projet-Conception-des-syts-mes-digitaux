--Programme: Module de gestion d'un servo-moteur pour logique_principale
--Description: Ce module permet de faire la rotation d'un servo-moteur selon la position désirée
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Signal_servo is
	port(
		clk : in STD_LOGIC; 
		
		activated : in STD_LOGIC;
		
		servo_pwm : out STD_LOGIC
	);
end Signal_servo;

architecture Bhv_Signal_servo of Signal_servo is
	constant clk_frequency : integer := 50000000; -- periode de l'horloge 50 MHz
	constant pwm_period : integer := 1000000; -- periode de 20 ms entre chaque --50MHz*20ms
	constant impulsion_min : integer := 50000; -- pulsation minimal de 1ms (position minimale) --50MHz*1ms
	constant impulsion_max : integer := 100000; -- pulsation maximale de 2ms pour la position maximale --50MHz*2ms
	
	signal position : integer := 0;
	signal counter : integer range 0 to pwm_period-1 := 0; --Compteur pour l'emission du signal
	signal pulse_width : integer := impulsion_min; --Largeur du signal envoyé
	signal pwm_signal : std_logic := '0'; --Signal du PWM interne
	
begin
	process(clk)	--processus pour déterminer la longueur du signal selon la position désirée
	begin
		if (rising_edge(clk)) then 
			if (activated='1') then
				position <= 120; --position barriere abaissée
			else
				position <= 0; --position barriere levée
			end if;

			--Remettre le compteur à 0 pour chaque période (20ms)
			if (counter >= pwm_period-1) then
				counter <= 0;
			else 
				counter <= counter+1;
			end if;
			
			pulse_width <= impulsion_min + ((position) * (impulsion_max-impulsion_min)/180);
			
			if (counter < pulse_width) then 
				pwm_signal <= '1';
			else
				pwm_signal <= '0';
			end if;
		end if;
	end process;
	
	servo_pwm <= pwm_signal;
	
end Bhv_Signal_servo;
			