#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <stdint.h>
#include <pthread.h>
#include "udpclient.h"


#define AUDIO_IN_L_REG *((unsigned *)(audioInPtr + 0))
#define AUDIO_IN_R_REG *((unsigned *)(audioInPtr + 4))

#define AUDIO_OUT_CHA_L_REG *((unsigned *)(audioOutPtrA + 0))
#define AUDIO_OUT_CHA_R_REG *((unsigned *)(audioOutPtrA + 4))

#define AUDIO_OUT_CHB_L_REG *((unsigned *)(audioOutPtrB + 0))
#define AUDIO_OUT_CHB_R_REG *((unsigned *)(audioOutPtrB + 4))


char *myfifo = "/tmp/myfifo";
void *audioInPtr;
void *audioOutPtrA;
void *audioOutPtrB;

int audioInFd;

void *line_out(){
	int fifo;
	fifo = open(myfifo, O_RDONLY);
	int buffer;
	while (1) {
		read(fifo, &buffer, sizeof(buffer));
		AUDIO_OUT_CHA_L_REG = buffer;
		AUDIO_OUT_CHA_R_REG = buffer;
	}
	return 0;
}

void *line_out_2() {
        // Create interrupt for axi audio
        printf("Enabling interrupt\n");
        int IRQEnable = 1; 
        write(audioInFd, &IRQEnable, sizeof(IRQEnable));

        printf("Waiting for new sample interrupt\n");
        while (1) {
            read(audioInFd, &IRQEnable, sizeof(IRQEnable));
            AUDIO_OUT_CHB_L_REG = AUDIO_IN_L_REG;
            AUDIO_OUT_CHB_R_REG = AUDIO_IN_R_REG;

            // Enable interrupt again
            write(audioInFd, &IRQEnable, sizeof(IRQEnable));
        }
}


int main(int argc, char *argv[])
{
        printf("Starting audio_copy_driver");

        // Open uio device
        printf("Opening in /dev/uio0");
        audioInFd = open("/dev/uio0", O_RDWR);
        if (audioInFd < 1) { perror("UIO"); return -1; }


        // Audio out address
        unsigned addressA = 0x43c10000;
        unsigned addressB = 0x43c20000;

        printf("Opening /dev/mem");
        int audioOutFd = open("/dev/mem", O_RDWR);
        if (audioOutFd < 1) { perror("mem"); return -1; }

        printf("/dev/mem opened");
    	/* create the FIFO (named pipe) */
    	mkfifo(myfifo, 0666);


  
        //get architecture specific page size
        unsigned pageSize = sysconf(_SC_PAGESIZE);

        unsigned offsetA = (addressA & (~(pageSize - 1)));
        unsigned offsetB = (addressB & (~(pageSize - 1)));

        printf("Mapping addresses\n");
        audioInPtr = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_SHARED, audioInFd, 0);
        audioOutPtrA = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_SHARED, audioOutFd, offsetA);
        audioOutPtrB = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_SHARED, audioOutFd, offsetB);


        printf("Creating thread for line_out data from axi audio");
        pthread_t line_out_thread_2;

        if (pthread_create(&line_out_thread_2, NULL, line_out_2, NULL)) {
            fprintf(stderr, "Error creating thread for data from axi audio");
            return 1;
        }

        

        printf("Creating thread for line_out data from udp stream\n");
	pthread_t line_out_thread;
	
 	if(pthread_create(&line_out_thread, NULL, line_out, NULL)) {
		fprintf(stderr, "Error creating thread for data from udp\n");
		return 1;
	}
	int fifo;
	fifo = open(myfifo, O_WRONLY);
	udp_client_setup("10.255.255.255", 7891);

	unsigned buffer[64];
        printf("Waiting for udp data\n");
        while (1) {
		udp_client_recv(buffer, sizeof(buffer));
		write(fifo, &buffer, sizeof(buffer));
        }

    return 0;
}
