FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
RUN tdnf -y update && tdnf -y install python3-3.9.19 curl-8.8.0 && tdnf clean all
COPY src/ /simulation
WORKDIR /simulation
RUN cp /bin/true xmrig
RUN chmod +x attack.sh
ENV SCENARIO=all
COPY /NOTICE /NOTICE
CMD ["./attack.sh"]
