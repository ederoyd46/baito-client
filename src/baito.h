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
  int morePossible;
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


typedef struct User {
  const char *username;
  const char *name;
  const char *phone;
  const char *email;
  const char *birthDate;
  
  const char **favouriteJobs;
  const char **createdJobs;
  const char **jobApplications;
  size_t createdJobsCount;
  size_t favouriteJobsCount;
  size_t jobApplicationsCount;
} User;

typedef struct UserResponse {
  int success;
  User user;
} UserResponse;

SearchResultsResponse jobs_search(const char *searchTerm);
SearchResultsResponse jobs_direct_search(const double latitude, const double longitude);
SearchResultsResponse jobs_search_full(const char *searchTerm, const double latitude, const double longitude, int limit, int skip);
SearchResultsResponse jobs_search_for_more(SearchResultsResponse existingResults);
int clear_job_search(SearchResultsResponse searchResultsResponse);

JobResponse job_view(const char *jobid);

const char* user_login(const char *username, const char *password);
UserResponse who_am_i(const char *sessionKey);
void user_view_favourites(const char *sessionKey);
void user_view_applications(const char *sessionKey);
void user_view_created(const char *sessionKey);

