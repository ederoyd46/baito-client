#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <openssl/sha.h>
#include <curl/curl.h>
#include "parson.h"
#include "baito.h"


//-Common ----------------------------------------------------------------------------------


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


const char* get_session_key(CURL *curl_handle) {
  CURLcode res;
  struct curl_slist *cookies;
  struct curl_slist *nc;
  
  res = curl_easy_getinfo(curl_handle, CURLINFO_COOKIELIST, &cookies);
  if (res != CURLE_OK) {
    fprintf(stderr, "Curl curl_easy_getinfo failed: %s\n", curl_easy_strerror(res));
  }
  nc = cookies;
  char *sessionKey;
  while (nc) {
    char *data = nc->data;
    char *token;
    
    token = strtok(data, "\t");
    while (token != NULL) {
      const char *current_token = token;
      if (strcmp("sessionkey", current_token) == 0) {
        token = strtok (NULL, "\t");
        sessionKey = token;
        break;
      }
      token = strtok (NULL, "\t");
    }
    nc = nc->next;
  }
  curl_slist_free_all(cookies);
  return sessionKey;
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
    curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, 0);
    //    curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYHOST, 0);
    curl_easy_setopt(curl_handle, CURLOPT_COOKIEFILE, "");
    res = curl_easy_perform(curl_handle);
    
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
  }
 
  printf("%lu bytes retrieved\n", (long)chunk.size);
  return chunk.memory;
}

//-Job Search ------------------------------------------------------------------------------

SearchResultsResponse jobs_search_for_more(SearchResultsResponse existing) {
  int skip = existing.count;
  
  SearchResultsResponse new;
  if (existing.searchTerm != NULL) {
    new = jobs_search_full(existing.searchTerm, 0, 0, RESULT_LIMIT, skip);
  } else {
    new = jobs_search_full(NULL, existing.latitude, existing.longitude, RESULT_LIMIT, skip);
  }
  
  if (new.count == 0) {
    free(new.results);
    existing.morePossible = 0;
    return existing;
  }
  
  int fullCount = existing.count + new.count;

  SearchResultsResponse newResponse;
  newResponse.success = new.success;
  newResponse.count= fullCount;
  newResponse.latitude = new.latitude;
  newResponse.longitude = new.longitude;
  newResponse.skip = new.skip;
  newResponse.morePossible = new.morePossible;
  newResponse.searchTerm = new.searchTerm;
  newResponse.results = calloc(fullCount, sizeof(JobSummary));
  
  int i = 0;
  int x;
  for (x=0; x<existing.count; x++) {
    newResponse.results[i] = existing.results[x];
    i++;
  }
  
  for (x=0; x<new.count; x++) {
    newResponse.results[i] = new.results[x];
    i++;
  }
  
  free(existing.results);
  free(new.results);
  
  return newResponse;
  
};

SearchResultsResponse jobs_direct_search(const double latitude, const double longitude) {
  return jobs_search_full(NULL, latitude, longitude, RESULT_LIMIT, 0);
};


SearchResultsResponse jobs_search(const char *searchTerm) {
  return jobs_search_full(searchTerm, 0, 0, RESULT_LIMIT, 0);
};

SearchResultsResponse jobs_search_full(const char *searchTerm, const double latitude, const double longitude, int limit, int skip) {
  CURL *curl_handle = get_curl_handle();
  
  char *apiUrl;
  
  if (searchTerm != NULL) {
    const char *searchTermApi = "https://baito.co.uk/api/search?searchTerm=%s&limit=%i&skip=%i";
    const char *parsedSearchTerm = curl_easy_escape(curl_handle, searchTerm, 0);
    apiUrl = malloc(strlen(searchTermApi) + strlen(parsedSearchTerm) +1);
    sprintf(apiUrl, searchTermApi, parsedSearchTerm, limit, skip);
    printf("search by term: %s limit: %i, skip: %i\nurl: %s\n", searchTerm, limit, skip, apiUrl);
  } else {
    if (latitude != 0 && longitude != 0) {
      const char *searchLocationApi = "https://baito.co.uk/api/search?searchLatitude=%G&searchLongitude=%G&limit=%i&skip=%i";
      apiUrl = malloc(strlen(searchLocationApi) + sizeof(latitude) + sizeof(longitude) +1);
      sprintf(apiUrl, searchLocationApi, latitude, longitude, limit, skip);
      printf("search by latitude: %G longitude: %G limit: %i skip: %i\nurl: %s\n", latitude, longitude, limit, skip, apiUrl);
    }
  }
  
  const char *response = get_data(curl_handle, apiUrl);
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
  int total = json_array_get_count(jsonArray);
  if (total < limit) {
    searchResultResponse.morePossible = 0;
  } else {
    searchResultResponse.morePossible = 1;
  }
  
  if (jsonArray != NULL && total > 0) {
    int i;
    searchResultResponse.results = calloc(total, sizeof(JobSummary));
    for (i = 0; i < total; i++) {
      JSON_Object *record = json_array_get_object(jsonArray, i);

      const char *uuid = json_object_dotget_string(record, "job.JobSummary.uuid");
      searchResultResponse.results[i].uuid = uuid;

      const char *company = json_object_dotget_string(record, "job.JobSummary.company");
      searchResultResponse.results[i].company = company;

      const char *title = json_object_dotget_string(record, "job.JobSummary.title");
      searchResultResponse.results[i].title = title;
    
      searchResultResponse.results[i].wage = json_object_dotget_number(record, "job.JobSummary.wage");
      searchResultResponse.results[i].hours = json_object_dotget_number(record, "job.JobSummary.hours");
      searchResultResponse.results[i].longitude = json_object_dotget_number(record, "job.JobSummary.location.longitude");
      searchResultResponse.results[i].latitude = json_object_dotget_number(record, "job.JobSummary.location.latitude");
      searchResultResponse.results[i].distance = json_object_dotget_number(record, "distance");
    }
  }

  if (apiUrl) free(apiUrl);
  if (jsonArray) free(jsonArray);
  if (jsonObj) free(jsonObj);
  put_curl_handle(curl_handle);

  return searchResultResponse;
};

int clear_job_search(SearchResultsResponse searchResultsResponse) {
  //Must read up on freeing const char's
  
  if (searchResultsResponse.count > 0) {
    free(searchResultsResponse.results);
  }
  
  return 0;
}

//-Job Info --------------------------------------------------------------------------------

JobResponse job_view(const char* jobid) {
  CURL *curl_handle = get_curl_handle();
  const char *api = "https://baito.co.uk/api/job/view?jobid=%s";
  const char *parsedJobId = curl_easy_escape(curl_handle, jobid, 0);
  char *apiUrl = malloc(strlen(api) + strlen(parsedJobId) +1);
  sprintf(apiUrl, api, parsedJobId);
  const char *response = get_data(curl_handle, apiUrl);

  JSON_Value *jsonValue = json_parse_string(response);
  JSON_Object *jsonObj = json_value_get_object(jsonValue);
  JobResponse jobResponse;
  jobResponse.success = json_object_dotget_boolean(jsonObj, "JobResponse.success");
  
  if (jobResponse.success == 1) {
    Job job;
    job.uuid = json_object_dotget_string(jsonObj, "JobResponse.job.Job.uuid");
    job.company = json_object_dotget_string(jsonObj, "JobResponse.job.Job.company");
    job.title = json_object_dotget_string(jsonObj, "JobResponse.job.Job.title");
    job.description = json_object_dotget_string(jsonObj, "JobResponse.job.Job.description");
    job.contactName = json_object_dotget_string(jsonObj, "JobResponse.job.Job.contactName");
    job.contactEmail = json_object_dotget_string(jsonObj, "JobResponse.job.Job.contactEmail");
    job.contactTelephone = json_object_dotget_string(jsonObj, "JobResponse.job.Job.contactTelephone");
    job.address = json_object_dotget_string(jsonObj, "JobResponse.job.Job.address");
    job.postalCode = json_object_dotget_string(jsonObj, "JobResponse.job.Job.postalCode");
    job.wage = json_object_dotget_number(jsonObj, "JobResponse.job.Job.wage");
    job.hours = json_object_dotget_number(jsonObj, "JobResponse.job.Job.hours");
    job.longitude = json_object_dotget_number(jsonObj, "JobResponse.job.Job.location.longitude");
    job.latitude = json_object_dotget_number(jsonObj, "JobResponse.job.Job.location.latitude");
    jobResponse.job = job;
  }
  put_curl_handle(curl_handle);
  return jobResponse;
  
}

//-User Authentication -----------------------------------------------------------------------

const char* user_login(const char *username, const char *password) {
  CURL *curl_handle = get_curl_handle();
  
  const char *parsedUsername = curl_easy_escape(curl_handle, username, 0);
  
  unsigned char hash[SHA256_DIGEST_LENGTH];
  SHA256_CTX sha256;
  SHA256_Init(&sha256);
  SHA256_Update(&sha256, password, strlen(password));
  SHA256_Final(hash, &sha256);

  char parsedPassword[65];
  int i = 0;
  for(i = 0; i < SHA256_DIGEST_LENGTH; i++) {
    sprintf(parsedPassword + (i * 2), "%02x", hash[i]);
  }
  parsedPassword[64] = 0;
  
  char *params = malloc(strlen("username=%s&password=%s")+strlen(parsedUsername)+strlen(parsedPassword));
  sprintf(params, "username=%s&password=%s", parsedUsername, parsedPassword);
  
  
  curl_easy_setopt(curl_handle, CURLOPT_POST, 1);
  curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, params);
  const char *response = get_data(curl_handle, "https://baito.co.uk/api/user/login");
  
  printf("%s\n", response);
  
  
  const char *sessionKey = get_session_key(curl_handle);
  put_curl_handle(curl_handle);
  return sessionKey;
}

void who_am_i(const char *sessionKey) {
  const char *api = "https://baito.co.uk/api/user/whoami?sessionkey=%s";

  CURL *curl_handle = get_curl_handle();
  char *apiUrl = malloc(strlen(api) + strlen(sessionKey) +1);
  sprintf(apiUrl, api, sessionKey);
  const char *response = get_data(curl_handle, apiUrl);
  puts(response);
}

void user_view_favourites(const char *sessionKey) {
  const char *api = "https://baito.co.uk/api/user/view/favourites?sessionkey=%s";
  CURL *curl_handle = get_curl_handle();
  char *apiUrl = malloc(strlen(api) + strlen(sessionKey) +1);
  sprintf(apiUrl, api, sessionKey);
  const char *response = get_data(curl_handle, apiUrl);
  puts(response);
}

void user_view_applications(const char *sessionKey) {
  const char *api = "https://baito.co.uk/api/user/view/applications?sessionkey=%s";
  CURL *curl_handle = get_curl_handle();
  char *apiUrl = malloc(strlen(api) + strlen(sessionKey) +1);
  sprintf(apiUrl, api, sessionKey);
  const char *response = get_data(curl_handle, apiUrl);
  puts(response);
}

void user_view_created(const char *sessionKey) {
  const char *api = "https://baito.co.uk/api/user/view/created?sessionkey=%s";
  CURL *curl_handle = get_curl_handle();
  char *apiUrl = malloc(strlen(api) + strlen(sessionKey) +1);
  sprintf(apiUrl, api, sessionKey);
  const char *response = get_data(curl_handle, apiUrl);
  puts(response);  
}








