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
-- File Name : INITIAL_ROUND_BLOCK.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block serves as a wrapper for the INITIAL_ROUND function
--             in the synthesis process
-- Notes     :   
-- ===========================================================================


library IEEE;
library DWDL;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity INITIAL_ROUND_BLOCK is
  port (
    encrypt                 : in std_logic;   -- encrypt/decrypt select
    roundkey                : in KEY_TYPE;    -- subkey input
    state                   : in STATE_TYPE;  -- subkey input
    INITIAL_ROUND_FUNCT_out : out STATE_TYPE  -- state output (processed)
  );
end INITIAL_ROUND_BLOCK;

architecture rtl of INITIAL_ROUND_BLOCK is 

  signal INITIAL_ROUND_FUNCT_out_tmp_created_by_csl : STATE_TYPE;


begin
    INITIAL_ROUND_FUNCT_out_tmp_created_by_csl <=
    INITIAL_ROUND_FUNCT(
	encrypt => encrypt,
	roundkey => roundkey,
	state => state);
    INITIAL_ROUND_FUNCT_out <= INITIAL_ROUND_FUNCT_out_tmp_created_by_csl ;

end rtl;
