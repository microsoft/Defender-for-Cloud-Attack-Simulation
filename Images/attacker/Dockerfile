FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
RUN tdnf -y update && tdnf -y install python3 curl && tdnf clean all
COPY src/ /simulation
WORKDIR /simulation
RUN cp /bin/true xmrig
RUN chmod +x attack.sh
ENV SCENARIO=all
CMD ["./attack.sh"]
