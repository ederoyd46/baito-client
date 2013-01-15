#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>
#include "parson.h"

struct MemoryStruct {
  char *memory;
  size_t size;
};
 
static size_t WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
  size_t realsize = size * nmemb;
  struct MemoryStruct *mem = (struct MemoryStruct *)userp;
 
  mem->memory = realloc(mem->memory, mem->size + realsize + 1);
  if (mem->memory == NULL) {
    /* out of memory! */ 
    printf("not enough memory (realloc returned NULL)\n");
    exit(EXIT_FAILURE);
  }
 
  memcpy(&(mem->memory[mem->size]), contents, realsize);
  mem->size += realsize;
  mem->memory[mem->size] = 0;
 
  return realsize;
}


static char* get_data(char *url) {
  CURL *curl_handle;
  CURLcode res;
  struct MemoryStruct chunk;
  chunk.memory = malloc(1);
  chunk.size = 0;
 
  curl_global_init(CURL_GLOBAL_ALL);
  curl_handle = curl_easy_init();
  
  if(curl_handle) {
    curl_easy_setopt(curl_handle, CURLOPT_URL, url);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");
    res = curl_easy_perform(curl_handle);
    if(res != CURLE_OK) fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    
    curl_easy_cleanup(curl_handle);
  }
 
  printf("%lu bytes retrieved\n", (long)chunk.size);
  curl_global_cleanup();
 
  return chunk.memory;
}

int jobs_search(char *searchTerm) {
  char *api = "https://baito.co.uk/api/search?searchTerm=%s";
  char *apiUrl = malloc(strlen(api) + strlen(searchTerm) +1);
  sprintf(apiUrl, api, searchTerm);
  
  char *response = get_data(apiUrl);
  // puts(response);
  JSON_Value *jsonValue = json_parse_string(response);
  JSON_Object *jsonObj = json_value_get_object(jsonValue);
  puts(json_object_dotget_string(jsonObj, "SearchResultsResponse.searchTerm"));
  // puti(json_object_dotget_boolean(jsonObj, "SearchResultsResponse.success"));

    // puts(json_object_dotget_string(parsedResponse, ""));
  

  
  // if (response) free(response);
  
  

  // if(chunk.memory) {
  //   free(chunk.memory);
  // }
  //   
  //  
  /* we're done with libcurl, so clean it up */ 
  
  return 0;
}

