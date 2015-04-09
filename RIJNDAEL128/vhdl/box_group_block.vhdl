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
-- File Name : BOX_GROUP_BLOCK.vhdl
-- Date      : December 99
-- Project   : AES Candidate Evaluation
-- Purpose   : This block implements the S-box array of the subkey expansion
--             for a pipelined case
-- Notes     :
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity BOX_GROUP_BLOCK is
  port (
    KS_ENC      : in std_logic;      -- encrypt/decrypt select
    W           : in W_PIPE_TYPE;    -- W register interconnections
    W_BOX       : out W_BOX_TYPE );  -- W outputs (from the S-boxes)

end BOX_GROUP_BLOCK;

architecture rtl of BOX_GROUP_BLOCK is 

-- ===========================================================================
-- Signal Definition
-- ===========================================================================

signal EXPANSION_FUNCT_out_tmp_created_by_csl : W_TYPE;

signal W_NEAR      : W_NEAR_TYPE;    -- represents the N-1 term in key expand
signal W_FAR       : W_FAR_TYPE;     -- represents the N-k term in key expand

-- ===========================================================================
-- Constant Definition
-- ===========================================================================

constant NEAR_INDEX_ENC : INDEX_TYPE := (0, 1, 3, 4, 6, 7, 9, 10,
                                         0, 0, 0, 0, 0);

begin

-- ===========================================================================
-- Creates the sbox key expansion generation (with sbox lookup) and
-- places the correctly expanded values into an array.
-- ===========================================================================

G4 : for bank in 0 to 9 generate

-- ===========================================================================
-- generate the SBOX array
-- ===========================================================================

   KS_SBOX (KS_ENC,
            std_logic_vector(TO_UNSIGNED(bank,16)),
            W_FAR(bank),
            W_NEAR(bank),
            W_BOX(bank));

-- ===========================================================================
-- ================================ ENCRYPTION ===============================
-- ===========================================================================

   W_FAR(bank) <= W(bank)(-4) when ( KS_ENC = '1' ) else

  
-- ===========================================================================
-- ================================ DECRYPTION ===============================
-- ===========================================================================

                  W(bank)(-1);

-- ===========================================================================
-- ================================ ENCRYPTION ===============================
-- ===========================================================================

   W_NEAR(bank) <=

      W(bank)(-1) when ( KS_ENC = '1') else


-- ===========================================================================
-- ================================ DECRYPTION ===============================
-- ===========================================================================

      W(bank)(-4) xor W(bank)(-3);

end generate;  -- G4

end rtl;

