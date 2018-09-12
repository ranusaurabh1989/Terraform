#!/bin/bash

echo "Downloading Istio ${istio_version}"

wget https://github.com/istio/istio/releases/download/${istio_version}/istio-${istio_version}-linux.tar.gz

sudo chown -R opc:opc /opt

mv istio-${istio_version}-linux.tar.gz /opt

cd /opt && tar zxvf istio-${istio_version}-linux.tar.gz

sudo ln -s /opt/istio-1.0.0/bin/istioctl /usr/local/bin/

cd /opt/istio-${istio_version}

echo "Creating CRDs"
# remove after helm 2.10.0 is released
kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

echo "Installing Istio with helm"
helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set ingress.enabled=${ingress_enabled} --set tracing.enabled=${tracing_enabled} --set grafana.enabled=${grafana_enabled} --set servicegraph.enabled=${servicegraph_enabled} --set gateways.istio-ingressgateway.enabled=${gateways_istio_ingressgateway_enabled} --set gateways.istio-egressgateway.enabled=${gateways_istio_egressgateway_enabled} --set galley.enabled=${galley_enabled} --set sidecarInjectorWebhook.enabled=${sidecarInjectorWebhook_enabled} --set mixer.enabled=${mixer_enabled} --set prometheus.enabled=${prometheus_enabled} --set global.proxy.envoyStatsd.enabled=${global_proxy_envoy_statsd_enabled}

if [ '${install_bookinfo_sample}' = 'true' ]; then 
  echo "Deploying bookinfo app"
  kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
  kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
fi

if [ '${efk_enabled}' = 'true' ]; then
  echo "Deploying logging stack"
  kubectl apply -f ~/logging-stack.yaml
  kubectl apply -f ~/fluentd-istio.yaml
fi

# wait until load balancer is ready and healthy 
http_code=0
until [ $http_code = '200' ]; do
  echo "sleeping for 10s"
  sleep 10
  export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
  export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
  export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
  let http_code=`curl --write-out '%{http_code}' --silent --output /dev/null http://$GATEWAY_URL/productpage`
done

# generate some traffic so Elasticsearch can create an index
echo productpage: http://$GATEWAY_URL/productpage

for i in 10; do
  curl --silent --output /dev/null http://$GATEWAY_URL/productpage
done