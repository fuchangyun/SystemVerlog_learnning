`timescale 1ns/100ps

module router_test_top;
  parameter simulation_cycle = 10;

  bit SystemClock = 0;

  router_io top_io(SystemClock);

  test t(top_io);

  router dut(

    .reset_n	(top_io.reset_n),
    .clock		(top_io.clock),
    .din		(top_io.din),
    .frame_n	(top_io.frame_n),
    .valid_n	(top_io.valid_n),
    .dout		(top_io.dout),
    .valido_n	(top_io.valido_n),
    .busy_n		(top_io.busy_n),
    .frameo_n	(top_io.frameo_n)
  );

  always begin
    #(simulation_cycle/2) SystemClock = ~SystemClock;
  end

endmodule
