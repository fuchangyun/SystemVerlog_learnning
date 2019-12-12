`ifndef INC_GENERATOR_SV
`define INC_GENERATOR_SV 
`include "Packet.sv"
typedef mailbox #(Packet) pkt_mbox;

class Generator;
  //int run_for_n_packets =10;
  string  name;   // unique identifier
  Packet  pkt2send; // stimulus Packet object
  pkt_mbox out_box[]; // mailbox to Drivers
  int port_id = -1; // port_id of connected Driver
  int temp;
  static bit[3:0] da_list[$];
  static int pkts_generated = 0; //packet count across all generators

  extern function new(string name = "Generator", int port_id);
  extern virtual task gen();
  extern virtual task start();
endclass: Generator

function Generator::new(string name, int port_id);
  this.name = name;
  this.pkt2send = new();
  this.out_box = new[16]; //1-deep mailbox
  foreach(this.out_box[i])
    this.out_box[i] = new();
  this.port_id = port_id;
endfunction: new

task Generator::gen();
  this.pkt2send.name = $sformatf("Packet[%0d]", this.pkts_generated++);
  //$display("gogogogogogogogo",this.pkts_generated);
  while(this.pkts_generated<=16)begin
    this.pkt2send.randomize();
    foreach(this.da_list[i]) if (this.pkt2send.da == this.da_list[i]) temp++;
    if (temp==0)  begin 
      da_list.push_back(this.pkt2send.da);
      //$display("random",this.pkt2send.da);
      //$display(this.da_list);
      break; 
    end
    temp=0;
  end

  //if ((!this.pkt2send.randomize())||(port_id == -1))// with {if (port_id != -1) sa == port_id;})
  //begin
    //$display("\n%m\n[ERROR]%t Randomization Failed!\n", $realtime,port_id);
    //$finish;
  //end
  //else 
  if (port_id != -1) this.pkt2send.sa = this.pkts_generated-1;
  //this.pkt2send.display("nima");
endtask: gen

task Generator::start();
  //fork
    this.pkts_generated = 0;
    da_list.delete();
    while (this.pkts_generated < 16) begin
      temp=0;
      this.gen();
      //$display("ii am hear!",this.pkts_generated);
      //$display("ii am hear!",this.pkts_generated);
      //this.pkt2send.randomize();
      //$display("u are hear!",this.pkts_generated);
      //this.pkt2send.display();
      begin
        Packet pkt = this.pkt2send.copy();
        //pkt.display("kpt");
        this.out_box[this.pkts_generated-1].put(pkt);
        //$display("*****","this.out_box","&&&&&",this.pkts_generated);
      end
      //pkt.display("kpt");
    end
  //join_none
endtask: start
`endif
