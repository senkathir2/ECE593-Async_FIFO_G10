class fifo_agent #(parameter DATA_WIDTH = 16) extends uvm_agent;

    `uvm_component_utils_begin(fifo_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //instantiate monitor
    fifo_monitor #(DATA_WIDTH) monitor_out;
    fifo_monitor_in #(DATA_WIDTH) monitor_in;
    fifo_driver #(DATA_WIDTH) driver;
    fifo_sequencer sequencer;

    virtual function void build_phase(uvm_phase phase);
        //create monitor
        monitor_out = fifo_monitor#()::type_id::create("monitor_out", this);
        monitor_in = fifo_monitor_in#()::type_id::create("monitor_in", this);
        if(is_active == UVM_ACTIVE) begin
            sequencer = fifo_sequencer::type_id::create("sequencer", this);
            driver = fifo_driver#()::type_id::create("driver", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if(is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for", get_full_name()}, UVM_HIGH)
    endfunction

endclass