#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include <sys/stat.h>

#define CRIU "/usr/sbin/criu"

/* pid passed as string from command line */
uid_t uid_from_pid(char *pid)
{
   char *proc_entry; /* program doesn't use enough to care about leakage */
   struct stat info;
   long l_pid;

   return((((l_pid=strtol(pid,&proc_entry,10))>0) &&
      asprintf(&proc_entry,"/proc/%ld",l_pid)>0 &&
         stat(proc_entry,&info)==0)?info.st_uid:-1);
}

int main(int argc,char *argv[])
{
   uid_t uid,my_uid;

   switch(argc)
      {
      case 2:
         /* execl(CRIU,CRIU,argv[1],"--shell-job","--restore-detached","--restore-sibling","-vvvv","--log-file","debug.log",(char *)NULL); */            
	 execl(CRIU,CRIU,argv[1],"--shell-job","--restore-detached","--restore-sibling",(char *)NULL);
         fprintf(stderr,"Error: failed to exec %s!\n",CRIU);
         break;
      case 3:
         if ((uid=uid_from_pid(argv[2]))<0)
            fprintf(stderr,"Error: pid either invalid or no longer running\n");
         else
            {
            if (uid!=(my_uid=getuid()))
               fprintf(stderr,"uid %d not allowed, pid %s owned by uid %d\n",
                  my_uid,argv[2],uid);
            else
               {
               execl(CRIU,CRIU,argv[1],"--shell-job","-t",argv[2],(char *)NULL);
               fprintf(stderr,"Error: failed to exec %s!\n",CRIU);
               }
            }
         break;
      default:
         fprintf(stderr,"Usage: %s <criu operation> [pid]\n",argv[0]);
      }
}
