#include "LoggerC.h"
#include <orbsvcs/CosNamingC.h>
#include <iostream>
#include <ctime>
#include <unistd.h>

const char *nomes[] = { "DEBUG", "WARNING", "ERROR", "CRITICAL" };

void testa_locate(Logger_ptr logger, Severidade s)
{
  try {
    auto r = logger->locate (s);
    std::cout << "locate(" << nomes[s] << "): " << r << std::endl;
  }
  catch (const EventoNaoRecebido &)
  {
    std::cout << "locate(" << nomes[s] << "): nenhum evento recebido ainda" << std::endl;
  }
}

int main (int argc, char *argv[])
{
  try
    {
      CORBA::ORB_var orb = CORBA::ORB_init (argc, argv);

      // Endereco ficticio do cliente, pode vir por args no cmd
      std::string endereco = argc > 1 ? argv[1] : "192.168.1.1:1500";
      
      // Busca a referencia do Logger no servidor de nomes
      CORBA::Object_var ns_obj = orb->resolve_initial_references ("NameService");
      CosNaming::NamingContext_var ns = CosNaming::NamingContext::_narrow (ns_obj.in ());

      CosNaming::Name nome (1);
      nome.length(1);
      nome[0].id = CORBA::string_dup ("Logger");

      CORBA::Object_var obj = ns->resolve (nome);
      Logger_var logger = Logger::_narrow (obj.in ());

      //antes de enviar eventos
      for (int s = DEBUG; s <= CRITICAL; s++) {
        testa_locate(logger.in (), (Severidade) s);
      }

      logger->log (DEBUG, endereco, getpid (), time (NULL), "conexao aberta");
      logger->log (WARNING, endereco, getpid (), time (NULL), "uso de memoria alto");
      logger->log (ERROR, endereco, getpid (), time (NULL), "falha ao abrir arquivo");
      logger->log (CRITICAL, endereco, getpid (), time (NULL), "disco cheio");

      // log e oneway, entao esperamos um instante antes de consultar
      sleep (1);

      // depois de enviar todos devem apontar para este cliente:
      for (int s = DEBUG; s <= CRITICAL; s++) {
        testa_locate(logger.in (), (Severidade) s);
      }

      orb->destroy ();
    }
  catch (const CORBA::Exception &e)
    {
      e._tao_print_exception ("Erro no cliente");
      return 1;
    }
  return 0;
}
