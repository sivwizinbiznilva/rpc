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
-- File Name : NOBOX_ENC_GROUP_BLOCK.vhdl
-- Date      : December 99
-- Project   : AES Candidate Evaluation
-- Purpose   : This block creates the structural block for key expansion 
--                in the non-sbox cases
-- Notes     :
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity NOBOX_ENC_GROUP_BLOCK is
  port (
    KS_ENC      : in std_logic;       -- encrypt/decrypt selection
    W           : in W_PIPE_TYPE;     -- W register interconnections
    W_BOX       : in W_BOX_TYPE;      -- S-box array connections
    W_NOBOX_ENC : out W_NOBOX_TYPE ); -- W array output (new values) 

end NOBOX_ENC_GROUP_BLOCK;

architecture rtl of NOBOX_ENC_GROUP_BLOCK is 

-- ===========================================================================
-- Component Definitions
-- ===========================================================================

component NOBOX_ENC_SLICE
  port (
    KS_ENC      : in std_logic;
    W           : in W_TYPE;    -- W register interconnections
    W_BOX       : in W_BOX_TYPE;
    BANK_NUM    : in SLV_6;
    W_NOBOX_ENC : out W_HALF_TYPE );

end component;

-- ===========================================================================
-- Type Definitions
-- ===========================================================================

  type BANK_VEC_TYPE is array(0 to 13) of SLV_6;

-- ===========================================================================
-- Constant Definitions
-- ===========================================================================

  constant BANK_VEC : BANK_VEC_TYPE := ( 
       "000000", "000001", "000010", "000011", 
       "000100", "000101", "000110", "000111", 
       "001000", "001001", "001010", "001011", 
       "001100", "001101" );

-- ===========================================================================
-- Signal Definitions
-- ===========================================================================

signal bank_num : BANK_VEC_TYPE;


begin

-- ===========================================================================
-- Creates the standard key expansion generation (no sbox lookup) and
-- places the correctly expanded values into an array. The array is 
-- defined back to i= -4 only for syntax, as these locations will not
-- contain valid data.
-- ===========================================================================

G0: for round in 0 to 13 generate
   bank_num(round) <= BANK_VEC(round);
end generate;

G5 : for bank in 0 to 13 generate
-- ===========================================================================
-- ================================ ENCRYPTION ===============================
-- ===========================================================================
   ENC_SLICE: NOBOX_ENC_SLICE 
                port map ( KS_ENC, 
                           W(bank),
                           W_BOX,
                           bank_num(bank),
                           W_NOBOX_ENC(bank) );
end generate; -- G5

end rtl;

