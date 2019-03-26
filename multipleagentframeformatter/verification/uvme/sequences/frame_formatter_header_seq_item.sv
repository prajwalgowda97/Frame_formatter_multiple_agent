class frame_formatter_header_seq_item extends uvm_sequence_item;

    rand  logic         in_bypass_en;
    rand  logic [63:0]  preamble;
    rand  logic [47:0]  source_addr;
    rand  logic [47:0]  dest_addr;
    rand  logic [15:0]  Type;
    rand  logic [31:0]  vlan_tag;
    rand  logic         vlan_tag_en;

    function new(string name="frame_formatter_header_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(frame_formatter_header_seq_item)
        `uvm_field_int(in_bypass_en,UVM_ALL_ON)
        `uvm_field_int(preamble,UVM_ALL_ON)
        `uvm_field_int(source_addr,UVM_ALL_ON)
        `uvm_field_int(dest_addr,UVM_ALL_ON)
        `uvm_field_int(Type,UVM_ALL_ON)
        `uvm_field_int(vlan_tag,UVM_ALL_ON)
        `uvm_field_int(vlan_tag_en,UVM_ALL_ON)
    `uvm_object_utils_end

endclass

