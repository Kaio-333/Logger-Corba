#include "LoggerI.h"
#include <iostream>
#include <orbsvcs/CosNamingC.h>

int main (int argc, char *argv[])
{
  try
    {
      CORBA::ORB_var orb = CORBA::ORB_init (argc, argv);

      CORBA::Object_var poa_obj = orb->resolve_initial_references ("RootPOA");
      PortableServer::POA_var poa = PortableServer::POA::_narrow (poa_obj.in ());
      PortableServer::POAManager_var mgr = poa->the_POAManager ();
      mgr->activate ();

      Logger_i *servant = new Logger_i;
      PortableServer::ServantBase_var dono = servant;
      Logger_var ref = servant->_this ();

      // Publica a referência no servidor de nomes
      CORBA::Object_var ns_obj = orb->resolve_initial_references ("NameService");
      CosNaming::NamingContext_var ns = CosNaming::NamingContext::_narrow (ns_obj.in ());

      CosNaming::Name nome (1);
      nome.length(1);
      nome[0].id = CORBA::string_dup ("Logger");
      ns->rebind (nome, ref.in ());

      std::cout << "Servidor no ar. Use Ctrl+C para encerrar." << std::endl;
      orb->run ();
    }
  catch (const CORBA::Exception &e)
    {
      e._tao_print_exception ("Erro no servidor");
      return 1;
    }
  return 0;
}
