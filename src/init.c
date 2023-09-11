#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sched.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "config.h"

#define ARRAY_SIZE(X) (sizeof(X) / sizeof(*(X)))
#define TIMEO 30

typedef struct {
	const char *chdir;
	char **argv;
	pid_t pid;
} Process;

typedef struct {
	int sig;
	void (*handler)(void);
} Sigmap;

static bool running;

static void sigreap(void) {
	while(waitpid(-1, NULL, WNOHANG) > 0);
	alarm(TIMEO);
}

static void sigexit(void) {
	running = false;
}

static Sigmap sigmap[] = {
	{ SIGALRM, sigreap },
	{ SIGCHLD, sigreap },
	{ SIGUSR1, sigexit },
	{ SIGINT, sigexit },
	{ SIGTERM, sigexit },
};

static Process processes[] = {
	{ .argv= (char*[]){ "/usr/sbin/lighttpd", "-f", "/etc/lighttpd/lighttpd.conf", "-D", NULL } },
	{ .argv= (char*[]){ "/usr/bin/mysqld", "--user=root", "--port=3306", "--bind-address=127.0.0.1", "--skip-networking=false", "--datadir=/var/lib/mysql", NULL } },
};

static int write_all(int fd, const char *src, size_t n) {
	while(n > 0) {
		ssize_t bytes = write(fd, src, n);
		if(bytes < 0)
			return -1;
		src += bytes;
		n -= bytes;
	}
	return 0;
}

int main(int argn, char **argv) {
	int ret;
	size_t idx;
	int fd;
	char buffer[65536];
	uid_t uid = geteuid();
	gid_t gid = getegid();
	int nullfd = open("/dev/null", O_WRONLY);
	sigset_t sigset;

	if(nullfd < 0) {
		fprintf(stderr, "error opening /dev/null\n");
		return 1;
	}

	ret = unshare(CLONE_NEWUSER);
	if(ret < 0) {
		fprintf(stderr, "error unsharing: %s\n", strerror(errno));
		return 1;
	}

	fd = open("/proc/self/uid_map", O_WRONLY);
	if(fd < 0) {
		fprintf(stderr, "error opening uid_map: %s\n", strerror(errno));
		return 1;
	}
	snprintf(buffer, sizeof(buffer), "0 %u 1", uid);
	if(write_all(fd, buffer, strlen(buffer)) < 0) {
		fprintf(stderr, "error setting uid mapping: %s\n", strerror(errno));
		return 1;
	}
	close(fd);

	fd = open("/proc/self/setgroups", O_WRONLY);
	if(fd < 0) {
		fprintf(stderr, "error opening setgroups: %s\n", strerror(errno));
		return 1;
	}
	if(write_all(fd, "deny", 4) < 0) {
		fprintf(stderr, "error denying setgroups: %s\n", strerror(errno));
		return 1;
	}
	close(fd);

	fd = open("/proc/self/gid_map", O_WRONLY);
	if(fd < 0) {
		fprintf(stderr, "error opening gid_map: %s\n", strerror(errno));
		return 1;
	}
	snprintf(buffer, sizeof(buffer), "0 %u 1", gid);
	if(write_all(fd, buffer, strlen(buffer)) < 0) {
		fprintf(stderr, "error setting gid mapping: %s\n", strerror(errno));
		return 1;
	}
	close(fd);

	ret = chdir(ROOT_DIR);
	if(ret < 0) {
		fprintf(stderr, "error changing to root directory: %s\n", strerror(errno));
		return 1;
	}

	ret = chroot(ROOT_DIR);
	if(ret < 0) {
		fprintf(stderr, "error chrooting: %s\n", strerror(errno));
		return 1;
	}

	for(idx = 0; idx < ARRAY_SIZE(processes); idx++) {
		Process *proc = processes + idx;
		pid_t pid = fork();
		if(pid < 0) {
			fprintf(stderr, "error forking: %s\n", strerror(errno));
			break;
		}
		else if(pid == 0) {
			if(proc->chdir != NULL) {
				ret = chdir(proc->chdir);
				if(ret < 0) {
					fprintf(stderr, "error changing working directory to '%s': %s\n", proc->chdir, strerror(errno));
					return 1;
				}
			}
			dup2(nullfd, STDOUT_FILENO);
			dup2(nullfd, STDERR_FILENO);
			ret = execve(proc->argv[0], proc->argv, NULL);
			if(ret < 0) {
				fprintf(stderr, "error executing %s: %s\n", proc->argv[0], strerror(errno));
				return 1;
			}
		}
		else
			proc->pid = pid;
		/*while(*argv != NULL) {
			printf("CHECK: %zu %s\n", i, *argv);
			argv++;
		}*/
	}
	close(nullfd);

	if(idx < ARRAY_SIZE(processes)) {
		//TODO join
		return 1;
	}

	for(size_t i = 0; i < ARRAY_SIZE(processes); i++) {
		Process *proc = processes + i;
		printf("started process %s with pid %d\n", proc->argv[0], proc->pid);
	}
	
	sigfillset(&sigset);
	sigprocmask(SIG_BLOCK, &sigset, NULL);
	for(running = true; running;) {
		int sig;
		alarm(TIMEO);
		sigwait(&sigset, &sig);
		for(size_t i = 0; i < ARRAY_SIZE(sigmap); i++) {
			if(sigmap[i].sig == sig) {
				sigmap[i].handler();
				break;
			}
		}
	}

	/*ret = system("/bin/bash");
	if(ret) {
		fprintf(stderr, "error executing shell: %s\n", strerror(errno));
	}*/

	for(size_t i = 0; i < ARRAY_SIZE(processes); i++) {
		Process *proc = processes + i;
		int status;
		printf("killing process %s...\n", proc->argv[0]);
		kill(proc->pid, SIGTERM);
		if(waitpid(proc->pid, &status, 0) < 0) {
			fprintf(stderr, "error killing: %s\n", strerror(errno));
		}
	}

	return 0;
}


