set -e

mkdir -p logs
consul agent -dev > logs/consul &!
nomad agent -dev > logs/nomad &!
vault server -dev > logs/vault &!

# Export it now and add it to zshrc for later (in case of terminal exit)
export VAULT_ADDR="http://127.0.0.1:8200"
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.zshrc
