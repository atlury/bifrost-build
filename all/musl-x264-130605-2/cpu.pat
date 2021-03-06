--- common/cpu.c.orig	Wed Jun  5 20:48:22 2013
+++ common/cpu.c	Wed Jun  5 20:49:41 2013
@@ -417,51 +417,32 @@
 
 #endif
 
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
 int x264_cpu_num_processors( void )
 {
-#if !HAVE_THREAD
-    return 1;
-
-#elif SYS_WINDOWS
-    return x264_pthread_num_processors_np();
-
-#elif SYS_CYGWIN || SYS_SunOS
-    return sysconf( _SC_NPROCESSORS_ONLN );
-
-#elif SYS_LINUX
-    cpu_set_t p_aff;
-    memset( &p_aff, 0, sizeof(p_aff) );
-    if( sched_getaffinity( 0, sizeof(p_aff), &p_aff ) )
-        return 1;
-#if HAVE_CPU_COUNT
-    return CPU_COUNT(&p_aff);
-#else
-    int np = 0;
-    for( unsigned int bit = 0; bit < 8 * sizeof(p_aff); bit++ )
-        np += (((uint8_t *)&p_aff)[bit / 8] >> (bit % 8)) & 1;
-    return np;
-#endif
-
-#elif SYS_BEOS
-    system_info info;
-    get_system_info( &info );
-    return info.cpu_count;
-
-#elif SYS_MACOSX || SYS_FREEBSD || SYS_OPENBSD
-    int ncpu;
-    size_t length = sizeof( ncpu );
-#if SYS_OPENBSD
-    int mib[2] = { CTL_HW, HW_NCPU };
-    if( sysctl(mib, 2, &ncpu, &length, NULL, 0) )
-#else
-    if( sysctlbyname("hw.ncpu", &ncpu, &length, NULL, 0) )
-#endif
-    {
-        ncpu = 1;
-    }
-    return ncpu;
-
-#else
-    return 1;
-#endif
+	int fd, n;
+	char buf[16], *p;
+	
+	fd = open("/sys/devices/system/cpu/online", O_RDONLY);
+	if(fd == -1) return 1;
+	n = read(fd, buf, sizeof(buf)-1);
+	if(n < 1 ) {
+		close(fd);
+		return 1;
+	}
+	
+	close(fd);
+	buf[n] = 0;
+	p = strchr(buf, '-');
+	if(!p) {
+		/* single CPU system */
+		return 1;
+	}
+	
+	n = atoi(p+1);
+	n++;
+	
+	return n;
 }
