--Programme: Module permettant d'activer et désactiver le système pour logique_principale
--Description: Ce module permet d'activer le système si le bon pin d'activation est entré ou de désactiver
-- le système si le bon pin de désactivation est entré. Si le système est bien activé, les LED situées au dessus
-- des interrupteurs de pin sont allumées.
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Pin_controle is
    Port (
        clk : in  std_logic;               
        interrupteurs : in  std_logic_vector(3 downto 0); 
        led : out std_logic_vector(3 downto 0);  
        system : out std_logic);
end Pin_controle;

architecture Bhv_pin of Pin_controle is
	constant pin_code_activation : std_logic_vector(3 downto 0) := "0100";
	constant pin_code_desactivation : std_logic_vector(3 downto 0) := "0010";
	signal s_system: std_logic:= '0';
	
	begin
		system <= s_system;
		process(clk)
		begin
		if (rising_edge(clk)) then
				if (interrupteurs = pin_code_activation and s_system = '0') then --si le pin d'activation est entré
					s_system <= '1';  --active système
					led <= (others => '1'); --allume les led    
            elsif (interrupteurs = pin_code_desactivation and s_system = '1') then --si le pin de désactivation est entré
					s_system <= '0';  -- désactive système 
					led <= (others => '0');  -- éteint les led
				end if;
		end if;
	end process;
    --si un autre pin que les deux mentionnées plus haut sont entrés, le système reste dans son état précédent
end Bhv_pin;