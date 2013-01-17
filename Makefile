VERSION_NUMBER=$(shell date +"%y%m%d%H%M")
BASE_DIR=$(shell pwd)
SRC_DIR=$(BASE_DIR)/src
BUILD_DIR=$(BASE_DIR)/build
LIB_SRC_DIR=$(BASE_DIR)/tmp
LIB_CURL=$(BASE_DIR)/lib/common-libcurl

COPTS=-Wall -I$(LIB_CURL)/include/curl/
LDOPTS=-framework CoreFoundation -framework Security -lz -lcurl -L$(LIB_CURL)/lib/

baito-client : init $(SRC_DIR)/main.c $(SRC_DIR)/parson.c $(SRC_DIR)/baito.c
	gcc $(COPTS) $(LDOPTS) -o $(BUILD_DIR)/baito-client $(SRC_DIR)/main.c $(SRC_DIR)/parson.c $(SRC_DIR)/baito.c

init: 
	mkdir -p $(BUILD_DIR) $(LIB_SRC_DIR)
	
clean:
	rm -rf $(BUILD_DIR)

