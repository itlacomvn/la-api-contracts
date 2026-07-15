GOBIN := $(shell go env GOPATH)/bin
export PATH := $(GOBIN):$(PATH)

# Mỗi ngôn ngữ là một module/package độc lập dưới gen/<lang>/
GO_DIR := gen/go

.PHONY: gen proto tidy build lint breaking clean

gen: proto tidy ## Gen code cho tất cả ngôn ngữ + sync deps

proto: ## Chạy buf generate (đọc buf.gen.yaml)
	buf generate

tidy: ## Sync go.mod của module Go đã gen
	cd $(GO_DIR) && go mod tidy

build: ## Compile thử code Go đã gen
	cd $(GO_DIR) && go build ./...

lint: ## Lint proto
	buf lint

breaking: ## Kiểm tra breaking change so với main
	buf breaking --against '.git#branch=main'

clean: ## Xoá code gen, giữ lại go.mod/go.sum của từng ngôn ngữ
	find $(GO_DIR) -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
