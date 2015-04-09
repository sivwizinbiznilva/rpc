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
-- File Name: tb_ecb_vt_enc_pipe.vhdl
-- Author   : NSA
-- Date     : Dec 1999
-- Project  : AES Candidate Evaluation
-- Purpose  : This test bench exercises the top level structural model for
--            a pipelined implementation of RIJNDAEL. All vectors from the
--            ECB mode (encrypt) Known Answer Test, Variable Text are
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


entity TB_ECB_VT_ENC_PIPE is
end;

architecture tb of TB_ECB_VT_ENC_PIPE is

   type RESULT     is (fail, pass, undefined);
   type PHASE      is  (clear, run_128_vectors, run_192_vectors,
                        run_256_vectors, undefined);
   constant PHASE_PIPE_SIZE : integer := LAST_ROUND+1;
   type PHASE_PIPE is array (PHASE_PIPE_SIZE-1 downto 0) of PHASE;



   constant CLK_PER   : time:= 10 ns;
   constant RUNUP_CYCLES : integer := 15;

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
   signal test_phase_pipe      : PHASE_PIPE;
   signal pass128              : integer := 0;
   signal pass192              : integer := 0;
   signal pass256              : integer := 0;
   signal fail128              : integer := 0;
   signal fail192              : integer := 0;
   signal fail256              : integer := 0;



   FILE test_vector_file: text is in
	  "KAT_vectors/ecb_vt_ct.vec";


   component RIJNDAEL_TOP_PIPE

      port( clock      : in std_logic;
            reset      : in std_logic;

            enc_dec_b  : in std_logic;
            data_in    : in SLV_128; 
            data_load  : in std_logic;
            cv_in      : in SLV_256;
            cv_load    : in std_logic;
            cv_size    : in SLV_2;

            data_out   : out SLV_128;
            done       : out std_logic );

   end component;

begin

   top_level : RIJNDAEL_TOP_PIPE
               PORT MAP (clock, reset, enc_dec_b, data_in, data_load,
                         cv_in, cv_load, cv_size, data_out, done);

proc_clock  : process

begin

  WAIT for CLK_PER / 2;
  clock <= not clock;

end process;



run_vectors : process


begin

  reset      <= '1';
  enc_dec_b  <= '1';
  data_in    <= (others => '0'); 
  data_load  <= '0';
  cv_in      <= (others => '0');
  cv_load    <= '0';
  cv_size    <= "00";

  wait for 5*CLK_PER;
  reset <= '0';

  enc_dec_b    <= '1';


  for i in 0 to 0 loop

    cv_size      <= std_logic_vector(TO_UNSIGNED(i,2));
    cv_in        <= (others => '0');
    cv_load      <= '1';
    data_load    <= '0';
    wait for CLK_PER;

    cv_load    <= '0';
    wait for (RUNUP_CYCLES - 1) * CLK_PER;

    data_in(127)          <= '1';
    data_in(126 downto 0) <= (others => '0'); 
    data_load  <= '1';
    wait for CLK_PER;

    for j in 1 to 127 loop

      data_in    <= '0' & data_in(127 downto 1);
      wait for CLK_PER;

    end loop;
    data_load  <= '0';

  wait for 40*CLK_PER;

  end loop;


  data_load  <= '0';
  wait for 1000*CLK_PER;

end process;




check_output : process (clock, reset)

variable L1              : LINE;           -- Predefined in textio
variable tmp_data_out    : SLV_128;

begin

  if reset = '1' then

    test_phase           <= clear;
    for i in PHASE_PIPE_SIZE-1 downto 0 loop
      test_phase_pipe(i) <= clear;
    end loop;
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

    test_phase_pipe <= test_phase &
                       test_phase_pipe(PHASE_PIPE_SIZE-1 downto 1);

    if done = '1' then

      if not (endfile(test_vector_file)) then

        readline(test_vector_file, L1);
        hread(L1, tmp_data_out);

        if tmp_data_out = data_out then
          test_result <= pass;

          case test_phase_pipe(0) is
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

          case test_phase_pipe(0) is
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

        tmp_data_out := (others => 'X');
        test_result <= undefined;

      end if;  -- not (endfile(test_vector_file))

    else

      test_result <= undefined;

    end if;  -- done = '1'

  end if;  -- reset = '1'

end process;


end tb;



configuration cfg_TB_ECB_VT_ENC_PIPE of TB_ECB_VT_ENC_PIPE is
   for tb
      for top_level : RIJNDAEL_TOP_PIPE 
         use entity WORK.RIJNDAEL_TOP_PIPE(STRUCTURAL);
      end for;
   end for;
end;
