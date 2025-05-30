# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

""" ASAP7 "rev 26" 6 track standard cell library using super-low VT transistors """

# ------------------------------------------------------------------------
asap7_cells_files(
    name = "asap7-cells-sc6t_rev26_slvt",
    rev = "26",
    tracks = "6t",
    vt = "slvt",
)

open_road_pdk_configuration(
    name = "open_road-asap7-sc6t_rev26_slvt",
    cell_site = "asap7sc6t",
    cts_buffer_cell = "BUFx4_ASAP7_6t_SL",
    do_not_use_cell_list = [
        "*x1_ASAP7*",
        "*x1p*_ASAP7*",
        "*xp*_ASAP7*",
        "SDF*",
        "ICG*",
        "DFFH*",
    ],
    endcap_cell = "TAPCELL_ASAP7_6t_SL",
    fill_cells = [
        "FILLERxp5_ASAP7_6t_SL",
        "DECAPx1_ASAP7_6t_SL",
        "DECAPx2_ASAP7_6t_SL",
        "DECAPx4_ASAP7_6t_SL",
        "DECAPx6_ASAP7_6t_SL",
        "DECAPx10_ASAP7_6t_SL",
    ],
    global_placement_cell_pad = 2,
    global_routing_clock_layers = "M2-M7",
    global_routing_layer_adjustments = {
        "M2": "0.5",
        "M3": "0.5",
        "M4": "0.5",
        "M5": "0.5",
        "M6": "0.5",
        "M7": "0.5",
    },
    global_routing_signal_layers = "M2-M7",
    klayout_tech_file = "//dependency_support/org_theopenroadproject_asap7_pdk_r1p7:asap7.lyt",
    pdn_config = "//dependency_support/org_theopenroadproject_asap7_pdk_r1p7:pdn_config_1x.pdn",
    pin_horizontal_metal_layer = "M4",
    pin_vertical_metal_layer = "M5",
    rc_script_configuration = "//dependency_support/org_theopenroadproject_asap7_pdk_r1p7:rc_script_1x.tcl",
    tap_cell = "TAPCELL_ASAP7_6t_SL",
    tapcell_distance = 25,
    tie_high_port = "TIEHIxp5_ASAP7_6t_SL/H",
    tie_low_port = "TIELOxp5_ASAP7_6t_SL/L",
    tie_separation = 0,
    tracks_file = "//dependency_support/org_theopenroadproject_asap7_pdk_r1p7:tracks_1x.tcl",
    wire_rc_clock_metal_layer = "M5",
    wire_rc_signal_metal_layer = "M2",
)
