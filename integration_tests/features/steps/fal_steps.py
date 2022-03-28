import os
from behave import *

MODELS = [
    "zendesk_ticket_data",
    "zendesk_sentiment",
    "latest_ticket_data",
    "ticket_sentiment_dataset",
]


@given("`{command}` is run")
def run_command_step(context, command):
    _run_command(command)


@when("`{command}` is run")
def run_command_step2(context, command):
    _run_command(command)


@then("outputs for {model} contain results")
def check_outputs(context, model, run_type):
    test_results = run_type == "test"
    if model == "all models":
        for m in MODELS:
            _check_output(m, test_results)
    else:
        _check_output(model, test_results)


def _run_command(command: str):
    os.system(f"cd mock && {command} > temp/output")


def _check_output(model, is_test=False):
    try:
        print(f"Checking: {model}", flush=True)
        if is_test:
            expected = open(f"mock/fal_output/{model}_expected_test", "r").read()
            current = open(f"mock/temp/{model}_test", "r").read()
        else:
            expected = open(f"mock/fal_output/{model}_expected", "r").read()
            current = open(f"mock/temp/{model}", "r").read()
        assert expected == current
    except AssertionError:
        print(f"Error for {model}:", flush=True)
        print(f"Expected: {expected}", flush=True)
        print(f"Got: {current}", flush=True)
        raise Exception("Did not get expected output")
