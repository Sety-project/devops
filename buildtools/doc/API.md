MyModules objects contains signature, argument validation, and testcases. But no defaults.
They are all registered upon import api_utils.

For each module_name in MyModules.current_module_list:

A) inside python
main(*args,**kwargs) is decorated with @api
@api validates arguments
@api creates a logger called module_name in /tmp/module_name/%Y%m%d_%H%M%S_info.log
log has at least:
 - "running [command line API]"
 - result
 - exceptions
 - and anything useful can be filled by lower level

B) command line
python3 module_name/main.py command argsvalue kwargskey=kwargsarg (args compulsory. kwargs optional depending on args value)

C) docker
1) pyrun_module_name mounts disks, passes default arguments and calls docker pull and then docker run
2) docker is defined in module_name/Dockerfile, which sets up environment and calls module_name/run.sh
3) run.sh calls module_name/main.py in command line format. Btw run.sh is generated by MyModules.register and needs to be committed if it changes.
some pyruns are in crontab

D) telegram
@Pronoia_Bot understands command line API