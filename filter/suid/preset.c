#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
printf("Content-type: text/plain\n\n");
fflush(NULL);
execl(PRESET, "/usr/bin/sudo", PRESET, (const char*)NULL);
}

