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
-- File Name : interface.vhdl
-- Author    : NSA
-- Date      : 04 October 1999
-- Project   : RC6 interface block
-- Purpose   : This block buffers all inputs and routes them to the 
--             necessary entity.
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity INTERFACE is

  port (clock          : in std_logic;
        reset          : in std_logic;

        DATA_LOAD      : in std_logic;     -- data load pulse
        DATAIN         : in SLV_128;       -- 128 bit block
        CV_LOAD        : in std_logic;     -- crypto variable load pulse
        CV_SIZE        : in SLV_2;         -- '00'= 128, '01'= 192, '10'= 256
        CVIN           : in SLV_256;       -- input cryptovariable
        ENC_DEC_B      : in std_logic;     -- '1' = encrypt, '0' = decrypt

        CTRL_DATA_LOAD : out std_logic;    -- data load signal to controller
        CTRL_ENC_DEC_B : out std_logic;    -- encrypt signal to controller
        ALG_DATA       : out SLV_128;      -- 128 bit data block to algorithm
        KS_CVLOAD      : out std_logic;    -- load cv signal to key sched.
        KS_CV          : out SLV_256       -- cv bus to key sched.
  );

end INTERFACE;
 
architecture INTERFACE_RTL of INTERFACE is

-- ===========================================================================
-- =========================== Signal Definition =============================
-- ===========================================================================

signal CV_INT       : SLV_256;
signal ALG_DATA_INT : SLV_128;

begin

-- ===========================================================================
-- =========================== Data Movement =================================
-- ===========================================================================

KS_CV    <= CV_INT;
ALG_DATA <= ALG_DATA_INT;

main: process( clock, reset )

begin

   if reset = '1' then

      CTRL_DATA_LOAD <= '0';
      CTRL_ENC_DEC_B <= '0';
      KS_CVLOAD      <= '0';
      ALG_DATA_INT   <= (others => '0');
      CV_INT         <= ( others => '0' );

   elsif clock'event and clock = '1' then

      CTRL_DATA_LOAD <= DATA_LOAD;  -- pass control signals through
      CTRL_ENC_DEC_B <= ENC_DEC_B;
      KS_CVLOAD      <= CV_LOAD;
 
      if DATA_LOAD = '1' then
        ALG_DATA_INT   <= DATAIN;
      else
        ALG_DATA_INT   <= ALG_DATA_INT;
      end if;

      if CV_LOAD = '1' then         -- latch CV
         CV_INT <= CVIN;
      else                          -- hold previous CV data
         CV_INT <= CV_INT;
      end if;  -- CV_LOAD = '1'

   end if;  -- reset = '1'

end process;

end INTERFACE_RTL;
