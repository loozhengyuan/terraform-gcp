init:
	chmod -R +x .githooks
	git config core.hooksPath .githooks

TERRAFORM_VERSION = 0.12.23
install:
	wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -O terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	sudo mv terraform /usr/local/bin
	rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
	terraform version

fmt:
	terraform fmt -recursive -diff

lint:
	terraform fmt -check -recursive -diff

validate:
	terraform validate
