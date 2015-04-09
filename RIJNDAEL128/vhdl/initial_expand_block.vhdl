-- *************************************************************************
-- DISCLAIMER. THIS SOFTWARE WAS WRITTEN BY EMPLOYEES OF THE U.S.
-- GOVERNMENT AS A PART OF THEIR OFFICIAL DUTIES AND, THEREFORE, IS NOT
-- PROTECTED BY COPYRIGHT. HOWEVER, THIS SOFTWARE CODIFIES THE FINALIST
-- CANDIDATE ALGORITHMS (i.e., MARS, RC6tm, RIJNDAEL, SERPENT, AND
-- TWOFISH) IN THE ADVANCED ENCRYPTION STANDARD (AES) DEVELOPMENT EFFORT
-- SPONSORED BY THE NATIONAL INSTITUTE OF STANDARDS AND TECHNOLOGY (NIST)
-- AND MAY BE PROTECTED BY ONE OR MORE FORMS OF INTELLECTUAL PROPERTY. THE
-- U.S. GOVERNMENT MAKES NO WARRANTY, EITHER EXPRESSED OR IMPLIED,
-- INCLUDING BUT NO LIMITED TO ANY IMPLIED WARRANTIES OF MERCHANTABILITY
-- OR FITNESS FOR A PARTICULAR PURPOSE, REGARDING THIS SOFTWARE. THE U.S.
-- GOVERNMENT FURTHER MAKES NO WARRANTY THAT THIS SOFTWARE WILL NOT
-- INFRINGE ANY OTHER UNITED STATES OR FOREIGN PATENT OR OTHER
-- INTELLECTUAL PROPERTY RIGHT. IN NO EVENT SHALL THE U.S. GOVERNMENT BE
-- LIABLE TO ANYONE FOR COMPENSATORY, PUNITIVE, EXEMPLARY, SPECIAL,
-- COLLATERAL, INCIDENTAL, CONSEQUENTIAL, OR ANY OTHER TYPE OF DAMAGES IN
-- CONNECTION WITH OR ARISING OUT OF COPY OR USE OF THIS SOFTWARE.
-- *************************************************************************

-- ===========================================================================
-- File Name : INITIAL_EXPAND_BLOCK.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block serves as a wrapper for the FINAL_ROUND function
--             in the synthesis process
-- Notes     :   
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity INITIAL_EXPAND_BLOCK is
  port (
    cv_in                    : in SLV_256;    -- cryptovariable input
    encrypt                  : in std_logic;  -- encrypt select
    INITIAL_EXPAND_FUNCT_out : out W_TYPE     -- initial W register output
  );
end INITIAL_EXPAND_BLOCK;

architecture rtl of INITIAL_EXPAND_BLOCK is 

-- ======================================================================
-- Component Definition
-- ======================================================================

component EXPANSION_BLOCK is
  port (
    cv_in : in SLV_256;
    round : in SLV_6;
    w_in : in W_TYPE;
    EXPANSION_FUNCT_out : out W_TYPE
  );
end component;

-- ======================================================================
-- Type Definition
-- ======================================================================

  type W_CHAIN_TYPE is array(0 to 12) of W_TYPE;
  type ROUND_VEC_TYPE is array(0 to 12) of SLV_6;

-- ======================================================================
-- Constant Definition
-- ======================================================================

  constant ROUND_VEC : ROUND_VEC_TYPE := ( 
       "000000", "000001", "000010", "000011", 
       "000100", "000101", "000110", "000111", 
       "001000", "001001", "001010", "001011", 
       "001100" );

-- ======================================================================
-- Signal Definition
-- ======================================================================

  signal w_array   : W_CHAIN_TYPE;
  signal w_output  : W_TYPE;
  signal w_in      : W_TYPE;
  signal round_num : ROUND_VEC_TYPE;

  signal INITIAL_EXPAND_FUNCT_out_tmp_created_by_csl : W_TYPE;


begin

-- ======================================================================
-- Map key inputs to the initial W register array based on cv_size
-- ======================================================================

w_in(-8) <= cv_in(255-0*32 downto 224-0*32);
w_in(-7) <= cv_in(255-1*32 downto 224-1*32);
w_in(-6) <= cv_in(255-2*32 downto 224-2*32);
w_in(-5) <= cv_in(255-3*32 downto 224-3*32);
w_in(-4) <= cv_in(255-0*32 downto 224-0*32);

w_in(-3) <= cv_in(255-1*32 downto 224-1*32);

w_in(-2) <= cv_in(255-2*32 downto 224-2*32);

w_in(-1) <= cv_in(255-3*32 downto 224-3*32);

-- ======================================================================
-- Initialize a constant array
-- ======================================================================

G0: for round in 0 to 12 generate
   round_num(round) <= ROUND_VEC(round);
end generate;

-- ======================================================================
-- Generate the instantiations of the key expansion block
-- ======================================================================

G1: for round in 0 to 12 generate
   G2: if round = 0 generate
      inst1: EXPANSION_BLOCK
              port map ( cv_in,
                         round_num(round),
                         w_in,
                         w_array(round) );
   end generate; -- G2
   G3: if round > 0 generate
      inst2: EXPANSION_BLOCK
              port map ( cv_in,
                         round_num(round),
                         w_array(round-1),
                         w_array(round) );
   end generate; -- G3

end generate; -- G1
 
-- ======================================================================
-- Re-map the W register to the final outputs of the initial expand
-- ======================================================================

G4: for i in -8 to -1 generate
   INITIAL_EXPAND_FUNCT_out(i) <= w_output(-9-i);
end generate; -- G4

w_output <= w_array(10);


end rtl;

