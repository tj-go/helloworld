# Self-Documented Makefile see https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

.PHONY: help
# Put it first so that "make" without argument is like "make help".
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-32s-\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##############################
###### GoLang commands #######
##############################
.PHONY: go-format
go-format:  ## Format go modules
	@go fmt ./...

.PHONY: go-tidy
go-tidy:  ## Tidy go.mod
	@go mod tidy

.PHONY: go-build
go-build: go-clean  ## Compile go modules
	@echo "Compiling go modules..."
	@go build -o ./bin/helloworld .

.PHONY: go-run
go-run: go-build  ## Execute binary
	@echo "Executing binary..."
	@./bin/helloworld

.PHONY: go-clean
go-clean:  ## Clean binary file
	@echo "Cleaning ./bin..."
	@rm -rf ./bin

##############################
###### Docker commands #######
##############################
.PHONY: docker-build
docker-build:  ## Build docker image
	@echo "Building docker image..."
	@docker build -t hello-world:v0.0.1 .

##############################
###### Helm commands #########
##############################
.PHONY: helm-lint
helm-lint:  ## Lint go modules
	@echo "Linting \"deploy/helloworld-chart...\""
	@helm lint deploy/helloworld-chart

.PHONY: helm-package
helm-package: helm-clean  ## Package helm chart
	@echo "Packaging \"deploy/helloworld-chart...\""
	@helm dep update deploy/helloworld-chart && helm package deploy/helloworld-chart -d deploy/build/

.PHONY: helm-clean
helm-clean:  ## Clean helm package artifacts
	@echo "Cleaning \"deploy/build\"..."
	@rm -rf deploy/build

################################
## Install Helm chart archive ##
################################
.PHONY: helm-install
helm-install: kind-create-cluster helm-package  ## Create the cluster, package helm charts and install the build
	@echo "Installing \"./deploy/build/helloworld-chart-0.0.1.tgz\"..."
	@sleep 60
	@helm install --create-namespace --namespace hello-kind hello-world ./deploy/build/helloworld-chart-0.0.1.tgz

.PHONY: helm-upgrade
helm-upgrade: helm-package
	@helm upgrade --namespace hello-kind hello-world ./deploy/build/helloworld-chart-0.0.1.tgz

##############################
###### Kind commands #########
##############################
.PHONY: kind-create-cluster
kind-create-cluster: kind-clean  ## Create k8's cluster using kind and a custom "./deploy/cluster.yml"
	@echo "Creating k8's cluster using kind and a custom \"./deploy/cluster.yml...\""
	@kind create cluster --name kind-helloworld --config=./deploy/cluster.yml
	@kubectl cluster-info --context kind-kind-helloworld
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@sleep 60
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

.PHONY: kind-clean
kind-clean:  ## Delete the "kind-helloworld" cluster and "ingress-nginx" namespace
	@echo "Deleting the \"kind-helloworld\" cluster and \"ingress-nginx\" namespace..."
	@kind delete cluster --name kind-helloworld > /dev/null 2>&1 || true
	@kubectl delete namespaces ingress-nginx > /dev/null 2>&1 || true

###############################
# Cleanup resources/artifacts #
###############################
.PHONY: clean  ## Clean all artifacts
clean: go-clean kind-clean helm-clean