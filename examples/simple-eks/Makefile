#ifeq ($(NO_DOCKER), true)
ifneq ($(DOCKER), true)
	RUNTIME = terraform
else 
	RUNTIME = docker run -it -v $$(cd ../ && pwd):$$(cd ../ && pwd) -v ~/.ssh:/root/.ssh -w $$PWD -v ~/.aws:/root/.aws hashicorp/terraform:1.3.4
endif
REGION ?= us-east-1
PROFILE ?= rocky
NAME ?= simple-eks
BUCKET ?= rocky-terraform-examples
PATCH = $(shell cat ./aws-node-patch.yaml)

.PHONY: clean
clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl

.PHONY: init
init:
	$(RUNTIME) init -var aws_region="${REGION}" -var aws_profile="${PROFILE}" -var name="${NAME}" -backend-config="bucket=${BUCKET}" -backend-config="key=${NAME}.tfstate" -backend-config="region=${REGION}" -backend-config="profile=${PROFILE}"

.PHONY: deploy
step1: init
	$(RUNTIME) apply -var aws_region="${REGION}" -var aws_profile="${PROFILE}" -var name="${NAME}" -var-file=./deployment/deploy.tfvars
	aws eks --profile ${PROFILE} --region ${REGION} update-kubeconfig --name ${NAME} --kubeconfig ${NAME}.kubeconfig

.PHONY: destroy
destroy: init
	$(RUNTIME) destroy -var aws_region="${REGION}" -var aws_profile="${PROFILE}" -var name="${NAME}" -var-file=./deployment/step1.tfvars
