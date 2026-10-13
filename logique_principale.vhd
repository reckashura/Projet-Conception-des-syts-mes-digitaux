--Programme: Système de contrôle automatique des barrières de sécurité et des feux de signalisation 
--					du passage à niveau pour trains et voitures.
--Description: Le système permet d'activer différents signaux selon les conditions: s'il y a un train de détecté
--	près du passage à niveau, s'il y a un obstacle sur le passage à niveau, si la barrière est bien descendue,
-- si le train est dépassé le passage à niveau
--Auteurs: Auger, L., Bekobo N., A.T, Cliche, A.
--Date: 17/11/2024
--
--Matériel nécessaire: 
	--5 LEDs avec 5 résistances 220ohm (2 rouges, 2 vertes, 1 orange)
	--2 buzzers passifs avec 2 résistances 1kohm
	--1 résistance 1kohm
	--2 boutons-poussoirs avec 2 résistances 1kohm
	--1 capteur ultrason HC-SR04
	--1 capteur PIR HC-SR501
	--1 servo-moteur micro HDD servo
	--1 carte DE1-SoC avec FPGA Cyclone V de Altera
--Modules nécessaires: afficheur_mots.vhd, Buzzer_Controle.vhd, LED_clignotante.vhd, Pin_controle.vhd,
-- Signal_servo.vhd, Ultrason.vhd

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity logique_principale is
	port(
		clk: in std_logic; --50MHz
		
		--Modules d'entrée
		--gestion activation/désactivation du système
		interrupteurs : in  std_logic_vector(3 downto 0); 
		led_interrupteurs : out std_logic_vector(3 downto 0);
		--ultrason1
		echo1: in std_logic;
		trig1: out std_logic;
		--detecteurPression1
		boutoninitial: in std_logic;
		--detecteurPression2
		boutonfinal: in std_logic;
		--detecteurPresenceIR
		presenceIR: in std_logic;
		--contactDeBarriere
		contact_barriere: in std_logic;
		
		--Modules de sortie
		--servomoteur
		servo_pwm: out std_logic;
		--buzzerTrain
		buzzer_out_train: out std_logic;
		--buzzerVoiture
		buzzer_out_voiture: out std_logic;
		--ledBlink_train
		ledBlink: out std_logic;
		--ledVerte_train
		ledverte_train: out std_logic;
		--ledVerte_voiture
		ledverte_voiture: out std_logic;
		--ledrouge_voiture
		ledrouge_voiture: out std_logic;
		--ledorange obstacle
		ledorange_obstacle: out std_logic;
		--Afficheurs
		afficheur0: out std_logic_vector(6 downto 0);
		afficheur1: out std_logic_vector(6 downto 0);
		afficheur2: out std_logic_vector(6 downto 0);
		afficheur3: out std_logic_vector(6 downto 0)
		);
		
end logique_principale;


architecture bhv_principal of logique_principale is

	constant clk_freq: integer:= 50000000; --50MHz
	constant temps_barriere: integer := 1; -- en secondes, temps pour que la barriere soit abaissée
	constant temps_obstacle1: integer := 1; -- en secondes, temps pour débuter la vérification d'un obstacle sur les voies
	constant temps_obstacle2: integer := 3; -- en secondes, temps pour qu'un obstacle se soit dégagé des voies
	signal counter_barriere: integer:= 0; 
	signal counter_obstacle: integer:= 0;
	
	signal traindetec_prec: std_logic := '0'; --est-ce qu'il y a un train près du passage à niveau? 1=oui, 0=non
	signal traingo_prec: std_logic := '0'; --est-ce que la train a reçu des signaux? 1=oui, 0=non
	signal detecteurtrain1: std_logic:= '0'; --détection train avant passage à niveau
	signal detecteurtrain2: std_logic:= '0'; --détection train après passage à niveau
	signal detectionobs: std_logic:= '0'; --détection obstacle sur passage à niveau
	signal signvoit: std_logic:= '0'; --signaux pour arrêter les voitures
	signal traingo: std_logic:= '0'; --signaux pour aviser le conducteur du train qu'il peut passer
	signal trainstop: std_logic:= '0'; --signaux pour aviser le conducteur du train qu'il ne peut pas passer
	signal barriere: std_logic:= '0'; --signal pour activer l'abaissement de la barrière
	  
   signal system : std_logic:= '0'; -- 0 si le système est désactivé, 1 si le système est activé
	
	signal activated_buzzerTrain: std_logic:= '0'; --signal activation buzzer du train actif haut
	constant bip_intervalle_train: integer:= 1; --intervalle en secondes des bip pour le buzzer du train
	signal activated_buzzerVoiture: std_logic:= '0'; --signal activation buzzer des voitures actif haut
	constant bip_intervalle_voiture: integer:= 2; --intervalle en secondes des bip pour le buzzer des voitures
	signal activated_ledBlink: std_logic:= '0'; --signal activation led rouge clignotante du train actif haut
	
	signal activated_afficheurs: std_logic:= '0'; --signal activation afficheurs -- si 0, go. si 1, StOP
	signal eteindre_afficheurs: std_logic:= '0'; --signal pour éteindre les afficheurs

	signal Ultra_detected1: std_logic:= '0'; --détecteur de distance <10
	signal counter_ultrason: integer :=0; --compteur pour l'ultrason
	signal Ultra_detected1_temp: std_logic :='0'; --temporaire
	
	begin --begin architecture
	--association des ports aux signaux intermediaires et vice-versa
	detecteurtrain1 <= presenceIR OR boutoninitial; 
	detecteurtrain2 <= boutonfinal;
	ledverte_train <= traingo;
	activated_ledBlink <= trainstop;
	activated_buzzerTrain <= trainstop;
	ledrouge_voiture <= signvoit;
	activated_buzzerVoiture <= signvoit;
	ledverte_voiture <= ((NOT signvoit) AND system);
	ledorange_obstacle <= detectionobs AND system;
	activated_afficheurs <= signvoit;
	eteindre_afficheurs <= NOT system;
	--barriere <= barriere --aucun signal intermediaire pour la barriere
	
	
	gestion_detectionobs: process(clk) --processus qui gère la détection d'obstacle
			begin --si un obstacle est détecté, il est gardé en mémoire 200us (pour éviter le flickering)
			if rising_edge(clk) then
				counter_ultrason <= counter_ultrason + 1;
				if(Ultra_detected1 = '1') then
					Ultra_detected1_temp <= '1';
				end if;
				if(counter_ultrason = (clk_freq/1000)*200) then
					counter_ultrason <= 0;
					detectionobs <= Ultra_detected1_temp;
					Ultra_detected1_temp <= '0';
				end if;
			end if;
	end process;
	
	--processus principal
	gestion_entrees_sorties: process(clk) --logique pour activer ou non les signaux nécessaires aux outputs
		begin --begin process
		if rising_edge(clk) then
			if system='1' then  --si le système automatique est activé
				if(traingo_prec = '0' AND traindetec_prec = '0' AND detecteurtrain1 = '0') then --aucun train
					signvoit <= '0';
					traingo <= '0';
					trainstop <= '0';
					barriere <= '0';
					traindetec_prec <= '0';
					traingo_prec <= '0';
				elsif(traingo_prec = '0' AND traindetec_prec = '0' AND detecteurtrain1 = '1') then --si le detecteur de train est activé, traindetec_prec est activé 
					signvoit <= '0';
					traingo <= '0';
					trainstop <= '0';
					barriere <= '0';
					traindetec_prec <= '1';
					traingo_prec <= '0';
				elsif(traingo_prec = '0' AND traindetec_prec = '1') then --s'il y a un train en mémoire qui n'a pas reçu de signaux
					signvoit <= '1';
					traingo <= '1';
					trainstop <= '0';
					barriere <= '0';
					traingo_prec <= '1';
				elsif(traingo_prec = '1' AND detecteurtrain2 = '0') then --si les signaux du train ont été activés
					if trainstop ='1' then -- si le train est arrêté, il doit le rester
						signvoit <= '1';
						traingo <= '0';
						trainstop <= '1';
						barriere <= '0';
					end if;
				elsif(traingo_prec = '1' AND detecteurtrain2 = '1') then --si le train a dépassé le passage à niveau, retour à la situation initiale
					signvoit <= '0';
					traingo <= '0';
					trainstop <= '0';
					barriere <= '0';
					traingo_prec <= '0';
					traindetec_prec <= '0';
				end if;
			else --system = '0' --système automatique éteint
				traingo_prec <= '0';
				traindetec_prec <= '0';
				signvoit <= '0';
				traingo <= '0';
				trainstop <= '0';
				barriere <= '0';
			end if;
			
			
			if(traindetec_prec = '1') then --vérification s'il y a toujours un obstacle sur les voies après 1s jusqu'à 3s
				if counter_obstacle <= (clk_freq*temps_obstacle2) then
					counter_obstacle <= counter_obstacle+1;
				end if;
				if (counter_obstacle > (clk_freq*temps_obstacle1) AND counter_obstacle < (clk_freq*temps_obstacle2)) then --intervalle de 1 à 3s
					if (detectionobs = '1') then --s'il y a un obstacle
						signvoit <= '1';
						traingo <= '0';
						trainstop <= '1';
						barriere <= '0';
					else --s'il n'y a pas ou plus d'obstacles
						signvoit <= '1';
						traingo <= '1';
						trainstop <= '0';
						barriere <= '1';
					end if;
				elsif counter_obstacle >= (clk_freq*temps_obstacle2) then --si ça fait plus que 3s
						if (detectionobs = '0') then
						signvoit <= '1';
						traingo <= '1';
						trainstop <= '0';
						barriere <= '1';
						end if;
				end if;
			else --traindetec_prec = '0'
				counter_obstacle <= 0;
			end if;
				
			
			if (barriere = '1') then --vérification si la barriere est belle et bien abaissée après 1s
				if counter_barriere < (clk_freq*temps_barriere) then 
					counter_barriere <= counter_barriere +1;
				end if;
				if counter_barriere = (clk_freq*temps_barriere) then
						if (contact_barriere ='1') then --si la barrière n'est pas abaissée
							traingo <= '0';
							trainstop <= '1';							
						else -- contact_barriere = '0' -- si la barriere est abaissée
							traingo <= '1';
							trainstop <= '0';
						end if;
				end if;
			else --barrière ='0'
			counter_barriere <= 0;
			end if;
		end if;
	end process;					
		
	
--direct instantiation des modules
	Gestion_systeme: entity work.Pin_controle
		port map(
			clk => clk,
			interrupteurs => interrupteurs,
			led => led_interrupteurs,
			system => system );
			
	CaptUltra1 : entity work.Ultrason
	port map(
		clk => clk,
		echo => echo1,
		trig => trig1,
		detected => Ultra_detected1 );
	
	Barriere_control : entity work.Signal_servo
	port map(
		clk => clk,
		activated => barriere,
		servo_pwm => servo_pwm );
		
	BuzzerTrain : entity work.Buzzer_Controle
	port map(
		clk => clk,
		activated => activated_buzzerTrain,
		bip_intervalle => bip_intervalle_train,
		buzzer_out => buzzer_out_train );
		
	BuzzerVoiture : entity work.Buzzer_Controle
		port map(
			clk => clk,
			activated => activated_buzzerVoiture,
			bip_intervalle => bip_intervalle_voiture,
			buzzer_out => buzzer_out_voiture );

	LED_Clignotante : entity work.LED_clignotante
		port map(
			clk => clk,
			activated => activated_ledBlink,
			led_out => ledBlink );

	Afficheur: entity work.afficheur_mots	
		port Map ( clk => clk, 
           activated => activated_afficheurs,
			  eteindre => eteindre_afficheurs,
           afficheur0 => afficheur0,
			  afficheur1 => afficheur1,
			  afficheur2 => afficheur2,
			  afficheur3 => afficheur3 );

end bhv_principal;