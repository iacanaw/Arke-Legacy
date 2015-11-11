--------------------------------------------------------------------------------------
-- DESIGN UNIT  : Router Unit                                                       --
-- DESCRIPTION  :                                                                   --
-- AUTHOR       : Everton Alceu Carara, Iaçanã Ianiski Weber & Michel Duarte        --
-- CREATED      : Apr 8th, 2015                                                     --
-- VERSION      : 1.0                                                               --
-- HISTORY      : Version 0.1 - Apr 8th, 2015                                       --
--              : Version 0.2 - Jul 9th, 2015                                       --
--              : Version 0.2.1 - Set 18th, 2015                                    --
--------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Arke_pkg.all;

entity Router is
generic(address: std_logic_vector(DATA_WIDTH-1 downto 0) := x"0015");
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        
        -- Data and control inputs
        data_in     : in Array1D_data(0 to PORTS-1);
        control_in  : in Array1D_control(0 to PORTS-1);
        
        -- Data and control outputs
        data_out    : out Array1D_data(0 to PORTS-1);
        control_out : out Array1D_control(0 to PORTS-1)
    );
end Router;

architecture Router of Router is
    signal routingTable         : Array1D_3bits(0 to PORTS-1);  -- From Switch Control to crossbar
    signal crossbarDataIn       : Array1D_data(0 to PORTS-1);   -- Data out from Input Buffers to Crossbar
    signal crossbarControlIn    : Array1D_control(0 to PORTS-1);-- Control out signals from Input Buffers to Crossbar
    signal crossbarControlOut   : Array1D_control(0 to PORTS-1);
    
    -- Signals to connect Switch Control and Input Buffers
    signal routingRequest       : std_logic_vector(PORTS-1 downto 0);
    signal routingAck           : std_logic_vector(PORTS-1 downto 0);
    signal sending              : std_logic_vector(PORTS-1 downto 0);
    
begin
    
--------------------------------------------------------------------------------------
-- CROSSBAR
--------------------------------------------------------------------------------------
CROSSBAR: entity work.Crossbar
    port map(   
        routingTable => routingTable,
        data_in      => crossbarDataIn,
        control_in   => crossbarControlIn,
        data_out     => data_out,
        control_out  => crossbarControlOut
    );
    
--------------------------------------------------------------------------------------
-- SWITCH CONTROL
--------------------------------------------------------------------------------------
SWITCH_CONTROL: entity work.SwitchControl
    generic map(address  => address)
    port map(
        clk         => clk,
        rst         => rst,
        
        -- Input Buffers interface
        routingReq  => routingRequest,
        routingAck  => routingAck,
        data        => crossbarDataIn,
        sending     => sending,
        
        -- Crossbar interface
        table       => routingTable
    );
--------------------------------------------------------------------------------------
-- Buffers instantiation with for ... generate
--------------------------------------------------------------------------------------
    PortBuffers: for n in 0 to PORTS-1 generate
        INPUT_BUFFER: entity work.InputBuffer(pipeline_4_cycles) 
        port map(
            clk                     => clk,
            rst                     => rst,
            
            -- Router interface. Signals coming from the neighboring router.
            data_in                 => data_in(n),
            control_in(EOP)         => control_in(n)(EOP),
            control_in(RX)          => control_in(n)(RX),
            
            -- Crossbar interface
            control_in(STALL_GO)    => crossbarControlOut(n)(STALL_GO),           
            data_out                => crossbarDataIn(n),
            control_out(EOP)        => crossbarControlIn(n)(EOP),
            control_out(RX)         => crossbarControlIn(n)(RX),
            
            -- Router interface. STALL_GO signal to the neighboring router.
            control_out(STALL_GO)   => control_out(n)(STALL_GO),
            
            -- Switch Control interface
            routingRequest          => routingRequest(n),
            routingAck              => routingAck(n),
            sending                 => sending(n)
        );
        
        -- Router interface. Signals coming from crossbar depending on the routingTable.
        control_out(n)(EOP)            <= crossbarControlOut(n)(EOP);
        control_out(n)(RX)             <= crossbarControlOut(n)(RX);
        
        -- Router interface. STALL_GO signal from the neighboring routers.
        crossbarControlIn(n)(STALL_GO) <= control_in(n)(STALL_GO); 
        
    end generate;

end architecture;