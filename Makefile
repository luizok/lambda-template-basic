IMAGE_NAME=python:3.12-alpine
TF_CMD=terraform -chdir=infra/

build_layer:
	rm -rf output/layer.zip
	mkdir -p python
	docker run \
		-v "$(PWD)/python:/venv" \
		-v "$(PWD)/app/requirements.txt:/requirements.txt" \
		$(IMAGE_NAME) \
		pip install -r /requirements.txt -t /venv
	zip -r output/layer.zip python
	rm -rf python

build_app:
	rm -rf output/app.zip
	cd app && zip -r ../output/app.zip .

deploy:
	$(TF_CMD) validate
	$(TF_CMD) plan
	$(TF_CMD) apply
