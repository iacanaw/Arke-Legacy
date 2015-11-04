--------------------------------------------------------------------------------------
-- DESIGN UNIT  : Crossbar                                                          --
-- DESCRIPTION  :                                                                   --
-- AUTHOR       : Everton Alceu Carara, Iaçanã Ianiski Weber & Michel Duarte        --
-- CREATED      : Jul 6th, 2015                                                     --
-- VERSION      : 1.0                                                             --
-- HISTORY      : Version 0.1 - Jul 6th, 2015                                       --
--              : Version 0.2.1 - Set 18th, 2015                                    --
--------------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Arke_pkg.all;

entity Crossbar is
    port(   
        -- Switch Control interface
        routingTable    : in Array1D_3bits(0 to PORTS-1);
        
        -- Input buffers interface
        data_in         : in Array1D_data(0 to PORTS-1);
        control_in      : in Array1D_control(0 to PORTS-1);
        
        -- Router output ports interface
        data_out        : out Array1D_data(0 to PORTS-1);
        control_out     : out Array1D_control(0 to PORTS-1)
    );
end Crossbar;

architecture full of Crossbar is
begin

    NoC2D : if(DIM_X>1 and DIM_Y>1 and DIM_Z=1) generate
        --DATA_OUT
        DATAOUT: for i in 0 to PORTS-1 generate
            data_out(i) <= data_in(LOCAL) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                           data_in(EAST) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                           data_in(SOUTH) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                           data_in(WEST) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                           data_in(NORTH);
        end generate;

        --EOP
        EOPP: for i in 0 to PORTS-1 generate
            control_out(i)(EOP) <= control_in(LOCAL)(EOP) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                                   control_in(EAST)(EOP) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                                   control_in(SOUTH)(EOP) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                                   control_in(WEST)(EOP) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                                   control_in(NORTH)(EOP) when TO_INTEGER(UNSIGNED(routingTable(NORTH))) = i else
                                   '0';
        end generate;

        --RX/TX
        RXTX: for i in 0 to PORTS-1 generate
            control_out(i)(RX) <= control_in(LOCAL)(RX) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                                  control_in(EAST)(RX) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                                  control_in(SOUTH)(RX) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                                  control_in(WEST)(RX) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                                  control_in(NORTH)(RX) when TO_INTEGER(UNSIGNED(routingTable(NORTH))) = i else
                                  '0';
        end generate;

        --STALL_GO
        STALLGO: for i in 0 to PORTS-1 generate
            control_out(i)(STALL_GO) <= control_in(LOCAL)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = LOCAL else
                                        control_in(EAST)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = EAST else
                                        control_in(SOUTH)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = SOUTH else
                                        control_in(WEST)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = WEST else
                                        control_in(NORTH)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = NORTH else
                                        '0';
        end generate;
    end generate;

    NoC3D : if(DIM_X>1 and DIM_Y>1 and DIM_Z>1) generate
        --DATA_OUT
        DATAOUT: for i in 0 to PORTS-1 generate
            data_out(i) <= data_in(LOCAL) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                           data_in(EAST) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                           data_in(SOUTH) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                           data_in(WEST) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                           data_in(NORTH) when TO_INTEGER(UNSIGNED(routingTable(NORTH))) = i else
                           data_in(UP) when TO_INTEGER(UNSIGNED(routingTable(UP))) = i else
                           data_in(DOWN);
        end generate;

        -- --EOP
        EOPP: for i in 0 to PORTS-1 generate
            control_out(i)(EOP) <= control_in(LOCAL)(EOP) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                                   control_in(EAST)(EOP) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                                   control_in(SOUTH)(EOP) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                                   control_in(WEST)(EOP) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                                   control_in(NORTH)(EOP) when TO_INTEGER(UNSIGNED(routingTable(NORTH))) = i else
                                   control_in(UP)(EOP) when TO_INTEGER(UNSIGNED(routingTable(UP))) = i else
                                   control_in(DOWN)(EOP) when TO_INTEGER(UNSIGNED(routingTable(DOWN))) = i else
                                   '0';
        end generate;

        --RX/TX
        RXTX: for i in 0 to PORTS-1 generate
            control_out(i)(RX) <= control_in(LOCAL)(RX) when TO_INTEGER(UNSIGNED(routingTable(LOCAL))) = i else
                                  control_in(EAST)(RX) when TO_INTEGER(UNSIGNED(routingTable(EAST))) = i else
                                  control_in(SOUTH)(RX) when TO_INTEGER(UNSIGNED(routingTable(SOUTH))) = i else
                                  control_in(WEST)(RX) when TO_INTEGER(UNSIGNED(routingTable(WEST))) = i else
                                  control_in(NORTH)(RX) when TO_INTEGER(UNSIGNED(routingTable(NORTH))) = i else
                                  control_in(UP)(RX) when TO_INTEGER(UNSIGNED(routingTable(UP))) = i else
                                  control_in(DOWN)(RX) when TO_INTEGER(UNSIGNED(routingTable(DOWN))) = i else
                                  '0';
        end generate;

        --STALL_GO
        STALLGO: for i in 0 to PORTS-1 generate
            control_out(i)(STALL_GO) <= control_in(LOCAL)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = LOCAL else
                                        control_in(EAST)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = EAST else
                                        control_in(SOUTH)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = SOUTH else
                                        control_in(WEST)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = WEST else
                                        control_in(NORTH)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = NORTH else
                                        control_in(UP)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = UP else
                                        control_in(DOWN)(STALL_GO) when TO_INTEGER(UNSIGNED(routingTable(i))) = DOWN else
                                        '0';
        end generate;
    end generate;

end architecture;