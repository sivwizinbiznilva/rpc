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

-----------------------------------------------------------------------------
-- File Name: tb_ecb_vk_dec_iter.vhdl
-- Author   : NSA
-- Date     : Dec 1999
-- Project  : AES Candidate Evaluation
-- Purpose  : This test bench exercises the top level structural model for
--            an iterative implementation of MARS. All vectors from the
--            ECB mode (decrypt) Known Answer Test, Variable Key are
--            tested and verified.
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.rijndael_pack.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity TB_ECB_VK_DEC_ITER is
end;

architecture tb of TB_ECB_VK_DEC_ITER is

   type RESULT     is (fail, pass, undefined);
   type PHASE      is  (clear, run_128_vectors, run_192_vectors,
                        run_256_vectors, undefined);
   type PHASE_ITER is array (2 downto 0) of PHASE;

   constant RUNUP_CYCLES : integer := 15;

   constant CLK_PER   : time:= 10 ns;

   signal clock       : std_logic := '0';  -- rising edge clock input
   signal reset       : std_logic;  -- asynchronous reset (active high)

   signal enc_dec_b   : std_logic;  -- encrypt select (0=encrypt, 1=decrypt)
   signal data_in     : SLV_128;    -- data input bus 
   signal data_load   : std_logic;  -- data start signal
   signal cv_in       : SLV_256;    -- cryptovariable input bus
   signal cv_load     : std_logic;  -- load a new cryptovariable
   signal cv_size     : SLV_2;      -- cv size (00=128, 01=192, 10=256)

   signal data_out    : SLV_128;   -- output data bus
   signal done        : std_logic; -- processing done

   signal test_result          : RESULT := undefined;
   signal test_phase           : PHASE  := clear;  --start simulation here
   signal pass128              : integer := 0;
   signal pass192              : integer := 0;
   signal pass256              : integer := 0;
   signal fail128              : integer := 0;
   signal fail192              : integer := 0;
   signal fail256              : integer := 0;



   FILE test_vector_file: text is in
	  "KAT_vectors/ecb_vk_ct.vec";


   component RIJNDAEL_TOP_ITER

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

   end component;

begin

   top_level : RIJNDAEL_TOP_ITER
               PORT MAP (clock, reset, enc_dec_b, data_in, data_load,
                         cv_in, cv_load, cv_size, data_out, done);

proc_clock  : process

begin

  WAIT for CLK_PER / 2;
  clock <= not clock;

end process;



run_vectors : process

variable L1              : LINE;           -- Predefined in textio
variable tmp_data_in     : SLV_128;


begin

  reset      <= '1';
  enc_dec_b  <= '0';
  data_in    <= (others => '0'); 
  data_load  <= '0';
  cv_in      <= (others => '0');
  cv_load    <= '0';
  cv_size    <= "00";

  wait for 5*CLK_PER;
  reset <= '0';


----------------------------------------------------------------------------
-- 128 bit key tests

  cv_size               <= "00";
  enc_dec_b             <= '0';
  data_in               <= (others => '1'); 
  cv_in(255)            <= '1';
  cv_in(254 downto 0)   <= (others => '0');
  cv_load               <= '1';
  wait for CLK_PER;

  cv_load               <= '0';
  wait for 40 * CLK_PER;

  for i in 1 to 127 loop

    if not (endfile(test_vector_file)) then
      readline(test_vector_file, L1);
      hread(L1, tmp_data_in);
    else
      tmp_data_in := (others => 'X');
    end if;

    data_in   <= tmp_data_in; 
    data_load           <= '1';
    wait for CLK_PER;

    data_in             <= (others => '1'); 
    data_load           <= '0';
    wait for 40 * CLK_PER;

    cv_in(255)          <= '0';
    cv_in(254 downto 0) <= cv_in(255 downto 1);
    cv_load             <= '1';
    wait for CLK_PER;

    cv_load             <= '0';
    wait for 40 * CLK_PER;

  end loop;

  if not (endfile(test_vector_file)) then
    readline(test_vector_file, L1);
    hread(L1, tmp_data_in);
  else
    tmp_data_in := (others => 'X');
  end if;

  data_in   <= tmp_data_in; 
  data_load             <= '1';
  wait for CLK_PER;

  data_in               <= (others => '1'); 
  data_load             <= '0';
  wait for (LAST_ROUND+3) * CLK_PER;

  wait for 1000*CLK_PER;

end process;




check_output : process (clock, reset)

variable tmp_data_out    : SLV_128;

begin

  if reset = '1' then

    test_phase           <= clear;
    test_result          <= undefined;
    pass128              <= 0;
    pass192              <= 0;
    pass256              <= 0;
    fail128              <= 0;
    fail192              <= 0;
    fail256              <= 0;


  elsif clock'event and clock = '1' then

    if cv_load = '1' then
      case cv_size is
        when "00" => test_phase <= run_128_vectors;
        when "01" => test_phase <= run_192_vectors;
        when "10" => test_phase <= run_256_vectors;
        when others => test_phase <= undefined;
      end case;
    else
      test_phase <= test_phase;
    end if;

    if done = '1' then

      tmp_data_out := (others => '0');

        if tmp_data_out = data_out then
          test_result <= pass;

          case test_phase is
            when run_128_vectors =>
              pass128 <= pass128 + 1;
              pass192 <= pass192;
              pass256 <= pass256;
            when run_192_vectors =>
              pass128 <= pass128;
              pass192 <= pass192 + 1;
              pass256 <= pass256;
            when run_256_vectors =>
              pass128 <= pass128;
              pass192 <= pass192;
              pass256 <= pass256 + 1;
            when others =>
              pass128 <= pass128;
              pass192 <= pass192;
              pass256 <= pass256;
          end case;

        else
          test_result <= fail;

          case test_phase is
            when run_128_vectors =>
              fail128 <= fail128 + 1;
              fail192 <= fail192;
              fail256 <= fail256;
            when run_192_vectors =>
              fail128 <= fail128;
              fail192 <= fail192 + 1;
              fail256 <= fail256;
            when run_256_vectors =>
              fail128 <= fail128;
              fail192 <= fail192;
              fail256 <= fail256 + 1;
            when others =>
              fail128 <= fail128;
              fail192 <= fail192;
              fail256 <= fail256;
          end case;

        end if;  -- tmp_data_out = data_out


      else

        test_result <= undefined;

      end if;  --  done = '1'

  end if;  -- reset = '1'

end process;


end tb;



configuration cfg_TB_ECB_VK_DEC_ITER of TB_ECB_VK_DEC_ITER is
   for tb
      for top_level : RIJNDAEL_TOP_ITER 
         use entity WORK.RIJNDAEL_TOP_ITER(STRUCTURAL);
      end for;
   end for;
end;
