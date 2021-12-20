FROM julia

RUN apt-get update

RUN apt-get -y install git clang

RUN mkdir -p /PSM

COPY . /PSM

WORKDIR /PSM

RUN julia --project src/utils.jl

EXPOSE 1235

CMD julia -q -J"botm.so" -e 'import Pluto;Pluto.run()'
