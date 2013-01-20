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

int clear_job_search(SearchResultsResponse searchResultsResponse) {
  // int i;
  // for (i=0; i<searchResultsResponse.count; i++) {
  //   printf("About to free index %i\n", i);
  //   free((char*)searchResultsResponse.results[i].description);
  //   free((char*)searchResultsResponse.results[i].title);
  //   // free((char*)searchResultsResponse.results[i].company);
  //   free((char*)searchResultsResponse.results[i].uuid);
  // }
  free(searchResultsResponse.results);
  free((char*)searchResultsResponse.searchTerm);
  
  return 0;
}

SearchResultsResponse jobs_search(char *searchTerm) {
  char *api = "https://baito.co.uk/api/search?searchTerm=%s&limit=20";
  CURL *curl_handle = get_curl_handle();

  char *parsedSearchTerm = curl_easy_escape(curl_handle, searchTerm, strlen(searchTerm));

  char *apiUrl = malloc(strlen(api) + strlen(parsedSearchTerm) +1);
  sprintf(apiUrl, api, parsedSearchTerm);

  char *response = get_data(curl_handle, apiUrl);

  JSON_Value *jsonValue = json_parse_string(response);
  JSON_Object *jsonObj = json_value_get_object(jsonValue);

  SearchResultsResponse searchResultResponse;
  searchResultResponse.searchTerm = json_object_dotget_string(jsonObj, "SearchResultsResponse.searchTerm");
  searchResultResponse.success = json_object_dotget_boolean(jsonObj, "SearchResultsResponse.success");
  searchResultResponse.count = json_object_dotget_number(jsonObj, "SearchResultsResponse.count");
  searchResultResponse.skip = json_object_dotget_number(jsonObj, "SearchResultsResponse.skip");
  searchResultResponse.latitude = json_object_dotget_number(jsonObj, "SearchResultsResponse.searchLocation.latitude");
  searchResultResponse.longitude = json_object_dotget_number(jsonObj, "SearchResultsResponse.searchLocation.longitude");

  JSON_Array *jsonArray = json_object_dotget_array(jsonObj, "SearchResultsResponse.results");
  if (jsonArray != NULL && json_array_get_count(jsonArray) > 0) {
    int i;
    searchResultResponse.results = calloc(json_array_get_count(jsonArray), sizeof(JobSummary));
    for (i = 0; i < json_array_get_count(jsonArray); i++) {
      JSON_Object *record = json_array_get_object(jsonArray, i);
      
      const char *uuid = json_object_dotget_string(record, "job.JobSummary.uuid");
      // searchResultResponse.results[i].uuid = malloc(sizeof(uuid));
      searchResultResponse.results[i].uuid = uuid;

      const char *company = json_object_dotget_string(record, "job.JobSummary.uuid");
      // searchResultResponse.results[i].company = malloc(sizeof(company));
      searchResultResponse.results[i].company = company;

      const char *title = json_object_dotget_string(record, "job.JobSummary.title");
      // searchResultResponse.results[i].title = malloc(sizeof(title));
      searchResultResponse.results[i].title = title;

      const char *description = json_object_dotget_string(record, "job.JobSummary.description");
      // searchResultResponse.results[i].description = malloc(sizeof(description));
      searchResultResponse.results[i].description = description;
    
      searchResultResponse.results[i].wage = json_object_dotget_number(record, "job.JobSummary.wage");
      searchResultResponse.results[i].hours = json_object_dotget_number(record, "job.JobSummary.hours");
      searchResultResponse.results[i].longitude = json_object_dotget_number(record, "job.JobSummary.location.longitude");
      searchResultResponse.results[i].latitude = json_object_dotget_number(record, "job.JobSummary.location.latitude");
      searchResultResponse.results[i].distance = json_object_dotget_number(record, "distance");
    }
  }


  if (response) free(response);
  put_curl_handle(curl_handle);

  return searchResultResponse;
}

