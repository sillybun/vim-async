#include <iostream>
#include <unistd.h>
#include <string.h>
#include <cstring>
using namespace std;

int main(int argc, char *argv[]) {
    double t = 0;
    int len = strlen(argv[1]);
    char * temp = (char *)(malloc(len));
    strcpy(temp, argv[1]);
    if(temp[len - 2] == 'm' && temp[len - 1] == 's') {
        temp[len - 2] = '\0';
        t = (double)atof(temp) / 1000;
    }
    else if (temp[len - 1] == 's') {
        temp[len - 1] = '\0';
        t = (double)atof(temp);
    }
    else
        t = 1;
    sleep(t);
    cout << '"' << argv[2] << '"' << endl;
    return 0;
}
