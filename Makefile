run:
	docker compose run --build --rm app
setup:
	docker buildx create --driver docker-container --use --name multiplatform-builder
build:
	docker buildx build --platform linux/amd64,linux/arm64 -t devops-tools:latest .