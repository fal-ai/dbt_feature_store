import os


def before_all(context):
    os.system("mkdir mock/temp")
    os.system("cd mock && dbt seed --profiles-dir .")


def after_all(context):
    os.system("rm -rf mock/temp")
    if hasattr(context, "temp_dir"):
        context.temp_dir.cleanup()


def after_scenario(context, scenario):
    os.system("rm -rf mock/temp/*")
