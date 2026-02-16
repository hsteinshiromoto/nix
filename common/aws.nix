{ config, pkgs, ... }:

let
  awsSopsFile = "${config.home.homeDirectory}/.config/sops/secrets/common/aws.yaml";
in
{
  sops = {
    secrets = {
      # SSO session config
      "config/sso_session_id".sopsFile = awsSopsFile;
      "config/sso_start_url".sopsFile = awsSopsFile;
      "config/sso_region".sopsFile = awsSopsFile;
      "config/sso_registration_scopes".sopsFile = awsSopsFile;
      "config/default_region".sopsFile = awsSopsFile;
      # Profile secrets
      "config/test/account_id".sopsFile = awsSopsFile;
      "config/test/role_name".sopsFile = awsSopsFile;
      "config/test/region".sopsFile = awsSopsFile;
      "config/qa02/account_id".sopsFile = awsSopsFile;
      "config/qa02/role_name".sopsFile = awsSopsFile;
      "config/qa02/region".sopsFile = awsSopsFile;
      "config/dev02/account_id".sopsFile = awsSopsFile;
      "config/dev02/role_name".sopsFile = awsSopsFile;
      "config/dev02/region".sopsFile = awsSopsFile;
      "config/sandbox/account_id".sopsFile = awsSopsFile;
      "config/sandbox/role_name".sopsFile = awsSopsFile;
      "config/sandbox/region".sopsFile = awsSopsFile;
      "config/produk/account_id".sopsFile = awsSopsFile;
      "config/produk/role_name".sopsFile = awsSopsFile;
      "config/produk/region".sopsFile = awsSopsFile;
      # SSM tunnel secrets
      "ssm/produk/uk/host".sopsFile = awsSopsFile;
      "ssm/produk/uk/port".sopsFile = awsSopsFile;
      "ssm/produk/uk/local_port".sopsFile = awsSopsFile;
    };

    templates."aws/config" = {
      content = ''
[profile test]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/test/account_id"}
sso_role_name = ${config.sops.placeholder."config/test/role_name"}
region = ${config.sops.placeholder."config/test/region"}

[profile qa02]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/qa02/account_id"}
sso_role_name = ${config.sops.placeholder."config/qa02/role_name"}
region = ${config.sops.placeholder."config/qa02/region"}

[profile dev02]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/dev02/account_id"}
sso_role_name = ${config.sops.placeholder."config/dev02/role_name"}
region = ${config.sops.placeholder."config/dev02/region"}

[profile sandbox]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/sandbox/account_id"}
sso_role_name = ${config.sops.placeholder."config/sandbox/role_name"}
region = ${config.sops.placeholder."config/sandbox/region"}

[profile produk]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/produk/account_id"}
sso_role_name = ${config.sops.placeholder."config/produk/role_name"}
region = ${config.sops.placeholder."config/produk/region"}

[sso-session ${config.sops.placeholder."config/sso_session_id"}]
sso_start_url = ${config.sops.placeholder."config/sso_start_url"}
sso_region = ${config.sops.placeholder."config/sso_region"}
sso_registration_scopes = ${config.sops.placeholder."config/sso_registration_scopes"}

[default]
region = ${config.sops.placeholder."config/default_region"}
'';
      path = "${config.home.homeDirectory}/.config/sops/templates/aws/config";
      mode = "0600";
    };

    templates."aws/ssm-tunnel-params-ukprod.json" = {
      content = ''
{
  "host": ["${config.sops.placeholder."ssm/produk/uk/host"}"],
  "portNumber": ["${config.sops.placeholder."ssm/produk/uk/port"}"],
  "localPortNumber": ["${config.sops.placeholder."ssm/produk/uk/local_port"}"]
}
'';
      path = "${config.home.homeDirectory}/.config/sops/templates/aws/ssm-tunnel-params-ukprod.json";
      mode = "0600";
    };
  };

  home.activation.copyAwsConfig = config.lib.dag.entryAfter ["sops-nix"] ''
    if [ ! -f "${config.home.homeDirectory}/.aws/config" ]; then
      $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.aws"
      $DRY_RUN_CMD cp "${config.home.homeDirectory}/.config/sops/templates/aws/config" "${config.home.homeDirectory}/.aws/config"
    fi
    if [ ! -f "${config.home.homeDirectory}/.aws/ssm-tunnel-params-ukprod.json" ]; then
      $DRY_RUN_CMD cp "${config.home.homeDirectory}/.config/sops/templates/aws/ssm-tunnel-params-ukprod.json" "${config.home.homeDirectory}/.aws/ssm-tunnel-params-ukprod.json"
    fi
  '';
}
