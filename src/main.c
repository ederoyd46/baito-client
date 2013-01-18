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
    res = jobs_search("pudsey");
  }
  
  return 0;
}




