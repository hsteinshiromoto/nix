{ config, pkgs, ... }:

{
  # SOPS secrets configuration for AWS
  sops = {
    secrets = {
      # Config profile secrets
      "config/test/account_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/qa02/account_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/dev02/account_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/sandbox/account_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/produk/account_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/sso_session_id" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "config/sso_start_url" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      # SSM tunnel secrets - produk
      "ssm/produk/uk/host" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "ssm/produk/uk/port" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
      "ssm/produk/uk/local_port" = {
        sopsFile = "${config.home.homeDirectory}/.config/sops/secrets/mbp2025/aws.yaml";
      };
    };

    # Generate templates to staging location
    templates."aws/config" = {
      content = ''
[profile test]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/test/account_id"}
sso_role_name = tech-lead-power-user
region = ap-southeast-2

[profile qa02]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/qa02/account_id"}
sso_role_name = tech-lead-power-user
region = ap-southeast-2

[profile dev02]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/dev02/account_id"}
sso_role_name = tech-lead-power-user
region = ap-southeast-2

[profile sandbox]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/sandbox/account_id"}
sso_role_name = tech-lead-admin
region = ap-southeast-2

[profile produk]
sso_session = ${config.sops.placeholder."config/sso_session_id"}
sso_account_id = ${config.sops.placeholder."config/produk/account_id"}
sso_role_name = tech-lead-admin
region = eu-west-2

[sso-session ${config.sops.placeholder."config/sso_session_id"}]
sso_start_url = ${config.sops.placeholder."config/sso_start_url"}
sso_region = ap-southeast-2
sso_registration_scopes = sso:account:access

[default]
region = ap-southeast-2
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

  # Conditionally copy AWS config files only if they don't exist
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
