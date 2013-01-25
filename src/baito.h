// #include <curl.h>
#define RESULT_LIMIT 20

typedef struct JobSummary {
  const char *uuid;
  const char *company;
  const char *title;
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

typedef struct Job {
  const char *uuid;
  const char *company;
  const char *title;
  const char *description;
  const char *address;
  const char *postalCode;
  const char *contactName;
  const char *contactEmail;
  const char *contactTelephone;
  double wage;
  double hours;
  double longitude;
  double latitude;
} Job;

typedef struct JobResponse {
  int success;
  Job job;
} JobResponse;

SearchResultsResponse jobs_search(const char *searchTerm);
SearchResultsResponse jobs_search_full(const char *searchTerm, int limit, int skip);
SearchResultsResponse jobs_search_for_more(SearchResultsResponse existingResults);
int clear_job_search(SearchResultsResponse searchResultsResponse);

JobResponse job_view(const char* jobid);
//int clear_job_view(JobResponse jobResponse);

