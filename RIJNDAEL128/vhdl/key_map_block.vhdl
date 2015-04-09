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
-- File Name : KEY_MAP_BLOCK.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block maps the W registers to round subkeys.
-- Notes     :   
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity KEY_MAP_BLOCK is
  port (
    KS_ENC       : in std_logic;  -- encrypt/decrypt selector
    W            : in W_TYPE;     -- W register interconnections
    W_INPUT      : in W_TYPE;     -- W register interconnections (unreg.)
    KS_ROUND_KEY : out KEY_TYPE   -- output round key
 );

end KEY_MAP_BLOCK;

architecture rtl of KEY_MAP_BLOCK is 


begin

-- =========================================================================
-- Create the mapping to the round key outputs
-- =========================================================================


  G7a: for column in 0 to 3 generate

     G7b: for row in 0 to 3 generate

        KS_ROUND_KEY(row)(column) <=

           W_INPUT(-4+column)(31-row*8 downto 24-row*8) when
           (  KS_ENC = '1' )              else

           W(-4+(3-column))(31-row*8 downto 24-row*8);

     end generate; -- G7b

  end generate; -- G7a



end rtl;

