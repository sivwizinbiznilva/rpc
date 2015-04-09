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
-- File Name : NOBOX_ENC_SLICE.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block performs a slice of the subkey expansion for the
--             encrypt direction.
-- Notes     :   
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity NOBOX_ENC_SLICE is
  port (
    KS_ENC      : in std_logic;       -- encrypt/decrypt select
    W           : in W_TYPE;          -- W register interconnections
    W_BOX       : in W_BOX_TYPE;      -- W outputs from S-box
    BANK_NUM    : in SLV_6;           -- identifies which subkey bank to expand
    W_NOBOX_ENC : out W_HALF_TYPE );  -- New W values (based on previous W)

end NOBOX_ENC_SLICE;

architecture rtl of NOBOX_ENC_SLICE is 

-- =========================================================================
-- Type Definitions
-- =========================================================================
type LG_BOX_TYPE is array(0 to 15) of integer;
type DIV3_TABLE_TYPE is array (0 to 23) of integer range 0 to 7;


-- =========================================================================
-- Constants
-- =========================================================================
-- Indexes for S-box lookup
constant LG_BOX_TABLE : LG_BOX_TYPE :=
                     (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 0, 0, 0);

-- Divide by 3 table lookup
constant div3_table : DIV3_TABLE_TYPE := ( 
    0,  0,  0,  
    1,  1,  1, 
    2,  2,  2,
    3,  3,  3,
    4,  4,  4,
    5,  5,  5,
    6,  6,  6, 
    7,  7,  7 );

-- =========================================================================
-- Signal Definition
-- =========================================================================

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
-- ================================ ENCRYPTION ===============================
-- ===========================================================================

      W_NOBOX_ENC(-4) <= W(-1) xor W(-4);

      W_NOBOX_ENC(-3) <= W_BOX(LG_BOX_TABLE(bank mod 16)) xor W(-3);

      W_NOBOX_ENC(-2) <= W_BOX(LG_BOX_TABLE(bank mod 16)) xor W(-3) xor W(-2);

      W_NOBOX_ENC(-1) <= W_BOX(LG_BOX_TABLE(bank mod 16)) xor 
                              W(-3) xor W(-2) xor W(-1);


end rtl;

