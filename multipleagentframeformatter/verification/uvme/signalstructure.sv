# SimVision Command Script (Sat Apr 01 12:23:03 AM IST 2023)
#
# Version 15.20.s051
#
# You can restore this configuration with:
#
#     simvision -input /home/vvtrainee39/ganesh/multipleagentframeformatter/verification/uvme/signalstructure.sv
#  or simvision -input /home/vvtrainee39/ganesh/multipleagentframeformatter/verification/uvme/signalstructure.sv database1 database2 ...
#


#
# Preferences
#
preferences set toolbar-txe_waveform_navigate-WaveWindow {
  usual
  shown 1
}
preferences set plugin-enable-svdatabrowser-new 1
preferences set cursorctl-dont-show-sync-warning 1
preferences set toolbar-sendToIndago-WaveWindow {
  usual
  position -pos 1
}
preferences set toolbar-Standard-Console {
  usual
  position -pos 1
}
preferences set toolbar-Search-Console {
  usual
  position -pos 2
}
preferences set plugin-enable-groupscope 0
preferences set toolbar-txe_waveform_view-WaveWindow {
  usual
  shown 1
}
preferences set sb-callstack-in-window 0
preferences set plugin-enable-interleaveandcompare 0
preferences set plugin-enable-waveformfrequencyplot 0

#
# Databases
#
array set dbNames ""
set dbNames(realName1) [ database require wave -hints {
	file ./wave.shm/wave.trn
	file /home/vvtrainee39/ganesh/multipleagentframeformatter/verification/uvme/wave.shm/wave.trn
}]
if {$dbNames(realName1) == ""} {
    set dbNames(realName1) wave
}

#
# Mnemonic Maps
#
mmap new -reuse -name {Boolean as Logic} -radix %b -contents {{%c=FALSE -edgepriority 1 -shape low}
{%c=TRUE -edgepriority 1 -shape high}}
mmap new -reuse -name {Example Map} -radix %x -contents {{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}}

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1366x665+-1+27}] != ""} {
    window geometry "Waveform 1" 1366x665+-1+27
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar select designbrowser
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 36
waveform baseline set -time 1,055,040ns

set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.Frame_Formatter_TOP_clk}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.Frame_Formatter_TOP_rstn}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.in_sop}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.in_eop}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.dest_addr[47:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.preamble[63:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.eth_type[15:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.source_addr[47:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.sync_fifo_wr_en}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.sync_fifo_wr_data[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_fifo_rd_en}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_fifo_rd_clk}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.out_sop}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_fifo_rd_data[31:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.out_eop}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_fifo_empty}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.sync_almost_full}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_fifo_full}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.Frame_Formatter_TOP_sw_rst}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_wr_lvl[5:0]}]}
	} ]]
set id [waveform add -signals [subst  {
	{$dbNames(realName1)::[format {frame_formatter_top_tb.DUT.async_rd_lvl[5:0]}]}
	} ]]

waveform xview limits 0 386800ns
waveform delta load {-item baseline -value 1,055,040ns} {-item baseline -value 1,055,040ns} {-item baseline -value 1,055,040ns}

#
# Waveform Window Links
#

#
# Layout selection
#

