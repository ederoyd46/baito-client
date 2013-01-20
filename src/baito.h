// #include <curl.h>
// typedef struct JobSummary JobSummary;
// typedef struct SearchResultsResponse SearchResultsResponse;

typedef struct JobSummary {
  const char *uuid;
  const char *company;
  const char *title;
  const char *description;
  double wage;
  double hours;
  double longitude;
  double latitude;
  double distance;
} JobSummary;

typedef struct SearchResultsResponse {
  const char *searchTerm;
  int success;
  int count;
  int skip;
  double latitude;
  double longitude;
  JobSummary *results;
} SearchResultsResponse;


struct SearchResultsResponse jobs_search(char *searchTerm);
int clear_job_search(SearchResultsResponse searchResultsResponse);