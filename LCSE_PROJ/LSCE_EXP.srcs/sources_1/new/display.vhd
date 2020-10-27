----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Alejandro Gomez Molina
-- Engineer: Luis Felipe Velez Flores
-- Create Date: 22.10.2020 15:52:03
-- Design Name: 
-- Module Name: display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Display configured with 6 registers of 8 bits. One for enable the entire device, another for activate the desired anode
-- (0 is for select), and the rest for passing the value in BCD (in each register there are two BDC words).
-- Dependencies: use LCSE_PKG in order to get the constanst needed and numeric_Std for math operations.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.LCSE_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Address_s : in STD_LOGIC_VECTOR (7 downto 0);
           InBus_s : in STD_LOGIC_VECTOR (7 downto 0);
           outBus_s : out STD_LOGIC_VECTOR (7 downto 0);
           WE_s : in STD_LOGIC;
           RE_s : in STD_LOGIC;
           out_display : out STD_LOGIC_VECTOR(7 downto 0);
           anode : out STD_LOGIC_VECTOR(7 downto 0));
end display;

architecture Behavioral of display is
    type dev_mem_8 is array (0 to TO_INTEGER(eDISPLAY - sDISPLAY) ) of std_logic_vector(7 downto 0);
    
    
    signal mem_r,mem_n : dev_mem_8;
    signal outBus_r : STD_LOGIC_VECTOR(7 downto 0);
    signal outDisp_r, outDisp_n : STD_LOGIC_VECTOR(7 downto 0);
    signal anode_r,anode_n : STD_LOGIC_VECTOR(7 downto 0);
    signal cnt_r, cnt_n : UNSIGNED(log2c(50000)-1 downto 0);    
    signal index_r, index_n     : UNSIGNED(log2c(8) -1 downto 0);
    
    signal d_r, d_n : STD_LOGIC_VECTOR (3 downto 0);  
    --Components
    component decod7s 
        Port ( D : in  STD_LOGIC_VECTOR (3 downto 0);					
               S : out  STD_LOGIC_VECTOR (7 downto 0));   	
    end component;
    
    signal S                    : STD_LOGIC_VECTOR (7 downto 0);
    signal D                    : STD_LOGIC_VECTOR (3 downto 0);    
begin

    decoder: decod7s 
        port map ( D => d_r,
                   S => S);

 FF: process (Clk, Reset) is
 begin
    if (Reset = '1') then
        mem_r <= (others => (others => '0'));
        mem_r(TO_INTEGER(DISPLAY_ANODE - DISPLAY_BASE)) <= X"FF";
        outDisp_r <= "00000001";
        index_r <= (others => '0');
        cnt_r <= (others => '0');
        anode_r <= (others => '1');
        d_r <= (others => '0');
    elsif (Clk'event and Clk = '1') then
        mem_r <= mem_n; 
        outDisp_r <= outDisp_n; 
        cnt_r <= cnt_n;
        index_r <= index_n;
        anode_r <= anode_n;
        d_r <= d_n;
    end if;
 end process;
 
process(Address_s, inBus_s,WE_s, RE_s, mem_r,cnt_r,index_r,D, outDisp_r,S,anode_r,d_r,D) is
begin
    outBus_r <= (others => 'Z');
    mem_n <= mem_r;
    cnt_n <= cnt_r + 1;
    index_n <= index_r;
    outDisp_n <= outDisp_r;
    anode_n <= anode_r;
    d_n <= d_r;
    
    if (TO_INTEGER(cnt_r) = 400) then
        cnt_n <= (others => '0');        
        index_n <= index_r + 1;
        outDisp_n <= S;  
        anode_n <= (others => '1');
        
        if ((mem_r(0)(7) and not(mem_r(1)(TO_INTEGER(index_r)))) = '1') then
            case index_r is
                when "000" => 
                    anode_n(0) <= '0';
                    d_n <= mem_r(TO_INTEGER(DISPLAY_01-DISPLAY_BASE))(3 downto 0);
                     
                when "001" =>
                    anode_n(1) <= '0';
                    d_n <= mem_r(TO_INTEGER(DISPLAY_01-DISPLAY_BASE))(7 downto 4);
                     
                when "010" =>
                    anode_n(2) <= '0'; 
                    d_n <= mem_r(TO_INTEGER(DISPLAY_23-DISPLAY_BASE))(3 downto 0);
                     
                when "011" =>
                    anode_n(3) <= '0'; 
                    d_n <= mem_r(TO_INTEGER(DISPLAY_23-DISPLAY_BASE))(7 downto 4);
                    
                when "100" =>
                    anode_n(4) <= '0'; 
                    d_n <= mem_r(TO_INTEGER(DISPLAY_45-DISPLAY_BASE))(3 downto 0);
                     
                when "101" =>
                    anode_n(5) <= '0'; 
                    d_n <= mem_r(TO_INTEGER(DISPLAY_45-DISPLAY_BASE))(7 downto 4);
                     
                when "110" =>
                    anode_n(6) <= '0'; 
                    d_n <= mem_r(TO_INTEGER(DISPLAY_67-DISPLAY_BASE))(3 downto 0);
                    
                when "111" =>
                    anode_n(7) <= '0';
                    d_n <= mem_r(TO_INTEGER(DISPLAY_67-DISPLAY_BASE))(7 downto 4);
                     
                when others =>
                    d_n <= "0000";
                            
            end case;         
        else
            d_n <= "0000";
        end if;       
    end if;
    
    if (WE_s = '1') then
        mem_n(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE)) <= InBus_s;
    elsif (RE_s = '1') then
        outBus_r <= mem_r(TO_INTEGER(UNSIGNED(Address_s) - DISPLAY_BASE));
    end if; 
    

end process;

--output: process(index_r,mem_r,D,outDisp_r,S) is
--begin
--    if ((mem_r(TO_INTEGER(DISPLAY_EN-DISPLAY_BASE))(7) = '1') and mem_r(TO_INTEGER(DISPLAY_ANODE-DISPLAY_BASE))(TO_INTEGER(index_r)) = '0') then
--        if (index_r(0) = '0') then
--            D <= mem_r(2 + TO_INTEGER('0' & index_r(2 downto 1)))(3 downto 0) ;
--        else
--            D <= mem_r(2 +TO_INTEGER('0' & index_r(2 downto 1)))(7 downto 4) ;
--        end if;
--    else
--        D<= "0000";    
--    end if;
    
--end process;
anode <= anode_r;  
outBus_s <= outBus_r;  
out_display <= outDisp_r; 
--anode <= std_logic_vector(index_r) when (mem_r(TO_INTEGER(DISPLAY_EN-DISPLAY_BASE))(7) = '1') else
--         (others => '0');  
         
end Behavioral;
