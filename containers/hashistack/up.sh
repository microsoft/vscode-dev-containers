set -e

mkdir -p logs
consul agent -dev > logs/consul &
nomad agent -dev > logs/nomad &
vault server -dev > logs/vault &

export VAULT_ADDR='http://127.0.0.1:8200'
