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
-- File Name : key_sched_pipe.vhdl
-- Author    : NSA
-- Date      : December 1999
-- Project   : Rijndael pipelined key schedule block 
-- Purpose   : build key schedule for pipelined implementation
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity KEY_SCHEDULE_PIPE is

  port (clock        : in std_logic;       -- clock signal
        reset        : in std_logic;       -- active high reset (asynch)

        KS_LOADCV    : in std_logic;       -- load a new cryptovariable
        KS_CV        : in SLV_256;         -- cryptovariable input bus
        KS_ENC       : in std_logic;       -- encrypt select (1=enc,0=dec)
        KS_INITIAL   : in W_TYPE;          -- Initial subkey
  
        KS_ROUND_KEY : out PIPE_KEY_TYPE   -- output round key

  );

end KEY_SCHEDULE_PIPE;

architecture KEY_SCHEDULE_PIPE_RTL of KEY_SCHEDULE_PIPE is

-- ===========================================================================
-- =========================== Component Definition ==========================
-- ===========================================================================

component REG32B

  port (clock    : in std_logic;   -- clock signal
        reset    : in std_logic;   -- active high reset (asynchronous)

        LATCH    : in std_logic;
        DATA_IN  : in SLV_32;      -- input data bus
        DATA_OUT : out SLV_32      -- output data bus

  );

end component;

component NOBOX_ENC_GROUP_BLOCK
  port (
    KS_ENC      : in std_logic;       -- encrypt/decrypt selection
    W           : in W_PIPE_TYPE;     -- W register interconnections
    W_BOX       : in W_BOX_TYPE;      -- S-box array connections
    W_NOBOX_ENC : out W_NOBOX_TYPE ); -- W array output (new values) 

end component;

component NOBOX_DEC_GROUP_BLOCK
  port (
    KS_ENC      : in std_logic;       -- encrypt/decrypt selection
    W           : in W_PIPE_TYPE;     -- W register interconnections
    W_NOBOX_DEC : out W_NOBOX_TYPE ); -- W array output (new values)

end component;

component BOX_GROUP_BLOCK
  port (
    KS_ENC      : in std_logic;      -- encrypt/decrypt select
    W           : in W_PIPE_TYPE;    -- W register interconnections
    W_BOX       : out W_BOX_TYPE );  -- W outputs (from the S-boxes)

end component;

component KEY_MAP_BLOCK 
  port (
    KS_ENC       : in std_logic;  -- encrypt/decrypt selector
    W            : in W_TYPE;     -- W register interconnections
    W_INPUT      : in W_TYPE;     -- W register interconnections (unreg.)
    KS_ROUND_KEY : out KEY_TYPE   -- output round key
 );
end component;

component INPUT_MAP128_BLOCK
  port (
    KS_ENC       : in  std_logic;      -- encrypt/decrypt select
    W            : in  W_PIPE_TYPE;    -- W register interconnections
    W_BOX        : in  W_BOX_TYPE;     -- S-box array inputs
    W_NOBOX_ENC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_NOBOX_DEC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_INPUT_128  : out W_INPUT_TYPE    -- output round key
 );
end component;

component INPUT_MAP192_BLOCK
  port (
    KS_ENC       : in  std_logic;      -- encrypt/decrypt select
    W            : in  W_PIPE_TYPE;    -- W register interconnections
    W_BOX        : in  W_BOX_TYPE;     -- S-box array inputs
    W_NOBOX_ENC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_NOBOX_DEC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_INPUT_192  : out W_INPUT_TYPE    -- output round key
 );
end component;


component INPUT_MAP256_BLOCK 
  port (
    KS_ENC       : in  std_logic;      -- encrypt/decrypt select
    W            : in  W_PIPE_TYPE;    -- W register interconnections
    W_BOX        : in  W_BOX_TYPE;     -- S-box array inputs
    W_NOBOX_ENC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_NOBOX_DEC  : in  W_NOBOX_TYPE;   -- non S-box array
    W_INPUT_256  : out W_INPUT_TYPE    -- output round key
 );

end component;

-- ===========================================================================
-- ================ Type, Signal, & Constant Definitions =====================
-- ===========================================================================

subtype LATCH_REG_TYPE is std_logic_vector(0 to 13);

signal LATCH_REG   : LATCH_REG_TYPE;
signal LOGIC_ONE   : std_logic;
signal W           : W_PIPE_TYPE;    -- W register interconnections
signal W_BOX       : W_BOX_TYPE;
signal W_FAR       : W_FAR_TYPE;
signal W_INPUT     : W_INPUT_TYPE;
signal W_INPUT_128 : W_INPUT_TYPE;
signal W_INPUT_192 : W_INPUT_TYPE;
signal W_INPUT_256 : W_INPUT_TYPE;
signal W_NEAR      : W_NEAR_TYPE;
signal W_NOBOX_ENC : W_NOBOX_TYPE;
signal W_NOBOX_DEC : W_NOBOX_TYPE;
signal W_ORIG      : W_TYPE;         -- first W reg. connection (from CV )

signal bank        : integer;
signal index       : integer;

type INDEX_TYPE is array (0 to 11) of integer;

constant FAR_INDEX_ENC : INDEX_TYPE := (0, 1, 3, 4, 6, 7, 9, 10, 0, 0, 0, 0);
constant FAR_INDEX_DEC : INDEX_TYPE := (0, 2, 3, 5, 6, 8, 9, 11, 0, 0, 0, 0);
constant SBOX_INDEX    : INDEX_TYPE := (0, 0, 1, 2, 0, 3, 4,  0, 5, 6, 0, 7);
constant NEAR_INDEX    : INDEX_TYPE := (0, 2, 3, 5, 6, 8, 9, 11, 0, 0, 0, 0);


begin

-- ===========================================================================
-- ====================== Generate Pipe Structure ============================
-- ===========================================================================
--
-- PURPOSE:  
--
-- The following generate statements create a pipelined architecture for 
-- the key expansion.  For each round of expansion, a new set of W values
-- are created.

-- ===========================================================================
-- Perform initial key expansion and store original values for future use
-- ===========================================================================

  W_ORIG <= KS_INITIAL;

-- ===========================================================================
-- Handles the mapping of the lower NK words of key into the first
-- key schedule registers.  Maps the two different key expansion 
-- techniques to the input of the register for the remaining cases.
-- ===========================================================================

-- ===========================================================================
-- First NK keys get mapped directly
-- ===========================================================================


W_INPUT(0)(-8) <= W_ORIG(-8) when KS_ENC = '0' else
                  KS_CV(255-0*32 downto 224-0*32);

W_INPUT(0)(-7) <= W_ORIG(-7) when KS_ENC = '0' else
                  KS_CV(255-1*32 downto 224-1*32);

W_INPUT(0)(-6) <= W_ORIG(-6) when KS_ENC = '0' else
                  KS_CV(255-0*32 downto 224-0*32);

W_INPUT(0)(-5) <= W_ORIG(-5) when KS_ENC = '0' else
                  KS_CV(255-1*32 downto 224-1*32);

W_INPUT(0)(-4) <= W_ORIG(-4) when KS_ENC = '0' else
                  KS_CV(255-0*32 downto 224-0*32);

W_INPUT(0)(-3) <= W_ORIG(-3) when KS_ENC = '0' else
                  KS_CV(255-1*32 downto 224-1*32);

W_INPUT(0)(-2) <= W_ORIG(-2) when KS_ENC = '0' else
                  KS_CV(255-2*32 downto 224-2*32);

W_INPUT(0)(-1) <= W_ORIG(-1) when KS_ENC = '0' else
                  KS_CV(255-3*32 downto 224-3*32);


-- ===========================================================================
-- Remaining keys after the initial CV get mapped by the expansion function
-- ===========================================================================

INMAP128: INPUT_MAP128_BLOCK port map ( KS_ENC,
                                        W, W_BOX,
                                        W_NOBOX_ENC,
                                        W_NOBOX_DEC,
                                        W_INPUT_128);



-- ===========================================================================
-- Mux different key size W values into a single input stream
-- ===========================================================================

G6 : for bank in 0 to 14 generate

   G6a : for index in -8 to -1 generate

      G6b: if ( bank > 0 and index > -5) generate

         W_INPUT(bank)(index) <=

            W_INPUT_128(bank-1)(index);

      end generate; -- G6b

      G6c: if ( bank > 0 and index < -4) generate

         W_INPUT(bank)(index) <= W(bank-1)(index+4);

      end generate; -- G6c

      REG : REG32B port map ( clock,
                              reset,
                              LOGIC_ONE, 
                              W_INPUT(bank)(index),
                              W(bank)(index) );

   end generate; -- G6a

end generate; -- G6


-- ===========================================================================
-- Map W register values to output round keys
-- ===========================================================================

G7: for keynum in 0 to 14 generate
   GEN_OUTPUT: KEY_MAP_BLOCK port map ( KS_ENC, W(keynum), W_INPUT(keynum), KS_ROUND_KEY(keynum) );

end generate; -- G7


-- ===========================================================================
-- Generate the S-box array
-- ===========================================================================


BOX_COMPS: BOX_GROUP_BLOCK port map ( KS_ENC,
                                      W,
                                      W_BOX );

-- ===========================================================================
-- Generate the non-S-Box array for both encrypt and decrypt directions
-- ===========================================================================


NOBOX_ENC_COMPS: NOBOX_ENC_GROUP_BLOCK port map ( KS_ENC,
                                                  W,
                                                  W_BOX,
                                                  W_NOBOX_ENC );

NOBOX_DEC_COMPS: NOBOX_DEC_GROUP_BLOCK port map ( KS_ENC,
                                                  W,
                                                  W_NOBOX_DEC );





-- ===========================================================================
-- =========================== Concurrent Assignments ========================
-- ===========================================================================

LOGIC_ONE <= '1';

-- ===========================================================================
-- =========================== Data Movement =================================
-- ===========================================================================

DATA_FLOW : process( clock, reset )

begin

   if reset = '1' then

      LATCH_REG <= ( others => '0' );

   elsif clock'event and clock = '1' then

      LATCH_REG <= KS_LOADCV & LATCH_REG(LATCH_REG'low to LATCH_REG'high-1);

   end if;

end process; -- DATA_FLOW

end KEY_SCHEDULE_PIPE_RTL;

-- ===========================================================================
-- ========================= Configuration ===================================
-- ===========================================================================

configuration CFG_KEY_SCHEDULE_PIPE of KEY_SCHEDULE_PIPE is

   for KEY_SCHEDULE_PIPE_RTL

   end for;

end;


