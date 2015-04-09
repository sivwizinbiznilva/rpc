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
-- File Name : NOBOX_DEC_SLICE.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block performs a slice of the subkey expansion for the
--             decrypt direction.
-- Notes     :   
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity NOBOX_DEC_SLICE is
  port (
    KS_ENC      : in std_logic;       -- encrypt/decrypt select
    W           : in W_TYPE;          -- W register interconnections
    BANK_NUM    : in SLV_6;           -- identifies which subkey bank to expand
    W_NOBOX_DEC : out W_HALF_TYPE );  -- New W values (based on previous W)

end NOBOX_DEC_SLICE;

architecture rtl of NOBOX_DEC_SLICE is 

signal bank : integer;

begin

-- ===========================================================================
-- Creates the standard key expansion generation (no sbox lookup) and
-- places the correctly expanded values into an array. The array is 
-- defined back to i= -4 only for syntax, as these locations will not
-- contain valid data.
-- ===========================================================================


   bank <= TO_INTEGER(unsigned(BANK_NUM));

-- ===========================================================================
-- ================================ DECRYPTION ===============================
-- ===========================================================================

      W_NOBOX_DEC(-4) <= W(-3) xor W(-4);

      W_NOBOX_DEC(-3) <= W(-2) xor W(-3);

      W_NOBOX_DEC(-2) <= W(-1) xor W(-2);

      W_NOBOX_DEC(-1) <= W(-3) xor W(-4) xor W(-1);



end rtl;

