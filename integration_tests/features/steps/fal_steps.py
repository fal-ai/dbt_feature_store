import json
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
def check_outputs(context, model):
    if model == "all models":
        for m in MODELS:
            _check_output(m)
    else:
        _check_output(model)


def _run_command(command: str):
    os.system(f"cd mock && {command} > temp/output")


def _check_output(model):
    expected = "expected unread"
    current = "current unread"
    try:
        print(f"Checking: {model}", flush=True)
        with open(f"mock/output_expected/{model}.json", "r") as f:
            expected = json.load(f)
        with open(f"mock/temp/{model}.json", "r") as f:
            current = json.load(f)

        assert expected == current
    except AssertionError as e:
        print(f"Error for {model}", flush=True)
        print(f"Expected:\n{expected}", flush=True)
        print(f"Got:\n{current}", flush=True)
        raise Exception("Did not get expected output") from e
