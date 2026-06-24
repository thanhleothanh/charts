ENV ?= self-hosted
NS ?= dev
NAMESPACE_CHART = charts/namespace
CLUSTER_CHART = charts/cluster

.PHONY: lint cluster-deploy namespace-deploy deploy-all dry-run-cluster dry-run-namespace teardown-cluster teardown-namespace teardown-all clean

# --- Cluster infrastructure ---

lint-cluster:
	helm lint $(CLUSTER_CHART)
	helm lint $(CLUSTER_CHART) -f environments/$(ENV)/cluster-values.yaml

dry-run-cluster:
	helm upgrade personal-cluster $(CLUSTER_CHART) \
		-f environments/$(ENV)/cluster-values.yaml \
		--dry-run --debug

cluster-deploy:
	@echo "Deploying cluster infra to $(ENV)..."
	helm dependency build $(CLUSTER_CHART) 2>/dev/null || true
	helm upgrade --install personal-cluster $(CLUSTER_CHART) \
		-f environments/$(ENV)/cluster-values.yaml \
		--wait --timeout 5m

teardown-cluster:
	helm uninstall personal-cluster || true

# --- Namespace apps ---

lint-namespace:
	helm lint $(NAMESPACE_CHART)
	helm lint $(NAMESPACE_CHART) -f environments/$(ENV)/$(NS)/values.yaml

dry-run-namespace:
	helm upgrade $(NS)-apps $(NAMESPACE_CHART) \
		-n $(NS) \
		-f environments/$(ENV)/$(NS)/values.yaml \
		--dry-run --debug

namespace-deploy:
	@echo "Deploying namespace $(NS) to $(ENV)..."
	@kubectl create namespace $(NS) --dry-run=client -o yaml | kubectl apply -f -
	helm upgrade --install $(NS)-apps $(NAMESPACE_CHART) \
		-n $(NS) \
		-f environments/$(ENV)/$(NS)/values.yaml \
		--wait --timeout 5m

teardown-namespace:
	helm uninstall $(NS)-apps -n $(NS) || true

# --- All-in-one ---

deploy-all: cluster-deploy namespace-deploy

teardown-all: teardown-namespace teardown-cluster

# --- Utilities ---

lint: lint-cluster lint-namespace

clean:
	helm uninstall personal-cluster 2>/dev/null || true
	helm uninstall dev-apps -n dev 2>/dev/null || true
	helm uninstall staging-apps -n staging 2>/dev/null || true
