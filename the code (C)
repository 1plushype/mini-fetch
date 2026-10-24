#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/utsname.h>
#include <sys/sysinfo.h>

static const char *logo[] = {
    "      /\\       ",
    "     /  \\      ",
    "    /    \\     ",
    "   /      \\    ",
    "  /        \\   ",
    " /   |''|   \\  ",
    "/_-''    ''-_\\ ",
};

const char* get_terminal_env(void) {
    // We checken nu alleen variabelen die ECHT de naam bevatten
    const char* terms[] = {"TERM_PROGRAM", "TERMINAL"};
    for (int i = 0; i < 2; i++) {
        const char* val = getenv(terms[i]);
        if (val) return val;
    }
    return NULL;
}

void get_terminal_name(char* buffer, size_t max_len) {
    const char* env_term = get_terminal_env();
    if (env_term) {
        strncpy(buffer, env_term, max_len);
        return;
    }

    pid_t shell_pid = getppid(); 
    char path[64];
    snprintf(path, sizeof(path), "/proc/%d/status", shell_pid);
    FILE* fp = fopen(path, "r");
    if (!fp) {
        strncpy(buffer, "Unknown", max_len);
        return;
    }

    pid_t terminal_pid = 0;
    char line[256];
    while (fgets(line, sizeof(line), fp)) {
        if (strncmp(line, "PPid:", 5) == 0) {
            terminal_pid = atoi(line + 5);
            break;
        }
    }
    fclose(fp);

    snprintf(path, sizeof(path), "/proc/%d/cmdline", terminal_pid);
    fp = fopen(path, "r");
    if (fp) {
        if (fgets(line, sizeof(line), fp)) {
            char* token = strrchr(line, '/');
            if (token) {
                strncpy(buffer, token + 1, max_len);
            } else {
                strncpy(buffer, line, max_len);
            }
            fclose(fp);
            return;
        }
        fclose(fp);
    }

    strncpy(buffer, "Unknown", max_len);
}

int main(void) {
    char os[128] = "Unknown";
    int is_arch = 0;
    FILE *f = fopen("/etc/os-release", "r");
    if (f) {
        char line[256];
        while (fgets(line, sizeof line, f)) {
            if (strncmp(line, "PRETTY_NAME=", 12) == 0)
                sscanf(line, "PRETTY_NAME=\"%127[^\"]\"", os);
            if ((strncmp(line, "ID=", 3) == 0 || strncmp(line, "ID_LIKE=", 8) == 0)
                && strstr(line, "arch"))
                is_arch = 1;
        }
        fclose(f);
    }
    if (!is_arch) {
        fprintf(stderr, "Alleen voor Arch-distros.\n");
        return 1;
    }

    struct utsname u;
    uname(&u);
    struct sysinfo si;
    sysinfo(&si);

    char host[64];
    gethostname(host, sizeof host);
    const char *user = getenv("USER");
    if (!user) user = "user";
    unsigned long total = si.totalram * si.mem_unit / (1024 * 1024);
    
    unsigned long avail_kb = 0;
    FILE *m = fopen("/proc/meminfo", "r");
    if (m) {
        char l[128];
        while (fgets(l, sizeof l, m)) {
            if (sscanf(l, "MemAvailable: %lu kB", &avail_kb) == 1)
                break;
        }
        fclose(m);
    }

    unsigned long used = total - avail_kb / 1024;
    char info[7][192] = {0};
    
    snprintf(info[0], sizeof info[0], "\033[1;36m%s\033[0m@\033[1;36m%s\033[0m", user, host);
    snprintf(info[1], sizeof info[1], "OS:       %s", os);
    snprintf(info[2], sizeof info[2], "Kernel:   %s", u.release);
    snprintf(info[3], sizeof info[3], "Uptime:   %ldh %ldm", si.uptime / 3600, (si.uptime % 3600) / 60);
    snprintf(info[4], sizeof info[4], "RAM:      %lu / %lu MiB", used, total);
    
    char term_name[64] = {0};
    get_terminal_name(term_name, sizeof(term_name));
    snprintf(info[5], sizeof info[5], "Terminal: %s", term_name);

    for (int i = 0; i < 7; i++)
        printf("\033[1;36m%s\033[0m  %s\n", logo[i], info[i]);

    return 0;
}
