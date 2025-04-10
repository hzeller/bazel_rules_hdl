# Copyright 2022 Google LLC
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

"""Design analysis utilities written using modular hardware flows."""

load("//flows:flows.bzl", "flow_binary", "tcl_script_prefix")
load("//flows/openroad:build_defs.bzl", "assemble_openroad_step", "read_standard_cells")
load("//flows/yosys:build_defs.bzl", "yosys_synth_file_step")
load("//pdk:build_defs.bzl", "StandardCellInfo")

def _analyze_netlist_step_impl(ctx):
    tcl_commands = [tcl_script_prefix]

    (read_cells_commands, read_cells_runfiles) = read_standard_cells(ctx)

    tcl_commands.extend(read_cells_commands)

    base_script = ctx.actions.declare_file(ctx.attr.name + "_base.tcl")
    full_script = ctx.actions.declare_file(ctx.attr.name + ".tcl")

    ctx.actions.write(
        output = base_script,
        content = "\n".join(tcl_commands + ["\n"]),
    )

    ctx.actions.run_shell(
        inputs = [base_script, ctx.file.analysis_script],
        outputs = [full_script],
        command = "cat {base_script} {analysis_script} > {full_script}".format(
            base_script = base_script.path,
            analysis_script = ctx.file.analysis_script.path,
            full_script = full_script.path,
        ),
    )

    return assemble_openroad_step(
        ctx,
        ctx.attr.name,
        full_script,
        read_cells_runfiles,
        inputs = ["netlist"] + ctx.attr.inputs,
        outputs = ctx.attr.outputs,
        constants = ["top"] + ctx.attr.outputs,
    )

analyze_netlist_step = rule(
    implementation = _analyze_netlist_step_impl,
    attrs = {
        "analysis_script": attr.label(
            doc = "OpenROAD Tcl script implementing the analysis",
            allow_single_file = [".tcl"],
            mandatory = True,
        ),
        "constants": attr.string_list(
            doc = "Logical names of string constants (beyond netlist top) required by this analysis step",
        ),
        "inputs": attr.string_list(
            doc = "Logical names of additional file inputs (beyond netlist) required by this analysis step",
        ),
        "outputs": attr.string_list(
            doc = "Logical names of file outputs generated by this analysis step",
        ),
        "standard_cells": attr.label(
            doc = "Standard cells to use for analysis",
            providers = [StandardCellInfo],
            mandatory = True,
        ),
        "_openroad": attr.label(
            default = Label("@org_theopenroadproject//:openroad"),
            executable = True,
            cfg = "exec",
        ),
    },
)

def analyze_rtl_binary(
        name,
        standard_cells,
        analysis_script,
        inputs = [],
        outputs = [],
        constants = [],
        yosys_script = "//flows/analysis:simple_synth.tcl"):
    """Build an RTL analysis binary out of a flow that includes Yosys synthesis and OpenROAD analysis.

    Args:
      name: Name for the generated analysis binary.
      standard_cells: StandardCellInfo provider for the cells used by Yosys and OpenROAD.
      analysis_script: Tcl script used for OpenROAD analysis.
      inputs: Names of logical inputs for the generated flow (beyond the rtl input for synthesis).
      outputs: Names of logical outputs for the generated flow.
      constants: Names of string constants required by the flow (beyond top).
      yosys_script: Tcl script used for Yosys synthesis, defaults to //flows/analysis:simple_synth.tcl
    """

    yosys_step = "_" + name + "_yosys_step"
    yosys_synth_file_step(
        name = yosys_step,
        standard_cells = standard_cells,
        synth_tcl = yosys_script,
        visibility = ["//visibility:private"],
    )

    analysis_step = "_" + name + "_analysis_step"
    analyze_netlist_step(
        name = analysis_step,
        inputs = ["netlist"] + inputs,
        outputs = outputs,
        constants = ["top"] + constants,
        analysis_script = analysis_script,
        standard_cells = standard_cells,
        visibility = ["//visibility:private"],
    )

    flow_binary(name = name, flow = [yosys_step, analysis_step])
