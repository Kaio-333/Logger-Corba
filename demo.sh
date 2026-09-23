#!/bin/bash
# Sobe Servidor de Nomes + servidor Logger + dois clientes e confere a saida.
# Servidor e clientes rodam em pastas separadas, como se fossem maquinas
# diferentes: a unica coisa que eles compartilham e o Servidor de Nomes.
# Uso (dentro do conteiner): ./demo.sh

cd "$(dirname "$0")/Logger" || exit 1
make -s -C servidor >/dev/null && make -s -C cliente >/dev/null || exit 1

BIN=$PWD/bin
NS=corbaloc:iiop:localhost:2809/NameService
TMP=$(mktemp -d)
mkdir "$TMP/srv" "$TMP/cli1" "$TMP/cli2"

tao_cosnaming -ORBEndpoint iiop://localhost:2809 > "$TMP/ns.out" 2>&1 &
NS_PID=$!
trap 'kill $SRV_PID $NS_PID 2>/dev/null' EXIT
sleep 1

(cd "$TMP/srv" && exec "$BIN/servidor" -ORBInitRef NameService=$NS) > "$TMP/srv.out" 2>&1 &
SRV_PID=$!
sleep 1

(cd "$TMP/cli1" && "$BIN/cliente" -ORBInitRef NameService=$NS 192.168.1.1:1500) > "$TMP/cli1.out" 2>&1
CLI1_EXIT=$?
(cd "$TMP/cli2" && "$BIN/cliente" -ORBInitRef NameService=$NS 192.168.1.2:1600) > "$TMP/cli2.out" 2>&1
CLI2_EXIT=$?
sleep 0.5

echo "===== cliente 1 (192.168.1.1:1500) ====="; cat "$TMP/cli1.out"
echo "===== cliente 2 (192.168.1.2:1600) ====="; cat "$TMP/cli2.out"
echo "===== servidor ===="; cat "$TMP/srv.out"
echo "===== checagens ==="

FALHAS=0
check () {
  if eval "$2"; then echo "  ok    $1"; else echo "  FALHA $1"; FALHAS=$((FALHAS+1)); fi
}
conta () { grep -c "$1" "$2"; }

check "clientes terminaram sem erro" '[ $CLI1_EXIT -eq 0 ] && [ $CLI2_EXIT -eq 0 ]'
check "clientes acharam o Logger pelo Servidor de Nomes" \
  'grep -q "locate(" "$TMP/cli1.out" && ! grep -q "Erro no cliente" "$TMP/cli1.out" "$TMP/cli2.out"'
check "nenhum logger.ior em arquivo" '[ -z "$(find "$TMP" -name logger.ior)" ]'
check "cliente 1: locate lanca excecao nas 4 severidades antes de qualquer evento" \
  '[ "$(conta "nenhum evento" "$TMP/cli1.out")" -eq 4 ]'
for SEV in DEBUG WARNING ERROR CRITICAL; do
  check "cliente 1: log($SEV) e depois locate($SEV) = 192.168.1.1:1500" \
    'grep -q "locate($SEV): 192.168.1.1:1500" "$TMP/cli1.out"'
  check "cliente 2: locate($SEV) = ultimo endereco (192.168.1.2:1600)" \
    'grep -q "locate($SEV): 192.168.1.2:1600" "$TMP/cli2.out"'
done
check "servidor mostra a severidade pelo nome" 'grep -qE "\[log\] (sev: )?CRITICAL" "$TMP/srv.out" && ! grep -q "sev: [0-9]" "$TMP/srv.out"'
check "servidor mostra a hora legivel" 'grep -qE "[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}" "$TMP/srv.out"'
check "servidor imprimiu os 8 eventos recebidos" '[ "$(conta "\[log\]" "$TMP/srv.out")" -eq 8 ]'

echo
[ $FALHAS -eq 0 ] && echo "TUDO OK" || echo "$FALHAS FALHA(S)"
exit $FALHAS
