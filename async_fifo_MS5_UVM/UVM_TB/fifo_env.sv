class fifo_env #(parameter DATA_WIDTH = 16) extends uvm_env;

    `uvm_component_utils(fifo_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    fifo_agent agent;
    fifo_subscriber subscriber;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = fifo_agent#(DATA_WIDTH)::type_id::create("agent", this);
        subscriber = fifo_subscriber::type_id::create("subscriber", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        agent.monitor_out.fifo_cov_out.connect(subscriber.analysis_export);
        agent.monitor_in.fifo_cov_in.connect(subscriber.analysis_export);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation for", get_full_name()}, UVM_HIGH)
    endfunction

endclass