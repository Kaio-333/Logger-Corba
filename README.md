# Logger CORBA

Trabalho de Programação Distribuída (PUCPR): sistema cliente/servidor CORBA em
C++ (ACE/TAO) em que o servidor — o **Logger** — registra eventos enviados por
clientes espalhados na rede.

Grupo: Kaio Teles, Angelo Neto, Eduardo Mendes, Hugo Fagundes

## Estrutura

```
Logger/
├── idl/Logger.idl        interface (log e locate)
├── servidor/             LoggerI.h, LoggerI.cpp, server.cpp, Makefile
├── cliente/              client.cpp, Makefile
└── bin/                  executáveis (gerados pelo make)
demo.sh                   sobe tudo e confere a saída (testes)
Dockerfile                ambiente com ACE+TAO 8.0.4
```

## Pré-requisito

Só o [Docker](https://www.docker.com/). O ACE/TAO é compilado dentro da imagem.

## 1. Subir o ambiente

Na raiz do projeto (a primeira vez demora alguns minutos para compilar o ACE/TAO):

```bash
docker compose up -d --build
```

## 2. Compilar

```bash
docker compose exec corba bash -c "cd Logger/servidor && make && cd ../cliente && make"
```

O `make` roda o `tao_idl` (gera stub e skeleton a partir do `Logger.idl`) e
coloca os executáveis em `Logger/bin/`.

## 3. Rodar os testes

```bash
docker compose exec corba ./demo.sh
```

O script sobe o Servidor de Nomes, o servidor Logger e dois clientes com
endereços diferentes, e confere a saída. No fim deve aparecer `TUDO OK`.

## 4. Rodar na mão (cenário do enunciado)

Cada comando num terminal separado, nesta ordem:

```bash
# 1. Servidor de Nomes
docker compose exec corba tao_cosnaming -ORBEndpoint iiop://localhost:2809

# 2. Servidor Logger
docker compose exec -w /work/Logger/bin corba ./servidor -ORBInitRef NameService=corbaloc:iiop:localhost:2809/NameService

# 3. Clientes (o último argumento é o endereço "ip:porta" do cliente)
docker compose exec -w /work/Logger/bin corba ./cliente -ORBInitRef NameService=corbaloc:iiop:localhost:2809/NameService 192.168.1.1:1500
docker compose exec -w /work/Logger/bin corba ./cliente -ORBInitRef NameService=corbaloc:iiop:localhost:2809/NameService 192.168.1.2:1600
docker compose exec -w /work/Logger/bin corba ./cliente -ORBInitRef NameService=corbaloc:iiop:localhost:2809/NameService 192.168.1.3:1500
```

O servidor imprime cada evento recebido. Cada cliente chama `locate` nas quatro
severidades antes e depois de enviar os seus eventos: no primeiro cliente dá
exceção (nenhum evento ainda); nos seguintes aparece o endereço do cliente
anterior, que é o último evento recebido.

## Limpar

```bash
docker compose exec corba bash -c "cd Logger/servidor && make clean && cd ../cliente && make clean"
docker compose down
```
