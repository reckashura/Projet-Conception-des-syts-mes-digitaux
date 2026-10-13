--Programme: Module de gestion des afficheurs 7 segments de la carte pour logique_principale
--Description: Ce module permet d'allumer (0) et d'éteindre (1) chaque segment de chaque afficheur individuellement
-- selon ce qui est souhaité (go, StOP) ou bien d'éteindre tous les segments.
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity afficheur_mots is
    Port ( clk : in std_logic;
           activated : in std_logic; --si les afficheurs sont activés à StOP
			  eteindre: in std_logic; --si les afficheurs sont éteints
			  afficheur0: out std_logic_vector(6 downto 0);
			  afficheur1: out std_logic_vector(6 downto 0);
			  afficheur2: out std_logic_vector(6 downto 0);
			  afficheur3: out std_logic_vector(6 downto 0)
			  );
           
end afficheur_mots;

architecture Behavioral of afficheur_mots is
	 type segments_arrays is array(3 downto 0) of std_logic_vector (6 downto 0);
    signal display_segments : segments_arrays:= ("1111111","1111111","1111111","1111111");
	 
    -- Encodage des lettres
    function encode_letter (letter : integer) return std_logic_vector is
    begin
        case letter is
            when 0 => return "0010010"; -- S
            when 1 => return "0000111"; -- t (avec le segment inférieur activé)
            when 2 => return "1000000"; -- O
            when 3 => return "0001100"; -- P
            when 4 => return "0010000"; -- g 
				when 5 => return "0011100";-- o 
            when others => return "1111111"; -- Éteindre tous les segments
        end case;
    end function encode_letter;

begin
    process(clk)
    begin
        if rising_edge(clk) then
				if(eteindre ='1') then --éteindre tous les segments
					display_segments(0) <= "1111111";
					display_segments(1) <= "1111111";
					display_segments(2) <= "1111111";
					display_segments(3) <= "1111111";
				elsif (activated='1') then --eteindre='0' --on veut afficher StOP
					display_segments(3) <= encode_letter(0); -- S
					display_segments(2) <= encode_letter(1); -- t
					display_segments(1) <= encode_letter(2); -- O
					display_segments(0) <= encode_letter(3); -- P
				elsif(activated='0') then --eteindre ='0' --on veut afficher go
					display_segments(1) <= encode_letter(4); -- g
					display_segments(0) <= encode_letter(5); -- o
					display_segments(2) <= "1111111"; -- Éteindre les autres
					display_segments(3) <= "1111111";
				end if;
		   end if;
    end process;

    -- Assignation des segments à la sortie
	 afficheur0 <= display_segments(0);
	 afficheur1 <= display_segments(1);
	 afficheur2 <= display_segments(2);
	 afficheur3 <= display_segments(3);

end Behavioral;