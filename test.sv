program automatic test(router_io.TB rtr_io);

  `include "Generator.sv"
  `include "Packet.sv"
  `include "Driver.sv"
  `include "Receiver.sv"
  `include "Scoreboard.sv"

  Packet pkt[];
  pkt_mbox in_box[];
  int run_for_n_packets;     // number of packets to test

  Generator gen[];                        // generator
  Driver dri[];
  Receiver rec[];
  Scoreboard scb[];

  int p;


  initial begin
    run_for_n_packets = 10;
    gen = new[10];
    pkt = new[16];
    in_box = new[16];
    dri = new[16];
    rec = new[16];
    scb = new[16];

    //$display(gen.size(),"%%%%%");
    foreach (gen[i]) gen[i] = new($sformatf("gen[%0d]", i), i);
    reset();
    p=0;
    repeat(run_for_n_packets) begin
      //$display(run_for_n_packets);
      //$display("@@@***",gen[p].port_id);
      gen[p].start();
      //foreach(gen[p].da_list[i]) $display(gen[p].da_list[i]);
      //$display("postgen",p);
      //gen[0].pkt2send.display("pkt2send");
      //foreach(gen[0].out_box[i])$display("out_box",out_box[i]);
      //pkt.display();
      foreach (gen[p].out_box[i])in_box[i]=gen[p].out_box[i];
      foreach(in_box[i]) in_box[i].get(pkt[i]);//.gen[0].out_box;
      foreach(pkt[i]) dri[i]=new("dri",pkt[i],rtr_io);
      foreach(pkt[i]) rec[i]=new("rec",pkt[i],rtr_io);
      foreach(pkt[i]) scb[i]=new("scb",pkt[i],rec[i].pkt2cmp);
      //$display("&&&&&",in_box,"*****");
      fork
        //foreach(dri[i]) dri[i].send();
        dri[0].send();dri[1].send();dri[2].send();dri[3].send();
        dri[4].send();dri[5].send();dri[6].send();dri[7].send();
        dri[8].send();dri[9].send();dri[10].send();dri[11].send();
        dri[12].send();dri[13].send();dri[14].send();dri[15].send();
        //foreach(rec[i]) rec[i].recv();
        rec[0].recv();rec[1].recv();rec[2].recv();rec[3].recv();
        rec[4].recv();rec[5].recv();rec[6].recv();rec[7].recv();
        rec[8].recv();rec[9].recv();rec[10].recv();rec[11].recv();
        rec[12].recv();rec[13].recv();rec[14].recv();rec[15].recv();
      join
      //foreach(scb[i]) scb[i].check();
      $display("************ the %dth pkt compare result ************",p+1);
      scb[0].check();scb[1].check();scb[2].check();scb[3].check();
      scb[4].check();scb[5].check();scb[6].check();scb[7].check();
      scb[8].check();scb[9].check();scb[10].check();scb[11].check();
      scb[12].check();scb[13].check();scb[14].check();scb[15].check();
      //$display("nimacao");
      repeat(4) @(rtr_io.cb);
      p++;
    end
    repeat(4) @(rtr_io.cb);
  end
  //end
  
  task reset();
    rtr_io.reset_n = 1'b0;
    rtr_io.cb.frame_n <= '1;
    rtr_io.cb.valid_n <= '1;
    repeat(2) @rtr_io.cb;
    rtr_io.cb.reset_n <= 1'b1;
    repeat(15) @(rtr_io.cb);
  endtask: reset



endprogram: test
