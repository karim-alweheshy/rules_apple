# Copyright 2026 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Tests for restricting application executable exports."""

load(
    "//test/starlark_tests/rules:action_command_line_test.bzl",
    "action_command_line_test",
    "make_action_command_line_test_rule",
)

_restrict_application_exports_action_command_line_test = make_action_command_line_test_rule({
    "//command_line_option:features": [
        "apple.restrict_application_exports",
    ],
})

_disable_restrict_application_exports_action_command_line_test = make_action_command_line_test_rule({
    "//command_line_option:features": [
        "apple.restrict_application_exports",
        "-apple.restrict_application_exports",
    ],
})

def application_exports_test_suite(name):
    """Test suite for the apple.restrict_application_exports feature.

    Args:
      name: The base name to use for tests created by this macro.
    """
    action_command_line_test(
        name = "{}_disabled_by_default_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_minimal",
        mnemonic = "ObjcLink",
        not_expected_argv = ["__mh_execute_header"],
        tags = [name],
    )

    _restrict_application_exports_action_command_line_test(
        name = "{}_application_linker_flag_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_minimal",
        mnemonic = "ObjcLink",
        expected_argv = [
            "-exported_symbol",
            "__mh_execute_header",
        ],
        tags = [name],
    )

    _disable_restrict_application_exports_action_command_line_test(
        name = "{}_explicitly_disabled_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_minimal",
        mnemonic = "ObjcLink",
        not_expected_argv = ["__mh_execute_header"],
        tags = [name],
    )

    _restrict_application_exports_action_command_line_test(
        name = "{}_custom_exports_are_additive_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_minimal_with_exported_symbols",
        mnemonic = "ObjcLink",
        expected_argv = [
            "-exported_symbol",
            "__mh_execute_header",
            "-exported_symbols_list",
            "ExportAnotherFunctionMain.exp",
        ],
        tags = [name],
    )

    _restrict_application_exports_action_command_line_test(
        name = "{}_extension_linker_flag_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:ext",
        mnemonic = "ObjcLink",
        expected_argv = [
            "-exported_symbol",
            "__mh_execute_header",
        ],
        tags = [name],
    )

    # A global feature must not change products that provide APIs to other binaries.
    _restrict_application_exports_action_command_line_test(
        name = "{}_framework_unchanged_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/ios:fmwk",
        mnemonic = "ObjcLink",
        not_expected_argv = ["__mh_execute_header"],
        tags = [name],
    )

    native.test_suite(
        name = name,
        tags = [name],
    )
