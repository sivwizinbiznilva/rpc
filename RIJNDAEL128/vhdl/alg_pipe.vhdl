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
-- File Name : alg_pipe.vhdl
-- Author    : NSA
-- Date      : December 99
-- Project   : AES Candidate Evaluation
-- Purpose   : This block implements the Rijndael algorithm
--             for a pipelined case
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity ALG_PIPE is

  port (clock       : in std_logic;      -- clock signal
        reset       : in std_logic;      -- active high reset (asynchronous)

        ALG_DATAIN  : in SLV_128;        -- input data
        ALG_KEY     : in PIPE_KEY_TYPE;  -- array of sub-keys
        ALG_ENC     : in std_logic;      -- '1' = encrypt, '0' = decrypt

        ALG_DATAOUT : out SLV_128        -- processed output data

  );

end ALG_PIPE;

architecture ALG_PIPE_RTL of ALG_PIPE is


-- ===========================================================================
-- ========================== Component Definition ===========================
-- ===========================================================================

component ARRAY_REG128 

  port (clock    : in std_logic;      -- clock signal
        reset    : in std_logic;      -- active high reset (asynchronous)

        DATA_IN  : in STATE_TYPE;     -- input data bus
        DATA_OUT : out STATE_TYPE     -- output data bus

  );

end component;

component RIJNDAEL_ROUND_BLOCK
  port (
    encrypt : in std_logic;
    roundkey : in KEY_TYPE;
    state : in STATE_TYPE;
    RIJNDAEL_ROUND_FUNCT_out : out STATE_TYPE
  );
end component;

component INITIAL_ROUND_BLOCK
  port (
    encrypt : in std_logic;
    roundkey : in KEY_TYPE;
    state : in STATE_TYPE;
    INITIAL_ROUND_FUNCT_out : out STATE_TYPE
  );
end component;

component FINAL_ROUND_BLOCK
  port (
    encrypt : in std_logic;
    roundkey : in KEY_TYPE;
    state : in STATE_TYPE;
    FINAL_ROUND_FUNCT_out : out STATE_TYPE
  );
end component;


-- ===========================================================================
-- =========================== Signal Definition =============================
-- ===========================================================================


signal ALG_DATA            : PIPE_DATA_TYPE;  -- array of 128 bit buses
signal ALG_DATA_FIRST      : STATE_TYPE;      -- first round of data (muxed e/d)
signal ALG_DATA_INT        : PIPE_DATA_TYPE;  -- procedure call interconnect
signal ALG_DATA_LAST       : STATE_TYPE;      -- last round of data (muxed e/d)
signal ALG_DATA_MAP        : STATE_TYPE;      -- SLV_128 to STATE_TYPE format
signal ALG_DATA_PREADD     : STATE_TYPE;      -- registered preadd intercon.
signal ALG_DATA_PREADD_INT : STATE_TYPE;      -- un-registered preadd intercon
signal FINAL_OUT           : STATE_TYPE;      -- final Rijndael round output
signal FINAL_OUT_REG       : STATE_TYPE;      -- final Rijndael round output
signal LAST_KEY            : KEY_TYPE;        -- last subkey (muxed by cvsize)
signal LAST_STATE          : STATE_TYPE;      -- data input to final round
signal POST_ADD_KEY        : KEY_TYPE;        -- post-add subkey
signal POST_OUT_INT        : STATE_TYPE;      -- postadd output (unregistered)
signal POST_OUT_REG        : STATE_TYPE;      -- postadd output (registered)
signal ROUND_KEY           : PIPE_KEY_TYPE;   -- array of subkeys
signal ROUND_STEP          : ROUND_TYPE;      -- current algorithm step


begin

-- ===========================================================================
--  Map SLV_128 to the STATE_TYPE format
-- ===========================================================================

G1: for column in 0 to 3 generate

   G1a: for row in 0 to 3 generate

      ALG_DATA_MAP(row)(column) <= ALG_DATAIN( 127-(column*32+row*8) downto 
                                               128-(column*32+(row+1)*8) );
   end generate; -- G1a

end generate; -- G1

-- ===========================================================================
-- ======================== Generate Pipe Structure ==========================
-- ===========================================================================
--
-- PURPOSE:  
--
-- The following generate statements create a pipelined architecture for 
-- the encryption/decryption.

-- ===========================================================================

PRE_ADD( ALG_DATA_MAP, ALG_ENC, ALG_KEY(0), ALG_DATA_PREADD_INT );

PREREG : ARRAY_REG128 port map ( clock,
                                 reset,
                                 ALG_DATA_PREADD_INT,   -- interconn.
                                 ALG_DATA_PREADD );     -- data out


ALG_DATA_FIRST <= ALG_DATA_MAP when ALG_ENC = '0' else 
                  ALG_DATA_PREADD;

G2: for ROUND_STEP in FIRST_ROUND to 8 generate

      ROUND_KEY(ROUND_STEP) <= ALG_KEY(ROUND_STEP+1) when ALG_ENC = '1' else
                               ALG_KEY(ROUND_STEP);

-- =========================== First Round ===================================

-- Generate first round and special case connections

   G2a: if (ROUND_STEP = FIRST_ROUND) generate

        STEP : INITIAL_ROUND_BLOCK
             port map ( ALG_ENC,
                        ROUND_KEY(ROUND_STEP),
                        ALG_DATA_FIRST,
                        ALG_DATA_INT(ROUND_STEP) );

      DATAREG : ARRAY_REG128 port map ( clock,
                                        reset,
                                        ALG_DATA_INT(ROUND_STEP), -- interconn.
                                        ALG_DATA(ROUND_STEP) );   -- data out

   end generate; -- G2a

-- ============================= Round i =====================================

-- Generate middle rounds for creating encryption/decryption.

   G2b: if (ROUND_STEP < 9 and ROUND_STEP > 0) generate

        STEP : RIJNDAEL_ROUND_BLOCK 
           port map ( ALG_ENC,
                      ROUND_KEY(ROUND_STEP),
                      ALG_DATA(ROUND_STEP-1),
                      ALG_DATA_INT(ROUND_STEP) ); 

      DATAREG : ARRAY_REG128 port map ( clock,
                                        reset,
                                        ALG_DATA_INT(ROUND_STEP), -- interconn.
                                        ALG_DATA(ROUND_STEP) );   -- data out

   end generate; -- G2b

end generate;  -- G2


-- ========================= Last Round ======================================

-- latch correct register for data input to final round based on CV size

LAST_STATE <= ALG_DATA(8);

LAST_KEY   <= ALG_KEY(10) when ALG_ENC = '1' else
              ALG_KEY(9);

LASTSTEP : FINAL_ROUND_BLOCK 
           port map ( ALG_ENC,
                      LAST_KEY,
                      LAST_STATE,
                      FINAL_OUT);

LASTREG : ARRAY_REG128 port map ( clock,
                                  reset,
                                  FINAL_OUT,         -- data interconnect
                                  FINAL_OUT_REG );   -- output data

-- ===========================================================================

POST_ADD_KEY   <= ALG_KEY(10);

POST_ADD( FINAL_OUT_REG, ALG_ENC, POST_ADD_KEY, POST_OUT_INT );

ALG_DATA_LAST <= POST_OUT_INT when ALG_ENC = '0' else
                 FINAL_OUT;

POSTREG : ARRAY_REG128 port map ( clock,
                                  reset,
                                  ALG_DATA_LAST,      -- data interconnect
                                  POST_OUT_REG );     -- output data

-- ===========================================================================
--  Map STATE_TYPE to the SLV_128 format
-- ===========================================================================

G3: for column in 0 to 3 generate

  G3a: for row in 0 to 3 generate

     ALG_DATAOUT(127-(column*32+row*8) downto
                 128-(column*32+(row+1)*8)) <= POST_OUT_REG(row)(column);

  end generate; -- G3a

end generate; -- G3


end ALG_PIPE_RTL;

-- ===========================================================================
-- ============================ Configuration ================================
-- ===========================================================================

configuration CFG_ALG_PIPE of ALG_PIPE is

   for ALG_PIPE_RTL

   end for;

end CFG_ALG_PIPE;


