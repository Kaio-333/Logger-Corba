# Makefile do servidor Logger (ACE/TAO)
IDL      = ../idl/Logger.idl
EXE      = ../bin/servidor

CXX      = g++
CXXFLAGS = -std=c++17 -Wall -I. -I$(ACE_ROOT) -I$(TAO_ROOT) -I$(TAO_ROOT)/orbsvcs
LDLIBS   = -L$(ACE_ROOT)/lib -lTAO_CosNaming -lTAO_PortableServer \
           -lTAO_AnyTypeCode -lTAO -lACE

GERADOS  = LoggerC.h LoggerC.cpp LoggerC.inl LoggerS.h LoggerS.cpp
FONTES   = LoggerC.cpp LoggerS.cpp LoggerI.cpp server.cpp

$(EXE): $(FONTES) LoggerI.h
	mkdir -p ../bin
	$(CXX) $(CXXFLAGS) $(FONTES) $(LDLIBS) -o $@

$(GERADOS) &: $(IDL)
	tao_idl -Gstl $(IDL)

clean:
	rm -f $(GERADOS) $(EXE)

.PHONY: clean
