#!/bin/sh
# Category 1b: render SMTP2Graph runtime configuration from Docker Secret files.
# This is a Task 2.3 qualification prototype, not a production deployment entrypoint.
set -eu

runtime_dir="${RUNTIME_CONFIG_DIR:-/runtime}"
secrets_dir="${DOCKER_SECRETS_DIR:-/run/secrets}"
auth_mode="${GRAPH_AUTH_MODE:-certificate}"
render_mode="${RUNTIME_ENTRYPOINT_MODE:-run}"

require_file() {
  if [ ! -r "$1" ]; then
    printf 'ERROR: required Docker Secret file is unavailable.\n' >&2
    exit 66
  fi
}

read_secret_line() {
  require_file "$1"
  tr -d '\r\n' <"$1"
}

yaml_quote() {
  printf "'"
  printf '%s' "$1" | sed "s/'/''/g"
  printf "'"
}

required_value() {
  value="$1"
  if [ -z "$value" ]; then
    printf 'ERROR: required non-secret runtime value is empty.\n' >&2
    exit 64
  fi
  yaml_quote "$value"
}

mkdir -p "$runtime_dir"
chmod 700 "$runtime_dir"
umask 077

tenant_id="$(read_secret_line "$secrets_dir/graph-tenant-id")"
client_id="$(read_secret_line "$secrets_dir/graph-client-id")"
smtp_tls_key_path="${SMTP_TLS_KEY_PATH:-$secrets_dir/smtp-tls-key}"
smtp_tls_cert_path="${SMTP_TLS_CERT_PATH:-$secrets_dir/smtp-tls-cert}"
require_file "$smtp_tls_key_path"
require_file "$smtp_tls_cert_path"

config_file="$runtime_dir/config.yml"
{
  printf '%s\n' 'mode: full'
  printf '%s\n' 'send:'
  printf '%s\n' '  appReg:'
  printf '    tenant: %s\n' "$(required_value "$tenant_id")"
  printf '    id: %s\n' "$(required_value "$client_id")"

  case "$auth_mode" in
    certificate)
      certificate_thumbprint="$(read_secret_line "$secrets_dir/graph-certificate-thumbprint")"
      graph_private_key_path="${GRAPH_PRIVATE_KEY_PATH:-$secrets_dir/graph-private-key}"
      require_file "$graph_private_key_path"
      printf '%s\n' '    certificate:'
      printf '      thumbprint: %s\n' "$(required_value "$certificate_thumbprint")"
      printf '      privateKeyPath: %s\n' "$(required_value "$graph_private_key_path")"
      ;;
    client-secret)
      graph_client_secret="$(read_secret_line "$secrets_dir/graph-client-secret")"
      printf '    secret: %s\n' "$(required_value "$graph_client_secret")"
      ;;
    *)
      printf 'ERROR: unsupported GRAPH_AUTH_MODE.\n' >&2
      exit 64
      ;;
  esac

  printf '%s\n' '  retryLimit: 1'
  printf '%s\n' '  retryInterval: 1'
  printf '%s\n' 'receive:'
  printf '%s\n' '  port: 587'
  printf '  listenAddress: %s\n' "$(required_value "${SMTP_LISTEN_ADDRESS:-127.0.0.1}")"
  printf '%s\n' '  secure: true'
  printf '  tlsKeyPath: %s\n' "$(required_value "$smtp_tls_key_path")"
  printf '  tlsCertPath: %s\n' "$(required_value "$smtp_tls_cert_path")"
  printf '%s\n' '  maxSize: 25m'
  printf '%s\n' '  requireAuth: false'
} >"$config_file"

chmod 600 "$config_file"

if [ "$render_mode" = 'render-only' ]; then
  case "$auth_mode" in
    certificate)
      grep -F -- "$graph_private_key_path" "$config_file" >/dev/null
      ;;
    client-secret)
      grep -F -- "$graph_client_secret" "$config_file" >/dev/null
      unset graph_client_secret
      ;;
  esac
  printf 'PASS: runtime configuration rendered in the configured runtime directory.\n'
  exit 0
fi

if [ "$render_mode" != 'run' ]; then
  printf 'ERROR: unsupported RUNTIME_ENTRYPOINT_MODE.\n' >&2
  exit 64
fi

cd "$runtime_dir"
exec /bin/sh /bin/startup.sh
