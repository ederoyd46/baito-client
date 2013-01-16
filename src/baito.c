#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>
#include "parson.h"

struct MemoryStruct {
  char *memory;
  size_t size;
};

struct SearchResultsResponse {
  const char *searchTerm;
  int success;
  int count;
  int skip;
  double latitude;
  double longitude;
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

static CURL* get_curl_handle() {
  CURL *curl_handle;
  
  curl_global_init(CURL_GLOBAL_ALL);
  curl_handle = curl_easy_init();

  if(curl_handle) {
    curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");
  }
  
  return curl_handle;
}

static int put_curl_handle(CURL *curl_handle) {
  curl_easy_cleanup(curl_handle);
  curl_global_cleanup();
  return 0;
}


static char* get_data(CURL *curl_handle, char *url) {
  CURLcode res;

  struct MemoryStruct chunk;
  chunk.memory = malloc(1);
  chunk.size = 0;
  
  if(curl_handle) {    
    curl_easy_setopt(curl_handle, CURLOPT_URL, url);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
    curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
    res = curl_easy_perform(curl_handle);
    
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
  }
 
  printf("%lu bytes retrieved\n", (long)chunk.size);
  return chunk.memory;
}



int jobs_search(char *searchTerm) {
  char *api = "https://baito.co.uk/api/search?searchTerm=%s";
  CURL *curl_handle = get_curl_handle();

  char *parsedSearchTerm = curl_easy_escape(curl_handle, searchTerm, strlen(searchTerm));

  char *apiUrl = malloc(strlen(api) + strlen(parsedSearchTerm) +1);
  sprintf(apiUrl, api, parsedSearchTerm);

  char *response = get_data(curl_handle, apiUrl);

  JSON_Value *jsonValue = json_parse_string(response);
  JSON_Object *jsonObj = json_value_get_object(jsonValue);

  struct SearchResultsResponse searchResultResponse;
  searchResultResponse.searchTerm = json_object_dotget_string(jsonObj, "SearchResultsResponse.searchTerm");
  searchResultResponse.success = json_object_dotget_boolean(jsonObj, "SearchResultsResponse.success");
  searchResultResponse.count = json_object_dotget_number(jsonObj, "SearchResultsResponse.count");
  searchResultResponse.skip = json_object_dotget_number(jsonObj, "SearchResultsResponse.skip");
  searchResultResponse.latitude = json_object_dotget_number(jsonObj, "SearchResultsResponse.searchLocation.latitude");
  searchResultResponse.longitude = json_object_dotget_number(jsonObj, "SearchResultsResponse.searchLocation.longitude");
  
  printf("Search Term: %s\n", searchResultResponse.searchTerm);
  printf("Success: %i\n", searchResultResponse.success);
  printf("Count: %i\n", searchResultResponse.count);
  printf("Skip: %i\n", searchResultResponse.skip);
  printf("Latitude: %G\n", searchResultResponse.latitude);
  printf("Longitude: %G\n", searchResultResponse.longitude);
  
  if (response) free(response);
  put_curl_handle(curl_handle);

  return 0;
}

