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
-- File Name : RIJNDAEL_Top_Pipelined.vhdl
-- Author    : NSA
-- Date      : December 99
-- Project   : AES Candidate Evaluation
-- Purpose   : This model is the top level structural model for a
--             pipelined implementation of Rijndael, an Advanced Encryption
--             Standard Candidate. It consists of port mappings among the
--             lower level components.
-- Notes     :
-- ===========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;

-- ===========================================================================
-- =========================== Interface Description =========================
-- ===========================================================================

entity RIJNDAEL_TOP_PIPE is

  port (clock     : in std_logic;
        reset     : in std_logic;

        ENC_DEC_B : in std_logic;  -- '1' = encrypt, '0' = decrypt
        DATA_IN   : in SLV_128;    -- 128-bit input data word (plaintext)
        DATA_LOAD : in std_logic;  -- data valid; load new input data word
        CV_IN     : in SLV_256;    -- 128, 192, 256-bit cv (user supplied key)
        CV_LOAD   : in std_logic;  -- cv_in is valid; load new cryptovariable
        CV_SIZE   : in SLV_2;      -- '00'= 128, '01'= 192, '10'= 256

        DATA_OUT  : out SLV_128;   -- 128-bit output data word (ciphertext)
        DONE      : out std_logic  -- indicates 'data_out' is valid

  );

end RIJNDAEL_TOP_PIPE;

architecture STRUCTURAL of RIJNDAEL_TOP_PIPE is


-- ===========================================================================
-- =========================== Component Definition ==========================
-- ===========================================================================

component INTERFACE is

  port (clock          : in std_logic;
        reset          : in std_logic;

        DATA_LOAD      : in std_logic;     -- data load pulse
        DATAIN         : in SLV_128;       -- 128 bit block
        CV_LOAD        : in std_logic;     -- crypto variable load pulse
        CV_SIZE        : in SLV_2;         -- '00'= 128, '01'= 192, '10'= 256
        CVIN           : in SLV_256;
        ENC_DEC_B      : in std_logic;     -- '1' = encrypt, '0' = decrypt

        CTRL_DATA_LOAD : out std_logic;    -- data load signal to controller
        CTRL_ENC_DEC_B : out std_logic;
        ALG_DATA       : out SLV_128;      -- 128 bit data block to algorithm
        KS_CVLOAD      : out std_logic;
        KS_CV          : out SLV_256
  );

end component;


component ALG_PIPE

  port (clock       : in std_logic;      -- clock signal
        reset       : in std_logic;      -- active high reset (asynchronous)

        ALG_DATAIN  : in SLV_128;        -- input data
        ALG_KEY     : in PIPE_KEY_TYPE;  -- array of sub-keys
        ALG_ENC     : in std_logic;      -- '1' = encrypt, '0' = decrypt

        ALG_DATAOUT : out SLV_128        -- processed output data

  );

end component;


component KEY_SCHEDULE_PIPE

  port (clock        : in std_logic;       -- clock signal
        reset        : in std_logic;       -- active high reset (asynch)

        KS_LOADCV    : in std_logic;       -- load a new cryptovariable
        KS_CV        : in SLV_256;         -- cryptovariable input bus
        KS_ENC       : in std_logic;       -- encrypt select (1=enc,0=dec)
        KS_INITIAL   : in W_TYPE;

        KS_ROUND_KEY : out PIPE_KEY_TYPE   -- output round key

  );

end component;


component CONTROL_PIPE

  port (clock           : in std_logic;
        reset           : in std_logic;

        CTRL_DATA_LOAD  : in std_logic;   -- data load signal from interface
        CTRL_KS_READY   : in std_logic;   -- runup done, schedule ready
        ENC_DEC_B       : in std_logic;   -- encrypt/decrypt control

        OUT_DONE        : out std_logic   -- done processing
       
  );

end component;

component INITIAL_EXPAND_BLOCK
  port (
    cv_in : in SLV_256;
    encrypt : in std_logic;
    INITIAL_EXPAND_FUNCT_out : out W_TYPE
  );
end component;


-- ===========================================================================
-- =========================== Signal Definition =============================
-- ===========================================================================

signal top_datain        : SLV_128;        -- top level data interconnection
signal top_dataload      : std_logic;      -- start new data connection
signal top_loadcv        : std_logic;      -- start new cv
signal top_cv            : SLV_256;        -- cryptovariable bus interconnect
signal top_enc_decb      : std_logic;      -- encrypt select interconnect
signal top_round_key     : PIPE_KEY_TYPE;  -- round key interconnects (array)
signal top_ks_ready      : std_logic;      -- cv runup complete signal (to ctrl)
signal top_ks_initial    : W_TYPE;         -- starting expanded key values

begin                                                                                                                                                                                                                             
INTER : INTERFACE port map (clock,             -- rising edge clock
                            reset,             -- active high reset
                            data_load,         -- ext. load new data
                            data_in,           -- ext. data input 
                            cv_load,           -- ext. load new cv
                            cv_size,           -- ext. cv size select
                            cv_in,             -- ext. cv input bus
                            enc_dec_b,         -- ext. encrypt select
                            top_dataload,      -- start new data
                            top_enc_decb,      -- encrypt select intercon.
                            top_datain,        -- data interconnect
                            top_loadcv,        -- load new cv intercon.
                            top_cv
                            );      -- cv bus connection


CTRL : CONTROL_PIPE port map (clock,           -- rising edge clock
                              reset,           -- active high reset
                              top_dataload,    -- process new data
                              top_ks_ready,    -- key runup complete
                              top_enc_decb,    -- encrypt select from interface
                              DONE);           -- start key expansion


ALG : ALG_PIPE port map (clock,                -- rising edge clock
                         reset,                -- active high reset
                         top_datain,           -- input data
                         top_round_key,        -- round key input array
                         top_enc_decb,         -- encrypt select
                         DATA_OUT );           -- data output connect

KEYSCH : KEY_SCHEDULE_PIPE port map (clock,           -- rising edge clock
                                     reset,           -- active high reset
                                     top_loadcv,      -- load new cv
                                     top_cv,          -- cv input bus
                                     top_enc_decb,    -- encrypt select
                                     top_ks_initial,  -- starting expanded key
                                     top_round_key ); -- round key outputs


KEYEXP : INITIAL_EXPAND_BLOCK 
                        port map(    top_cv,          -- cv input bus
                                     top_enc_decb,    -- encrypt select
                                     top_ks_initial); -- starting expanded key


end STRUCTURAL;


-- ===========================================================================
-- =========================== Configuration =================================
-- ===========================================================================


configuration CFG_RIJNDAEL_TOP_PIPE of RIJNDAEL_TOP_PIPE is

   for STRUCTURAL

      for CTRL: CONTROL_PIPE use
         entity work.CONTROL_PIPE(CONTROL_PIPE_RTL);
       end for;

      for all: KEY_SCHEDULE_PIPE use
         entity work.KEY_SCHEDULE_PIPE(KEY_SCHEDULE_PIPE_RTL);
      end for;

      for all: ALG_PIPE use
         entity work.ALG_PIPE(ALG_PIPE_RTL);
      end for;

      for INTER: INTERFACE USE
         entity work.INTERFACE(INTERFACE_RTL);
      end for;


   end for;

end CFG_RIJNDAEL_TOP_PIPE;
