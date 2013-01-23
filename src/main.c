#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "baito.h"
#include "parson.h"

int printSearchResultResponse(SearchResultsResponse res) {
  puts("-------------------------------------------------");
  printf("Search Term: %s\n", res.searchTerm);
  printf("Success: %i\n", res.success);
  printf("Count: %i\n", res.count);
  printf("Skip: %i\n", res.skip);
  printf("Latitude: %G\n", res.latitude);
  printf("Longitude: %G\n", res.longitude);
  puts("-------------------------------------------------");
  
  int i;
  for (i=0; i<res.count; i++) {
    printf("distance: %-5G| uuid: %-40s| company: %-40s| title: %-40s\n", res.results[i].distance, res.results[i].uuid, res.results[i].company, res.results[i].title);
    
  }
  puts("-------------------------------------------------");
  
  return 0;
};

int main(int argc, char * argv[])
{
  if (argc == 1) {
    printf("Usage\nsearch [term]\nsearchmore [term]\n");
    return 0;
  }

  int search = strncmp("search", argv[1], strlen(argv[1]));
  if (search == 0) {
    if (!argv[2]) {
      puts("Enter a term");
      return 1;
    }
    char *searchTerm = argv[2];
    SearchResultsResponse res = jobs_search(searchTerm);
    printSearchResultResponse(res);
    clear_job_search(res);
    return 0;
  }

  int searchmore = strncmp("searchmore", argv[1], strlen(argv[1]));
  if (searchmore == 0) {
    if (!argv[2] || !argv[3]) {
      puts("Enter a term and a repeat");
      return 1;
    }
    char *searchTerm = argv[2];
    
    int repeat = (int) strtol(argv[3], NULL, 0);
    int i;
    
    SearchResultsResponse res = jobs_search(searchTerm);
    
    for (i=0; i<repeat; i++) {
      res = jobs_search_for_more(res);
    }
    printSearchResultResponse(res);
    clear_job_search(res);
    return 0;
  }
  
  
  
  return 0;
}




