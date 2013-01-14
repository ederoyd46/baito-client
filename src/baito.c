#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <curl/curl.h>

/* Auxiliary function that waits on the socket. */
static int wait_on_socket(curl_socket_t sockfd, int for_recv, long timeout_ms)
{
  struct timeval tv;
  fd_set infd, outfd, errfd;
  int res;

  tv.tv_sec = timeout_ms / 1000;
  tv.tv_usec= (timeout_ms % 1000) * 1000;

  FD_ZERO(&infd);
  FD_ZERO(&outfd);
  FD_ZERO(&errfd);

  FD_SET(sockfd, &errfd); /* always check for error */

  if(for_recv)
  {
    FD_SET(sockfd, &infd);
  }
  else
  {
    FD_SET(sockfd, &outfd);
  }

  /* select() returns the number of signalled sockets or -1 */
  res = select(sockfd + 1, &infd, &outfd, &errfd, &tv);
  return res;
}

int jobs_search(char *searchTerm) {
  CURL *curl;
  CURLcode res;
  curl_socket_t sockfd;
  long sockextr;
  size_t iolen;
  curl_off_t nread;
  
  char *preApi = "/api/search?searchTerm=%s";
  char *api = malloc(25 + strlen(searchTerm) + 1); //Include +1 for terminating null??
  sprintf(api, preApi, searchTerm);

  char *preRequest = "GET %s HTTP/1.1\r\nHost: baito.co.uk\r\n\r\n;";
  char *request = malloc(strlen(preRequest) + strlen(api) +1);
  sprintf(request, preRequest, api);
  
  
  curl_global_init(CURL_GLOBAL_DEFAULT);
  curl = curl_easy_init();
  
  if (curl) {
    curl_easy_setopt(curl, CURLOPT_URL, "https://baito.co.uk");
    curl_easy_setopt(curl, CURLOPT_CONNECT_ONLY, 1L);
    // curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L); -- Uncomment if the certificate is incorrect
    // curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
  
    res = curl_easy_perform(curl);
    if(res != CURLE_OK) fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
    
    res = curl_easy_getinfo(curl, CURLINFO_LASTSOCKET, &sockextr);
    if(res != CURLE_OK) fprintf(stderr, "curl_easy_getinfo() failed: %s\n", curl_easy_strerror(res));
    
    sockfd = sockextr;
    /* wait for the socket to become ready for sending */
    if(!wait_on_socket(sockfd, 0, 60000L))
    {
      printf("Error: timeout.\n");
      return 1;
    }
  
    puts("Sending request.");
  
    res = curl_easy_send(curl, request, strlen(request), &iolen);
    if(res != CURLE_OK) fprintf(stderr, "curl_easy_send() failed: %s\n", curl_easy_strerror(res));
  
    puts("Reading response.");
  
    /* read the response */
    char *response = malloc(1024);
    for(;;)
    {
      char buf[1024];
  
      wait_on_socket(sockfd, 1, 60000L);
      res = curl_easy_recv(curl, buf, 1024, &iolen);
  
      if(CURLE_OK != res) 
        break;
      
      nread = (curl_off_t)iolen;
      
      char *existing = malloc(strlen(response));
      strcpy(existing, response);
      response = malloc(strlen(response) + strlen(buf));
      strcpy(response, existing);
      strcat(response, buf);
  
      printf("Received %" CURL_FORMAT_CURL_OFF_T " bytes.\n", nread);
    }
    
    puts(response);
    
    curl_easy_cleanup(curl);
  }
   
  curl_global_cleanup();
   
  return 0;
}



