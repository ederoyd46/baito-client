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

int printJobResponse(JobResponse res) {
  puts("-------------------------------------------------");
  printf("Success: \t\t %i\n", res.success);
  if (res.success == 1) {
    printf("UUID: \t\t\t %s\n", res.job.uuid);
    printf("Title: \t\t\t %s\n", res.job.title);
    printf("Company: \t\t %s\n", res.job.company);
    printf("Contact Name: \t\t %s\n", res.job.contactName);
    printf("Contact Email: \t\t %s\n", res.job.contactEmail);
    printf("Contact Name: \t\t %s\n", res.job.contactName);
    printf("Hours: \t\t\t %G\n", res.job.hours);
    printf("Wage: \t\t\t %G\n", res.job.wage);
    printf("Latitude: \t\t %G\n", res.job.latitude);
    printf("Longitude: \t\t %G\n", res.job.longitude);
    printf("Postal Code: \t\t %s\n", res.job.postalCode);
    printf("Address: \n-------\n%s\n\n", res.job.address);
    printf("Description: \n-----------\n%s\n\n", res.job.description);
  }
  
  puts("-------------------------------------------------");
  return 0;
};



int main(int argc, char * argv[])
{
  if (argc == 1) {
    puts("Usage");
    puts("search [term]");
    puts("searchmore [term] [repeat]");
    puts("job [jobid]");
    puts("login [username] [password]");
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
  
  int job = strncmp("job", argv[1], strlen(argv[1]));
  if (job == 0) {
    if (!argv[2]) {
      puts("Enter a jobid");
    }
    const char *jobid = argv[2];
    JobResponse res = job_view(jobid);
    printJobResponse(res);
  }

  int login = strncmp("login", argv[1], strlen(argv[1]));
  if (login == 0) {
    if (!argv[2] || !argv[3]) {
      puts("Enter a username and password");
    }
    const char *username = argv[2];
    const char *password = argv[3];
    
    user_login(username, password);
  }
  
  return 0;
}




