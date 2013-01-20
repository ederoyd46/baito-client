#include <stdio.h>
#include "baito.h"
#include "parson.h"

int main(int argc, char * argv[])
{
  struct SearchResultsResponse res;
  int i;

  for (i=0; i<argc; i++) {
    printf("arg: %i, value: %s \n", i, argv[i]);
  }
  
  if (argc == 2) {
    char *searchTerm = argv[1];
    res = jobs_search(searchTerm);
  } else {
    res = jobs_search("AL3 5PX");
  }
  
  puts("-------------------------------------------------");
  printf("Search Term: %s\n", res.searchTerm);
  printf("Success: %i\n", res.success);
  printf("Count: %i\n", res.count);
  printf("Skip: %i\n", res.skip);
  printf("Latitude: %G\n", res.latitude);
  printf("Longitude: %G\n", res.longitude);
  puts("-------------------------------------------------");

  for (i=0; i<res.count; i++) {
    printf("distance: %-5G| uuid: %-40s| company: %-40s| title: %-40s\n", res.results[i].distance, res.results[i].uuid, res.results[i].company, res.results[i].title);
  }
  puts("-------------------------------------------------");
  
  clear_job_search(res);
  return 0;
}




