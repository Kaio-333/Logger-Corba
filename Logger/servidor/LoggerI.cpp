#include "LoggerI.h"
#include <iostream>
#include <ctime>

Logger_i::Logger_i ()
{
}

Logger_i::~Logger_i ()
{
}

void Logger_i::log (
  ::Severidade s,
  const std::string endereco,
  ::CORBA::UShort pid,
  ::CORBA::ULongLong hora,
  const std::string msg)
{

  const char *nomes[] = { "DEBUG", "WARNING", "ERROR", "CRITICAL" };

  time_t t = hora;
  char data[20];
  strftime (data, sizeof data, "%d/%m/%Y %H:%M:%S", localtime (&t));

  std::cout << "[log] " << nomes[s]
            << " | endereco: " << endereco
            << " | pid: " << pid
            << " | hora: " << data << " (" << hora << ")"
            << " | msg: " << msg << std::endl;

  ultimo_endereco[s] = endereco;
}

std::string Logger_i::locate (
  ::Severidade s)
{
  auto posicao = ultimo_endereco.find(s);
  if (posicao == ultimo_endereco.end())
  {
    throw EventoNaoRecebido();
  }
  return posicao->second;
}
