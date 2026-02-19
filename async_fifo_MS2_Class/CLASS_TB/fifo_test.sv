// import fifo_pkg::*;
class fifo_test;

    fifo_env #(.DATA_WIDTH(8)) env;

    function new(virtual interface fifo_if vif);
        env = new(vif);
    endfunction

    task run();
        env.run();
        wait(env.generator.num_of_packets == env.scoreboard.packets_received);
        $finish;
    endtask
    
endclass