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
-- File Name : reg32b.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : Rijndael 32 bit input/output data bus
-- Purpose   : This block provides a 32 bit input/output registered buffer 
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity REG32B is

  port (clock    : in std_logic;   -- clock signal
        reset    : in std_logic;   -- active high reset (asynchronous)

        LATCH    : in std_logic;
        DATA_IN  : in SLV_32;      -- input data bus
        DATA_OUT : out SLV_32      -- output data bus

  );

end REG32B;

architecture REG32B_RTL of REG32B is

-- ===========================================================================
-- =========================== Signal Definition =============================
-- ===========================================================================

signal DATA_OUT_INT : SLV_32;

begin

-- ===========================================================================
-- =========================== Data Movement =================================
-- ===========================================================================

DATA_OUT <= DATA_OUT_INT;

DATA_FLOW : process( clock, reset )

begin

   if reset = '1' then

      DATA_OUT_INT <= ( others => '0' );

   elsif clock'event and clock = '1' then

      if LATCH = '1' then
         DATA_OUT_INT <= DATA_IN;       -- latch input data
      else
         DATA_OUT_INT <= DATA_OUT_INT;  -- hold data
      end if;

   end if;

end process; -- DATA_FLOW


end REG32B_RTL;
