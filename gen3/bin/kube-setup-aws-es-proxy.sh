#!/bin/bash
#
# Deploy aws-es-proxy into existing commons
# https://github.com/abutaha/aws-es-proxy
# 


source "${GEN3_HOME}/gen3/lib/utils.sh"
gen3_load "gen3/lib/kube-setup-init"

[[ -z "$GEN3_ROLL_ALL" ]] && gen3 kube-setup-secrets

if g3kubectl get secrets/aws-es-proxy > /dev/null 2>&1; then
  envname="$(gen3 api environment)"
  gen3_log_info "envname: $envname"
  if ES_ENDPOINT="$(aws es describe-elasticsearch-domains --domain-names ${envname}-gen3-metadata --query "DomainStatusList[*].Endpoints" --output text)" \
      && [[ -n "${ES_ENDPOINT}" && -n "${envname}" ]]; then
    gen3_log_info "ES_ENDPOINT is $ES_ENDPOINT"
    gen3 roll aws-es-proxy GEN3_ES_ENDPOINT "${ES_ENDPOINT}"
    gen3_log_info "did aws-ex-proxy"
    g3kubectl apply -f "${GEN3_HOME}/kube/services/aws-es-proxy/aws-es-proxy-service.yaml"
    gen3_log_info "kube-setup-aws-es-proxy" "The aws-es-proxy service has been deployed onto the k8s cluster."
  else
    #
    # probably running in jenkins or job environment
    # try to make sure network policy labels are up to date
    #
    gen3_log_info "kube-setup-aws-es-proxy" "Not deploying aws-es-proxy, no endpoint to hook it up."
    gen3 kube-setup-networkpolicy service aws-es-proxy
    g3kubectl patch deployment "aws-es-proxy-deployment" -p  '{"spec":{"template":{"metadata":{"labels":{"netvpc":"yes"}}}}}' || true
  fi
  gen3 job cron es-garbage '@daily'
else
  gen3_log_info "kube-setup-aws-es-proxy"  "Not deploying aws-es-proxy - secret is not configured"
  exit 1
fi
