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
	@echo "Cleaning binary..."
	@rm -rf ./bin

##############################
###### Docker commands #######
##############################
.PHONY: docker-build
docker-build:
	@echo "Building docker image..."
	@docker build -t hello-world:v0.0.1 .

##############################
###### Helm commands #########
##############################
.PHONY: helm-lint
helm-lint:  ## Lint go modules
	@cd deploy && helm lint helloworld-chart

.PHONY: helm-package
helm-package:
	@cd deploy && helm dep update helloworld-chart && helm package helloworld-chart

##############################
###### Kind commands #########
##############################
.PHONY: kind-create-cluster
kind-create-cluster: kind-clean
	@kind create cluster --name kind-helloworld --config=./deploy/cluster.yml
	@kubectl cluster-info --context kind-kind-helloworld
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@sleep 60
	@kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

.PHONY: kind-clean
kind-clean:  ## Delete the kind-helloworld cluster and ingress-nginx namespace
	@kind delete cluster --name kind-helloworld > /dev/null 2>&1 || true
	@kubectl delete namespaces ingress-nginx > /dev/null 2>&1 || true

##############################
###### Deployment commands ###
##############################
.PHONY: deploy
deploy: kind-create-cluster helm-package
	@cd deploy && \
		helm install --namespace hello-kind hello-world ./deploy/helloworld-chart-0.0.1.tgz

##############################
###### Cleanup resources #####
##############################
.PHONY: clean
clean: go-clean kind-clean