// provides _syscall and message
#include <lib.h>
// provides function prototype
#include <unistd.h>   


int cubictables(int value) {

	// Minix message to pass parameters to a system call
    message m;      

    // set first integer of message to value
    m.m1_i1 = value;
    // select cubic tables
    m.m1_i2 = 1;
    m.m1_i3 = 1;

    // invoke underlying system call
    return _syscall(PM_PROC_NR, CALCTABLES, &m);
}
