#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
printf("Content-type: text/plain\n\n");
fflush(NULL);
execl("/opt/filter/lockdown.sh", "/opt/filter/lockdown.sh", "unlock", "now", (const char*)NULL);
}

