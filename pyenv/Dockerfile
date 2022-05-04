FROM ubuntu:focal
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y python3 python3-pip 
RUN pip3 install numpy pandas elasticsearch tabulate regex pytz pathlib flask statistics sklearn pymongo mplfinance mp flask_cors flask_table orjson ujson pyyaml ccxt cdk8s~=1.0.0.b53 jsii==1.36.0 constructs~=3.3.130 cdk8s-plus-17~=1.0.0.b57 argparse requests
RUN /usr/bin/python3 -m pip install pymongo[srv]
RUN mkdir pylibs
#ADD .pypirc /    # This is for pushing into the pypi server
ENV PYTHONPATH=/

ENTRYPOINT ["/usr/bin/python3"]

