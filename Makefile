# Go parameters
GOCMD ?=	go
GOBUILD ?=	$(GOCMD) build
GOCLEAN ?=	$(GOCMD) clean
GOINSTALL ?=	$(GOCMD) install
GOTEST ?=	$(GOCMD) test
GOFMT ?=	gofmt -w

NAME = gsb
NAME_DOCKER_IMG	= goslackbot
SRC = src
C_FILES = $(shell find c_modules -name "*.c")
O_FILES = $(C_FILES:.c=.shared)
DIRNAME = $(shell basename $(shell pwd))
PACKAGES = go_modules

BUILD_LIST = $(foreach int, $(SRC), $(int)_build)
CLEAN_LIST = $(foreach int, $(SRC) $(PACKAGES), $(int)_clean)
INSTALL_LIST = $(foreach int, $(SRC), $(int)_install)
IREF_LIST = $(foreach int, $(SRC) $(PACKAGES), $(int)_iref)
TEST_LIST = $(foreach int, $(SRC) $(PACKAGES), $(int)_test)
FMT_LIST = $(foreach int, $(SRC) $(PACKAGES), $(int)_fmt)

.PHONY: $(CLEAN_LIST) $(TEST_LIST) $(FMT_LIST) $(INSTALL_LIST) $(BUILD_LIST) $(IREF_LIST)


all: build
#build: check_docker_image build_into_docker
#build_into_docker: $(BUILD_LIST)
build: $(O_FILES) $(BUILD_LIST)
clean: $(CLEAN_LIST)
install: $(INSTALL_LIST)
test: $(TEST_LIST)
iref: $(IREF_LIST)
fmt: $(FMT_LIST)


%.shared	: %.c
	gcc -W -Wall -Wextra -o $@ -shared -fPIC $<

check_docker_image :
	@docker ps | grep $(NAME_DOCKER_IMG) > /dev/null \
	|| ((docker rm -f goslackbot 2> /dev/null || true)\
		&& docker create -ti -v $(PWD):/go/src/$(DIRNAME) -w /go/src/$(DIRNAME) --name=$(NAME_DOCKER_IMG) golang:1.5 \
		&& docker start $(NAME_DOCKER_IMG))

$(BUILD_LIST): %_build: %_fmt %_iref
	$(GOBUILD) -o $(NAME) ./$*
	go tool vet -all=true $(SRC) $(PACKAGES)
$(CLEAN_LIST): %_clean:
	$(GOCLEAN) ./$*
$(INSTALL_LIST): %_install:
	$(GOINSTALL) ./$*
$(IREF_LIST): %_iref:
	$(GOTEST) -i ./$*
$(TEST_LIST): %_test:
	$(GOTEST) ./$*
$(FMT_LIST): %_fmt:
	$(GOFMT) ./$*

#$(BUILD_LIST): %_build: %_fmt %_iref
#	docker exec $(NAME_DOCKER_IMG) $(GOBUILD) -o $(NAME) ./$*
#	docker exec $(NAME_DOCKER_IMG) go tool vet -all=true $(SRC)
#$(CLEAN_LIST): %_clean:
#	docker exec $(NAME_DOCKER_IMG) $(GOCLEAN) ./$*
#$(INSTALL_LIST): %_install:
#	docker exec $(NAME_DOCKER_IMG) $(GOINSTALL) ./$*
#$(IREF_LIST): %_iref:
#	docker exec $(NAME_DOCKER_IMG) $(GOTEST) -i ./$*
#$(TEST_LIST): %_test:
#	docker exec $(NAME_DOCKER_IMG) $(GOTEST) ./$*
#$(FMT_LIST): %_fmt:
#	docker exec $(NAME_DOCKER_IMG) $(GOFMT) ./$*
#
