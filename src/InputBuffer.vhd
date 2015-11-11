--------------------------------------------------------------------------------------
-- DESIGN UNIT  : InputBuffer                                                       --
-- DESCRIPTION  :                                                                   --
-- AUTHOR       : Everton Alceu Carara, Iaçanã Ianiski Weber & Michel Duarte        --
-- CREATED      : Apr 8th, 2015                                                     --
-- VERSION      : 1.0                                                               --
-- HISTORY      : Version 0.1 - May 13th, 2015                                      --
--              : Version 0.2.1 - Set 18th, 2015                                    --
--------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Arke_pkg.all;

entity InputBuffer is
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        
        -- Receiving/Sending Interface
        data_in         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        control_in      : in std_logic_vector(CONTROL_WIDTH-1 downto 0);
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        control_out     : out std_logic_vector(CONTROL_WIDTH-1 downto 0);
        
        -- Switch Control Interface
        routingRequest  : out std_logic;
        routingAck      : in  std_logic;
        sending         : out std_logic
    );
end InputBuffer;

-- This architecture implies a 4 cycles pipeline router due to the register used to store the routingRequest output
architecture pipeline_4_cycles of InputBuffer is

    type state is (IDLE, WAITING_ACK, TRANSMITTING);
    signal currentState : state;
    
    -- "first" and "last" indexes width calculated based on BUFFER_DEPTH
    -- Used to control the circular queue
    signal first,last       : UNSIGNED((log2(BUFFER_DEPTH)-1) downto 0);
    signal available_slot   : std_logic;
    
    -- Buffer works in a circular queue - first in first out
    signal queue            : DataBuff;
    -- Store the EOP signal relative to each flit stored in queue 
    signal eop_buff         : std_logic_vector(BUFFER_DEPTH-1 downto 0);

begin

    ------------------------------------------------------
    -- Controls the flit receiving and storing on queue --
    ------------------------------------------------------
    process(rst,clk) -- async reset
    begin
        if rst='1' then
            last <= (others=>'0'); 
            eop_buff <= (others=>'0');
        elsif rising_edge(clk) then
            -- If the buffer is receiving data and there is an available slot in the buffer then
            -- store the data flit in the free slot pointed by last
            -- Each buffer slot has an EOP flag assigned to it (eop_buff)
            if control_in(RX) = '1' and available_slot = '1' then
                queue(TO_INTEGER(last)) <= data_in;
                eop_buff(TO_INTEGER(last)) <= control_in(EOP);
                last <= last + 1;                                        
            end if;
        end if;
    end process;
        
    -- Determine if there is any available slot in the buffer
    available_slot <= '0' when ((TO_INTEGER(first) = 0) and (last = BUFFER_DEPTH-1)) or (first = last+1) else '1';    
    
    -- Connect the queue output (next to-be-transmitted flit) to the data output
    data_out <= queue(TO_INTEGER(first));
    
    -- Connect the EOP signal to the control output
    control_out(EOP) <= eop_buff(TO_INTEGER(first));
    
    -- Connect the STALL_GO signal to the control output
    control_out(STALL_GO) <= available_slot;
    
    -- Signal transmission to the receiver
    control_out(TX) <= '1' when currentState = TRANSMITTING and first /= last else '0';
    
    -- Warns the SwitchControl that the routed port is in use
    sending <= '1' when currentState = TRANSMITTING else '0';
    
    ------------------------------------------------------------
    -- Controls the flit transmission and removing from queue --
    ------------------------------------------------------------
    process(rst,clk) -- async reset
    begin
        if rst='1' then
            first <= (others=>'0');
            currentState <= IDLE;
            routingRequest <= '0';

        elsif rising_edge(clk) then
            case currentState is
            
                -- Request routing for current package
                when IDLE =>
                if currentState = IDLE and last /= first then
                    routingRequest <= '1';
                    currentState <= WAITING_ACK;
                else 
                    currentState <= IDLE;
                end if;
                
                -- Waits the ACK signal from SwitchControl
                when WAITING_ACK =>
                    if routingAck = '1' then
                        currentState <= TRANSMITTING;
                        routingRequest <= '0';
                    else
                        currentState <= WAITING_ACK;
                    end if;
                
                -- Send package flits
                when TRANSMITTING =>
                
                    -- Verifies if receiver has an available slot and there is data to be sent
                    if control_in(STALL_GO)='1' and last /= first then
                        first <= first + 1;     -- Set the next flit to be transmitted
                        
                        -- If the last packet flit was transmitted, finish the transmission
                        if eop_buff(TO_INTEGER(first)) = '1' then
                            currentState <= IDLE;
                        else
                            currentState <= TRANSMITTING;
                        end if;
                        
                    else
                        currentState <= TRANSMITTING;
                    end if;
                    
                when others =>
                    currentState <= IDLE;
                    
            end case;
        end if;
    end process;
    
end architecture;

-- This architecture implies a 3 cycles pipeline router since the routingRequest output is generates combinatorially
architecture pipeline_3_cycles of InputBuffer is

    type state is (IDLE, TRANSMITTING);
    signal currentState : state;
    
    -- "first" and "last" indexes width calculated based on BUFFER_DEPTH
    -- Used to control the circular queue
    signal first,last       : UNSIGNED((log2(BUFFER_DEPTH)-1) downto 0);
    signal available_slot   : std_logic;
    
    -- Buffer works in a circular queue - first in first out
    signal queue            : DataBuff;
    -- Store the EOP signal relative to each flit stored in queue 
    signal eop_buff         : std_logic_vector(BUFFER_DEPTH-1 downto 0);

begin

    ------------------------------------------------------
    -- Controls the flit receiving and storing on queue --
    ------------------------------------------------------
    process(rst,clk) -- async reset
    begin
        if rst='1' then
            last <= (others=>'0'); 
            eop_buff <= (others=>'0');
        elsif rising_edge(clk) then
            -- If the buffer is receiving data and there is an available slot in the buffer then
            -- store the data flit in the free slot pointed by last
            -- Each buffer slot has an EOP flag assigned to it (eop_buff)
            if control_in(RX) = '1' and available_slot = '1' then
                queue(TO_INTEGER(last)) <= data_in;
                eop_buff(TO_INTEGER(last)) <= control_in(EOP);
                last <= last + 1;                                        
            end if;
        end if;
    end process;
        
    -- Determine if there is any available slot in the buffer
    available_slot <= '0' when ((TO_INTEGER(first) = 0) and (last = BUFFER_DEPTH-1)) or (first = last+1) else '1';    
    
    -- Connect the queue output (next to-be-transmitted flit) to the data output
    data_out <= queue(TO_INTEGER(first));
    
    -- Connect the EOP signal to the control output
    control_out(EOP) <= eop_buff(TO_INTEGER(first));
    
    -- Connect the STALL_GO signal to the control output
    control_out(STALL_GO) <= available_slot;
    
    -- Signal transmission to the receiver
    control_out(TX) <= '1' when currentState = TRANSMITTING and first /= last else '0';
    
    -- Request routing for current package 
    routingRequest <= '1' when currentState = IDLE and last /= first else '0';
    
    -- Warns the SwitchControl that the routed port is in use
    sending <= '1' when currentState = TRANSMITTING else '0';
    
    ------------------------------------------------------------
    -- Controls the flit transmission and removing from queue --
    ------------------------------------------------------------
    process(rst,clk) -- async reset
    begin
        if rst='1' then
            first <= (others=>'0');
            currentState <= IDLE;
            
        elsif rising_edge(clk) then
            case currentState is
            
                -- Waits the ACK signal from SwitchControl
                when IDLE =>
                    if routingAck = '1' then
                        currentState <= TRANSMITTING;
                    else
                        currentState <= IDLE;
                    end if;
                
                -- Send package flits
                when TRANSMITTING =>
                
                    -- Verifies if receiver has an available slot and there is data to be sent
                    if control_in(STALL_GO)='1' and last /= first then
                        first <= first + 1;     -- Set the next flit to be transmitted
                        
                        -- If the last packet flit was transmitted, finish the transmission
                        if eop_buff(TO_INTEGER(first)) = '1' then
                            currentState <= IDLE;
                        else
                            currentState <= TRANSMITTING;
                        end if;
                        
                    else
                        currentState <= TRANSMITTING;
                    end if;
                    
                when others =>
                    currentState <= IDLE;
                    
            end case;
        end if;
    end process;
    
end architecture;