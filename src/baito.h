// #include <curl.h>
// typedef struct JobSummary JobSummary;
// typedef struct SearchResultsResponse SearchResultsResponse;

struct JobSummary {
  const char *uuid;
  const char *company;
  const char *title;
  const char *description;
  double wage;
  double hours;
  double longitude;
  double latitude;
  double distance;
};

struct SearchResultsResponse {
  const char *searchTerm;
  int success;
  int count;
  int skip;
  double latitude;
  double longitude;
  struct JobSummary *results;
};

struct SearchResultsResponse jobs_search(char *searchTerm);
