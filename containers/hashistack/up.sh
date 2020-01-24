set -e

mkdir -p logs
consul agent -dev > logs/consul &!
nomad agent -dev > logs/nomad &!
vault server -dev > logs/vault &!
