# Docker-MSOffice2010-Python

docker with office2010 and python in wine

you can use windows python, and use the office com.

## Examples

```
FROM akkuman/msoffice2010-python:latest

...

ENTRYPOINT ["tini", "--", "xvfb-run", "-a", "wine", "python", "xxx.py"]
```
