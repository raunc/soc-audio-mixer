/*
* Simple app to read/write into custom IP in PL via /dev/uoi0 interface
* To compile for arm: make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-
* Author: Tsotnep, Kjans
*/
  
//C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdint.h>


#define AUDIO_IN_L_REG *((unsigned *)(audioInPtr + 0))
#define AUDIO_IN_R_REG *((unsigned *)(audioInPtr + 4))

#define AUDIO_OUT_L_REG *((unsigned *)(audioOutPtr + 0))
#define AUDIO_OUT_R_REG *((unsigned *)(audioOutPtr + 4))


int main(int argc, char *argv[])
{
        printf("Starting audio_copy_driver");
    
        // Open devices
        printf("Opening in device");
        int audioInFd = open("/dev/uio0", O_RDWR);
        if (audioInFd < 1) { perror("UIO"); return -1; }

        // Audio out address
        unsigned address = 0x43c10000;

        printf("Opening /dev/mem");
        int audioOutFd = open("/dev/mem", O_RDWR);
        if (audioOutFd < 1) { perror("mem"); return -1; }

        printf("/dev/mem opened");

        //Redirect stdout/printf into /dev/kmsg file (so it will be printed using printk)
        //freopen ("/dev/kmsg","w",stdout);
  
        //get architecture specific page size
        unsigned pageSize = sysconf(_SC_PAGESIZE);

        unsigned offset = (address & (~(pageSize - 1)));
        //unsigned registerOffset = address - offset;
  
        /*************************************************************************************************
         * TASK 1: Map the physical address to virtual address.                                          *
         *************************************************************************************************
         * HINT 0: You can look at how you did this in the /dev/mem task.                                *
         * HINT 1: When mapping in UIO, there are some differences from doing it in /dev/mem.            *
         *         check the "Mapping usage in UIO" section in Lab 3 additional materials for details.   *
         *************************************************************************************************/
          
        printf("Mapping address\n");
        void *audioInPtr = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_SHARED, audioInFd, 0);

        void *audioOutPtr = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_SHARED, audioOutFd, offset);

        /************************************************************************************************
         * TASK 2: Enable interrupts                                                                    *
         ************************************************************************************************
         * HINT 0: You need to write the value of IRQEnable into a specific file.                       *
         * HINT 1: You can find more information from the "Userspace I/O (UIO)" section in the          *
         *         LAB 3 additional material                                                            *
         ************************************************************************************************/
         
        printf("Enabling interrupt\n");
        int IRQEnable = 1; 
        write(audioInFd, &IRQEnable, sizeof(IRQEnable));
         
        /************************************************************************************************
         * TASK 3: Wait for interrupts (block program execution until the interrupt is received         *
         ************************************************************************************************
         * HINT 0: You need to read a specific file                                                     *
         * HINT 1: You can find more information from the "Userspace I/O (UIO)" section in the          *
         *         LAB 3 additional material                                                            *
         * HINT 2: Use the IRQEnable variable for storing the output of the function                    *
         ************************************************************************************************/
 
        printf("Waiting for new sample interrupt\n");
        while (1) {
            read(audioInFd, &IRQEnable, sizeof(IRQEnable));
            AUDIO_OUT_L_REG = AUDIO_IN_L_REG;
            AUDIO_OUT_R_REG = AUDIO_IN_R_REG;

            // Enable interrupt again
            write(audioInFd, &IRQEnable, sizeof(IRQEnable));
        }
/*  
        //if you direct stdio into correct file, this printf will be written into printk, and will get time-stamp on message
        printf("DEBUG_USERSPACE : IRQ\n");
  
        //when you read from file into this buffer, it will give you total number of interrupts, 
        printf("Interrupt count: = %d \n", IRQEnable);
  
        //Read and print result of IP calculation
        unsigned ans = SLV_REG_3;0
        printf("READ: from offset of %d, a value of %d \n", 12, ans);
  
        //unmap
        munmap(ptr, pageSize);
  
        //close
        fclose(stdout);*/
    return 0;
}
