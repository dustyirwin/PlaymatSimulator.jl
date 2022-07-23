FROM julia

RUN apt-get update

RUN apt-get -y install git clang

COPY . .

RUN julia --project src/utils.jl

EXPOSE 1235

CMD julia --project -q -J"botm.so" -e 'import Pluto;Pluto.run(host="0.0.0.0", port=1235, require_secret_for_open_links=false, require_secret_for_access=false)'
