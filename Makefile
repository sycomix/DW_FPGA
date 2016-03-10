#Rules to use the Makefile:
#  1) directory structure:
#        Verilog files: chipname/chipname.srcs/HDL/*.v .sv .vh .svh  (and subdirs below that)
#        Clock IP:      chipname/chipname.srcs/IP/*clk*/*clk*.xci
#        Memory IP:     chipname/chipname.srcs/IP/*mem*/*mem*.xci
#        tcl files:     chipname/chipname.srcs/tcl/*.tcl
#        sim files:     chipname/chipname.srcs/sim/*.v .sv .vh .svh (and subdirs below at) (TBD)
#
#  2) All files within this structure will be acted upon.
#        Change extensions for temporary files (testcode.sv.temp)
#
#  3) Clock IP is handled differently from Memory IP
#         Clock IP must have clk somewhere in the ip name.
#         Memory IP must have mem somewhere in the ip name.
#
#  4) Only the HDL top level must start with top. (top.sv top_chip.sv etc.)
#         And must be located just below HDL (NO subdir)
#
rootDir   := $(CURDIR)
srcDir    := $(CURDIR)/$(wildcard *.srcs)
HDLDir    := $(srcDir)/HDL
IPDir     := $(srcDir)/IP
tclDir    := $(srcDir)/tcl
xdcDir    := $(srcDir)/constrs_1
runDir    := $(patsubst %.srcs,%.runs,$(srcDir))
makeDir   := $(runDir)/make

HDLFiles  := $(shell find $(HDLDir) -iname '*.sv')
topFiles  := $(notdir $(wildcard $(HDLDir)/top*.sv $(HDLDir)/top*.v))
clkFiles  := $(wildcard $(IPDir)/*clk*/*.xci)
memFiles  := $(wildcard $(IPDir)/*mem*/*.xci)
xdcFiles  := $(wildcard $(xdcDir)/*.xdc)
xprFile   := $(wildcard *.xpr)

clkTargets  := $(patsubst %.xci,%.dcp,$(clkFiles))
memTargets  := $(patsubst %.xci,%.xml,$(memFiles))
topBase     := $(strip $(subst .v,,$(subst .sv,,$(topFiles))))
synTargets  := $(runDir)/synth_1/$(topBase).dcp
implTargets := $(runDir)/impl_1/$(topBase)_routed.dcp

ipTouch    := $(makeDir)/ip.touch
elabTouch  := $(makeDir)/elab.touch
synTouch   := $(makeDir)/syn.touch
implTouch  := $(makeDir)/impl.touch

joblist    := $(makeDir)/joblist 
junk       := $(shell mkdir -p $(makeDir))
junk       := $(shell rm -f $(joblist))

all: $(implTargets) $(implTouch)
	@if [ -f $(joblist) ]     ;\
	then echo vivado -mode batch -source $(tclDir)/dojob.tcl $(xprFile) -tclargs $(strip $(shell cat $(joblist))) ;\
	vivado -mode batch -source $(tclDir)/dojob.tcl $(xprFile) -tclargs $(strip $(shell cat $(joblist))) ;\
	else echo nothing to do   ;\
	fi                         
	@echo all done

$(implTouch): $(implTargets)

$(implTargets): $(synTouch)  $(synTargets) $(tclDir)/impl_top.tcl $(xdcFiles)
	@echo impl_top.tcl nofile >> $(joblist)  ;\
	rm -rf $(runDir)/impl_1                  ;\
	touch $(implTouch)

$(synTouch): $(synTargets)

$(synTargets): $(ipTouch) $(HDLFiles) $(clkTargets) $(memTargets) $(tclDir)/synth_top.tcl
	@echo synth_top.tcl nofile >> $(joblist)  ;\
	rm -rf $(runDir)/synth_1                  ;\
	touch $(synTouch)

$(ipTouch): $(memTargets) $(clkTargets)

$(clkTargets): %.dcp : %.xci $(tclDir)/clk.tcl
	@echo clk.tcl $(basename $(notdir $<)) >> $(joblist)  ;\
	touch $(ipTouch)

$(memTargets): %.xml : %.xci $(tclDir)/mem.tcl
	@echo mem.tcl $(basename $(notdir $<)) >> $(joblist)  ;\
	touch $(ipTouch)

#Not required
$(elabTouch): $(ipTouch) $(HDLFiles) $(clkTargets) $(memTargets) $(tclDir)/elab.tcl
	@echo elab.tcl nofile >> $(joblist)  ;\
	touch $@

.PHONY: clean

clean:
	rm -f $(clkTargets)
	rm -f $(memTargets)
	rm -f $(synTargets)
	rm -f $(implTargets)
	rm -f vivado*
	rm -f $(makeDir)/*
