--------------------------------------------------------------------------------------
-- DESIGN UNIT  : NoC test bench                                                           --
-- DESCRIPTION  :                                                                   --
-- AUTHOR       : Everton Alceu Carara, Iaçanã Ianiski Weber & Michel Duarte        --
-- CREATED      : Aug 10th, 2015                                                    --
-- VERSION      : v1.0                                                             --
-- HISTORY      : Version 0.1 - Aug 10th, 2015                                      --
--              : Version 0.2.1 - Set 18th, 2015                                    --
--------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Text_Package.all;
use work.Arke_pkg.all;

entity NoC_tb is
end NoC_tb;

architecture NoC_tb of NoC_tb is

    signal clk         : std_logic := '0';
    signal rst         : std_logic;
    signal data_in     : Array3D_data(0 to DIM_X-1, 0 to DIM_Y-1, 0 to DIM_Z-1);
    signal data_out    : Array3D_data(0 to DIM_X-1, 0 to DIM_Y-1, 0 to DIM_Z-1);
    signal control_in  : Array3D_control(0 to DIM_X-1, 0 to DIM_Y-1, 0 to DIM_Z-1);
    signal control_out : Array3D_control(0 to DIM_X-1, 0 to DIM_Y-1, 0 to DIM_Z-1);

begin
    
    clk <= not clk after 5 ns;
    
    rst <= '1', '0' after 3 ns;
    
    DataManager_x: for x in 0 to DIM_X-1 generate
        DataManager_y: for y in 0 to DIM_Y-1 generate
            DataManager_z: for z in 0 to DIM_Z-1 generate
                DataManager: entity work.DataManager
                generic map(fileNameIn => "simulation/data/fileIn" & IntegerToString(x) & '_' & IntegerToString(y) & '_' & IntegerToString(z) & ".txt",
                        fileNameOut => "simulation/data/fileOut" & IntegerToString(x) & '_' & IntegerToString(y) & '_' & IntegerToString(z) & ".txt")
                port map(
                    clk         => clk,
                    rst         => rst,
                    data_in     => data_out(x,y,z),
                    control_in  => control_out(x,y,z),
                    data_out    => data_in(x,y,z),
                    control_out => control_in(x,y,z)
                );
                
            end generate;
        end generate;
    end generate;
    
    ARKE: entity work.NoC
    port map(
        clk         => clk,
        rst         => rst,
        data_in     => data_in,
        data_out    => data_out,
        control_in  => control_in,
        control_out => control_out
    );
    
end NoC_tb;
