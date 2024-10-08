FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
RUN tdnf -y update && tdnf -y install python3 curl gettext && tdnf clean all
COPY src/ /simulation
WORKDIR /simulation
RUN cp /bin/true xmrig
RUN chmod +x attack.sh
ENV SCENARIO=all
ENV NAME=mdc-simulator
CMD ["./attack.sh"]
