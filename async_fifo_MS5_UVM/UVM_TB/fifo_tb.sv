class fifo_tb extends uvm_env;

    `uvm_component_utils(fifo_tb)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    fifo_env env;
    fifo_scoreboard scoreboard;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Execution of build phase", UVM_HIGH)
        env = fifo_env#()::type_id::create("env", this);
        scoreboard = fifo_scoreboard::type_id::create("scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        env.agent.monitor_out.fifo_out.connect(scoreboard.fifo_out);
        env.agent.monitor_in.fifo_in.connect(scoreboard.fifo_in);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info("", "  /\\_/\\", UVM_LOW);
        `uvm_info("", " ( o.o )", UVM_LOW);
        `uvm_info("", "  > ^ <", UVM_LOW);
    endfunction

endclass