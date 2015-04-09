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
-- File Name : ARRAY_REG128.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : Rijndael registered array (state) input/output data bus
-- Purpose   : This block provides a 128 bit (arrayed) input/output
--             registered buffer 
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity ARRAY_REG128 is

  port (clock    : in std_logic;    -- clock signal
        reset    : in std_logic;    -- active high reset (asynchronous)

        DATA_IN  : in STATE_TYPE;   -- input data bus
        DATA_OUT : out STATE_TYPE   -- output data bus

  );

end ARRAY_REG128;

architecture ARRAY_REG128_RTL of ARRAY_REG128 is


begin

-- ===========================================================================
-- =========================== Data Movement =================================
-- ===========================================================================

DATA_FLOW : process( clock, reset )

variable row    : integer range 0 to 3;
variable column : integer range 0 to 3;

begin

   if reset = '1' then

      for row in 0 to 3 loop
         for column in 0 to 3 loop
            DATA_OUT(row)(column) <= ( others => '0' );
         end loop;
      end loop;

   elsif clock'event and clock = '1' then

      for row in 0 to 3 loop
         for column in 0 to 3 loop
            DATA_OUT(row)(column) <= DATA_IN(row)(column);
         end loop;
      end loop;

   end if;

end process; -- DATA_FLOW


end ARRAY_REG128_RTL;
