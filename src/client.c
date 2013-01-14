#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <curl/curl.h>

int jobs_search(char *searchTerm) {
  CURL *curl;
  CURLcode res;
  
  curl_global_init(CURL_GLOBAL_DEFAULT);
  curl = curl_easy_init();
  
  char *apiUrl = "https://baito.co.uk/api/search?searchTerm=";
  size_t len1 = strlen(apiUrl);
  size_t len2 = strlen(searchTerm);
  char *fullSearchTerm = malloc(len1 + len2 + 1); //Include +1 for terminating null
  sprintf(fullSearchTerm, "%s%s", apiUrl, searchTerm);
  
  if (curl) {
    curl_easy_setopt(curl, CURLOPT_URL, fullSearchTerm);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    res = curl_easy_perform(curl);
    if(res != CURLE_OK) fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    curl_easy_cleanup(curl);
  }
 
  curl_global_cleanup();
 
  return 0;
}