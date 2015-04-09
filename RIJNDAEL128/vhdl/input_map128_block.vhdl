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
-- File Name : INPUT_MAP128_BLOCK.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : RIJNDAEL 
-- Purpose   : This block creates the mapping necessary for muxing the S-box
--             and non-S-Box inputs into a single stream for the 128 bit key
--             size.  The mapping is performed for the entire key array.
-- Notes     :   
-- ===========================================================================

library IEEE;
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

entity INPUT_MAP128_BLOCK is
  port (
    KS_ENC       : in  std_logic;      -- encrypt/decrypt select
    W            : in  W_PIPE_TYPE;    -- W register interconnections
    W_BOX        : in  W_BOX_TYPE;     -- S-box inputs
    W_NOBOX_ENC  : in  W_NOBOX_TYPE;   -- Non-sbox inputs (encrypt)
    W_NOBOX_DEC  : in  W_NOBOX_TYPE;   -- Non-sbox inputs (decrypt)
    W_INPUT_128  : out W_INPUT_TYPE    -- output round key
 );

end INPUT_MAP128_BLOCK;

architecture rtl of INPUT_MAP128_BLOCK is 


begin

-- =========================================================================
-- Create the mapping to the W registers from S-box and Non-sbox inputs
-- =========================================================================

G1 : for bank in 0 to 9 generate

   W_INPUT_128(bank)(-8) <= W(bank)(-4);

   W_INPUT_128(bank)(-7) <= W(bank)(-3);

   W_INPUT_128(bank)(-6) <= W(bank)(-2);

   W_INPUT_128(bank)(-5) <= W(bank)(-1);

   W_INPUT_128(bank)(-4) <= W_NOBOX_DEC(bank)(-4) when (KS_ENC = '0') else
                            W_BOX(bank);

   W_INPUT_128(bank)(-3) <= W_NOBOX_DEC(bank)(-3) when (KS_ENC = '0') else
                            W_NOBOX_ENC(bank)(-3);

   W_INPUT_128(bank)(-2) <= W_NOBOX_DEC(bank)(-2) when (KS_ENC = '0') else
                            W_NOBOX_ENC(bank)(-2);

   W_INPUT_128(bank)(-1) <= W_BOX(bank) when (KS_ENC = '0') else
                            W_NOBOX_ENC(bank)(-1);

end generate; -- G1

end rtl;

