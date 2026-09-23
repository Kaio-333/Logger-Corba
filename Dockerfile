# Ambiente ACE/TAO para o trabalho Logger CORBA.
# Mesma versão que gerou os stubs originais (TAO IDL Compiler v4.0.4 = ACE+TAO 8.0.4).
FROM ubuntu:24.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential perl make wget ca-certificates procps \
 && rm -rf /var/lib/apt/lists/*

ENV ACE_ROOT=/opt/ACE_wrappers
ENV TAO_ROOT=$ACE_ROOT/TAO
ENV LD_LIBRARY_PATH=$ACE_ROOT/lib
ENV PATH=$ACE_ROOT/bin:$TAO_ROOT/orbsvcs/Naming_Service:$PATH

WORKDIR /opt
RUN wget -q "https://github.com/DOCGroup/ACE_TAO/releases/download/ACE%2BTAO-8_0_4/ACE%2BTAO-8.0.4.tar.gz" -O acetao.tgz \
 && tar xzf acetao.tgz && rm acetao.tgz \
 && echo '#include "ace/config-linux.h"' > $ACE_ROOT/ace/config.h \
 && printf 'debug=0\ninclude $(ACE_ROOT)/include/makeinclude/platform_linux.GNU\n' \
      > $ACE_ROOT/include/makeinclude/platform_macros.GNU

# Só o necessário: ACE, gperf (usado pelo tao_idl), TAO + Naming Service.
RUN make -j"$(nproc)" -C $ACE_ROOT/ace \
 && make -j"$(nproc)" -C $ACE_ROOT/apps/gperf/src \
 && make -j"$(nproc)" -C $TAO_ROOT Naming_Service \
 && tao_idl -V 2>&1 | head -3 \
 && ls $TAO_ROOT/orbsvcs/Naming_Service/tao_cosnaming

WORKDIR /work
CMD ["sleep", "infinity"]
