FROM julia

RUN mkdir -p /PSM

COPY . /

RUN julia -e ''