interface frame_formatter_header_interface();
        
	logic         in_bypass_en;
	logic [63:0]  preamble;
	logic [47:0]  source_addr;
	logic [47:0]  dest_addr;
	logic [15:0]  Type;
	logic [31:0]  vlan_tag;
	logic         vlan_tag_en;

endinterface
