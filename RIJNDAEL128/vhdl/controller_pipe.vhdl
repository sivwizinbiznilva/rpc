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
-- File Name : controller_pipe.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : Rijndael pipelined controller block
-- Purpose   : This block runs the timing and data ready signals
-- Notes     :   
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity CONTROL_PIPE is

  port (clock          : in std_logic;
        reset          : in std_logic;

        CTRL_DATA_LOAD : in std_logic;   -- data load signal from interface
        CTRL_KS_READY  : in std_logic;   -- runup done, schedule ready
        ENC_DEC_B      : in std_logic;   -- encrypt/decrypt control

        OUT_DONE       : out std_logic   -- done processing
       
  );

end CONTROL_PIPE;

architecture CONTROL_PIPE_RTL of CONTROL_PIPE is

-- ===========================================================================
-- =========================== Signal Definition =============================
-- ===========================================================================

signal SHIFT_REG       : SLV_16;
signal LATCH_DATA_LOAD : std_logic;

begin

-- ===========================================================================
-- =========================== Data Movement =================================
-- ===========================================================================

DATA_FLOW : process ( clock, reset )

begin

   if reset = '1' then

      SHIFT_REG <= (others => '0');

   elsif clock'event and clock = '1' then

      SHIFT_REG <= CTRL_DATA_LOAD & 
                   SHIFT_REG(SHIFT_REG'HIGH downto SHIFT_REG'LOW+1);

   end if; -- reset = '1'

end process; -- DATA_FLOW

-- Output gets last bit of shift delay reg

OUT_DONE <= SHIFT_REG(SHIFT_REG'LOW+5); 


end CONTROL_PIPE_RTL;
 
 
