#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl.h>
#include "parson.h"
#include "baito.h"

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

struct SearchResultsResponse jobs_search(char *searchTerm) {
  char *api = "https://baito.co.uk/api/search?searchTerm=%s&limit=20";
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

  JSON_Array *jsonArray = json_object_dotget_array(jsonObj, "SearchResultsResponse.results");
  if (jsonArray != NULL && json_array_get_count(jsonArray) > 0) {
    struct JobSummary results[json_array_get_count(jsonArray)];
    int i;
    for (i = 0; i < json_array_get_count(jsonArray); i++) {
      struct JobSummary result;
      JSON_Object *record = json_array_get_object(jsonArray, i);
      result.uuid = json_object_dotget_string(record, "JobSummary.uuid");
      result.company = json_object_dotget_string(record, "JobSummary.company");
      result.title = json_object_dotget_string(record, "JobSummary.title");
      result.description = json_object_dotget_string(record, "JobSummary.description");

      result.wage = json_object_dotget_number(record, "JobSummary.wage");
      result.hours = json_object_dotget_number(record, "JobSummary.hours");
      result.longitude = json_object_dotget_number(record, "JobSummary.longitude");
      result.latitude = json_object_dotget_number(record, "JobSummary.latitude");
      result.distance = json_object_dotget_number(record, "distance");
      
      results[i] = result;
    }
    searchResultResponse.results = results;
  }


  if (response) free(response);
  put_curl_handle(curl_handle);

  return searchResultResponse;
}

