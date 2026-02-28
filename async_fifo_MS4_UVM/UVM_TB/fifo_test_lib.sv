class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    fifo_tb tb;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_int::set(this, "*", "recording_detail", 1);
        `uvm_info(get_type_name(), "Execution of build phase", UVM_HIGH);
        tb = fifo_tb::type_id::create("tb", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for", get_full_name()}, UVM_HIGH)
    endfunction

    virtual function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 20000ns);
    endtask

endclass

class test2 extends base_test;

    `uvm_component_utils(test2)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence", fifo_5_packets::get_type());
    endfunction

endclass
