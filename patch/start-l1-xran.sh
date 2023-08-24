#!/bin/bash
set -x
cd $DIR_ROOT_L1_BIN/l1/bin/nr5g/gnb/l1
l1Binary="./l1app"
xrancfg_xml_file="xrancfg_sub6.xml"
phycfg_xml_file="phycfg_xran.xml"

#sudo $l1Binary --cfgfile=$phycfg_xml_file --xranfile=$xrancfg_xml_file
#sudo /opt/intel/oneapi/debugger/2023.0.0/gdb/intel64/bin/gdb-oneapi $l1Binary --cfgfile=$phycfg_xml_file --xranfile=$xrancfg_xml_file

if [ "$1" = "-g" ]; then
	/opt/intel/oneapi/debugger/2023.0.0/gdb/intel64/bin/gdb-oneapi --args $l1Binary --cfgfile=$phycfg_xml_file --xran
else
	$l1Binary --cfgfile=$phycfg_xml_file --xranfile=$xrancfg_xml_file
fi
