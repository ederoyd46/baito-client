VERSION_NUMBER=$(shell date +"%y%m%d%H%M")
BASE_DIR=$(shell pwd)
SRC_DIR=$(BASE_DIR)/src
BUILD_DIR=$(BASE_DIR)/build

ifdef CROSS_COMPILE
	BAITO_CLIENT=$(CROSS_COMPILE)-baito-client
	LIB_CURL=$(BASE_DIR)/lib/$(CROSS_COMPILE)-libcurl
	LIB_SSL=$(BASE_DIR)/lib/$(CROSS_COMPILE)-libssl
	LIB_INCLUDE=$(BUILD_DIR)/$(CROSS_COMPILE)-libbaito/include/baito 
	LIB_LIB=$(BUILD_DIR)/$(CROSS_COMPILE)-libbaito/lib
	COMPILER=$(CC)
	COMPILER_FLAGS=$(CFLAGS) -Wall -I$(LIB_CURL)/include/ -I$(LIB_SSL)/include/
	LINKER_FLAGS=$(LDFLAGS) -L$(LIB_SSL)/lib/ -lssl -L$(LIB_CURL)/lib/ -lcurl -lcrypto -lz
else 
	BAITO_CLIENT=baito-client
	LIB_CURL=$(BASE_DIR)/lib/host-libcurl
	LIB_SSL=$(BASE_DIR)/lib/host-libssl
	LIB_INCLUDE=$(BUILD_DIR)/libbaito/include/baito 
	LIB_LIB=$(BUILD_DIR)/libbaito/lib
	COMPILER=gcc
	COMPILER_FLAGS=-Wall -I$(LIB_CURL)/include/ -I$(LIB_SSL)/include/
	LINKER_FLAGS=-L$(LIB_SSL)/lib/ -lssl -L$(LIB_CURL)/lib/ -lcurl -lcrypto -lz 
endif


baito-client : baito-lib $(SRC_DIR)/main.c
	@$(COMPILER) $(COMPILER_FLAGS) $(LINKER_FLAGS) -I$(LIB_INCLUDE) -L$(LIB_LIB) -lbaito -o $(BUILD_DIR)/$(BAITO_CLIENT) $(SRC_DIR)/main.c
	@echo Finished Building baito-client

baito-lib : baito-lib-compile
	@ar -rcs $(LIB_LIB)/libbaito.a $(BUILD_DIR)/baito.o $(BUILD_DIR)/parson.o
	@rm $(BUILD_DIR)/baito.o $(BUILD_DIR)/parson.o
	@echo Finished Building baito-lib

baito-lib-compile: init $(SRC_DIR)/parson.c $(SRC_DIR)/baito.c
	@mkdir -p $(LIB_INCLUDE) $(LIB_LIB)
	@cp $(SRC_DIR)/*.h $(LIB_INCLUDE)
	
	@$(COMPILER) -c $(COMPILER_FLAGS) $(SRC_DIR)/baito.c -o $(BUILD_DIR)/baito.o
	@$(COMPILER) -c $(COMPILER_FLAGS) $(SRC_DIR)/parson.c -o $(BUILD_DIR)/parson.o

init: 
	@mkdir -p $(BUILD_DIR)
	
clean:
	@rm -rf $(BUILD_DIR)

