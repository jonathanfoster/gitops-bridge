SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

CLUSTER_NAME ?= gitops-bridge

.PHONY: all
all: debug

.PHONY: argo-bootstrap
argo-bootstrap:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

.PHONY: argo-password
argo-password:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

.PHONY: argo-server
argo-server:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: cluster-create
cluster-create:
	kind create cluster --name=${CLUSTER_NAME}

.PHONY: kind-create
cluster-delete:
	kind delete cluster --name=${CLUSTER_NAME}

.PHONY: helm-debug
helm-debug:
	helm template add-ons charts/add-ons --debug
	helm template monitoring charts/monitoring --debug

.PHONY: helm-lint
helm-lint:
	helm lint charts/add-ons
	helm lint charts/monitoring

.PHONY: deploy
deploy:
	kubectl apply -f clusters/local/add-ons.yaml
	kubectl apply -f clusters/local/monitoring.yaml

.PHONY: install-toolchain
install-toolchain:
	brew install argocd
	brew install helm

.PHONY: lint
lint: helm-lint
