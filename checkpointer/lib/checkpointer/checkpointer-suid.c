#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include <sys/stat.h>

#define CRIU "/usr/sbin/criu"

#define ERR_GENER 1001
#define ERR_EXIST 1002
#define ERR_ALLOW 1003

/* pid passed as string from command line and yes, asprintf is correct */
uid_t uid_from_pid(char *pid)
{
   char *proc_entry; /* program doesn't use enough to care about leakage */
   struct stat info;
   long l_pid;

   return((((l_pid=strtol(pid,&proc_entry,10))>0) &&
      asprintf(&proc_entry,"/proc/%ld",l_pid)>0 &&
         stat(proc_entry,&info)==0)?info.st_uid:-1);
}

void exec_criu(char *op,char *pid)
{
   if (pid)
      execl(CRIU,CRIU,op,"--shell-job","--leave-stopped","-t",pid,(char *)NULL);
   else
      execl(CRIU,CRIU,op,"--shell-job","--restore-detached",
         "--restore-sibling",(char *)NULL);

   fprintf(stderr,"Error: failed to exec %s!\n",CRIU);
}

int main(int argc,char *argv[])
{
   int status=ERR_GENER; /* default to generic error */
   uid_t uid,my_uid;

   switch(argc)
      {
      case 2:
         exec_criu(argv[1],NULL);
         break;
      case 3:
         if ((uid=uid_from_pid(argv[2]))<0)
            {
            fprintf(stderr,"Error: pid either invalid or no longer running\n");
            status=ERR_EXIST;
            }
         else
            {
            if (uid!=(my_uid=getuid()))
               {
               fprintf(stderr,"uid %d not allowed, pid %s owned by uid %d\n",
                  my_uid,argv[2],uid);
               status=ERR_ALLOW;
               }
            else
               exec_criu(argv[1],argv[2]);
            }
         break;
      default:
         fprintf(stderr,"Usage: %s <criu operation> [pid]\n",argv[0]);
      }

   return(status);
}
