class fifo_subscriber extends uvm_subscriber #(fifo_packet);

    `uvm_component_utils(fifo_subscriber)

    fifo_packet packet;

    real cov;

    covergroup cg;

        w_en: coverpoint packet.w_en;
        r_en: coverpoint packet.r_en;
        full: coverpoint packet.full;
        empty: coverpoint packet.empty;

        wr_rd_cp: coverpoint {packet.w_en, packet.r_en}{
            bins idle  = {2'b00};
            bins write_only = {2'b10};
            bins read_only = {2'b01};
            bins both = {2'b11};
        }

    endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        packet = fifo_packet#()::type_id::create("packet", this);
        cg = new;
    endfunction

    virtual function void write(fifo_packet t);
        packet = t;

        cg.sample();

    endfunction

endclass