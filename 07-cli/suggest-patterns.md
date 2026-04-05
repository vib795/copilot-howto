# `gh copilot suggest` Practical Patterns

A collection of real-world examples organized by category. For each, the natural language prompt is shown followed by a representative suggested command.

Run any of these yourself with:
```bash
gh copilot suggest "your prompt here"
```

---

## File Operations

### Compress a directory into tar.gz

```bash
gh copilot suggest "compress the logs directory into a gzipped tarball named logs-backup.tar.gz"
# → tar -czf logs-backup.tar.gz logs/
```

### Find large files

```bash
gh copilot suggest "find all files larger than 100MB in the current directory tree"
# → find . -type f -size +100M -exec ls -lh {} \;

gh copilot suggest "find the 10 largest files in /var/log, show sizes in human-readable format"
# → find /var/log -type f -exec du -h {} + | sort -rh | head -10
```

### Batch rename files

```bash
gh copilot suggest "rename all .jpeg files in the current directory to .jpg"
# → for f in *.jpeg; do mv "$f" "${f%.jpeg}.jpg"; done

gh copilot suggest "add a timestamp prefix to all .log files in the logs directory"
# → for f in logs/*.log; do mv "$f" "logs/$(date +%Y%m%d)_$(basename $f)"; done
```

### Find and delete old files

```bash
gh copilot suggest "delete all .tmp files in /tmp that are older than 7 days"
# → find /tmp -name "*.tmp" -mtime +7 -delete

gh copilot suggest "find all node_modules directories and show their combined disk usage"
# → find . -name "node_modules" -type d -prune -exec du -sh {} \; | sort -rh
```

### Sync directories

```bash
gh copilot suggest "sync the src directory to a remote server, preserving permissions, excluding .git"
# → rsync -avz --delete --exclude='.git' src/ user@server:/path/to/dest/

gh copilot suggest "mirror the local dist folder to an S3 bucket and delete files not in local"
# → aws s3 sync dist/ s3://my-bucket/dist/ --delete
```

---

## Git

### Complex rebases

```bash
gh copilot suggest "interactively rebase the last 5 commits"
# → git rebase -i HEAD~5

gh copilot suggest "rebase my feature branch onto main and auto-squash fixup commits"
# → git rebase --autosquash main

gh copilot suggest "continue a rebase after resolving merge conflicts"
# → git add . && git rebase --continue
```

### Finding commits by content

```bash
gh copilot suggest "find all commits that changed a specific string in the code"
# → git log -S "your_string" --all --oneline

gh copilot suggest "find which commit introduced the function getUserById"
# → git log -S "getUserById" --oneline --pickaxe-regex

gh copilot suggest "show all commits that touched a specific file, including renames"
# → git log --follow --all --oneline -- path/to/file
```

### Cleaning up branches

```bash
gh copilot suggest "delete all local git branches that have been merged to main"
# → git branch --merged main | grep -v '^\*\|main\|master' | xargs git branch -d

gh copilot suggest "delete all remote tracking branches that no longer exist on the remote"
# → git remote prune origin

gh copilot suggest "list all branches sorted by most recent commit date"
# → git branch --sort=-committerdate --format='%(committerdate:short) %(refname:short)'
```

### Other useful git operations

```bash
gh copilot suggest "show a compact graph of all branches and their commits"
# → git log --oneline --graph --decorate --all

gh copilot suggest "find the commit where a specific file was deleted"
# → git log --all --full-history -- path/to/deleted/file

gh copilot suggest "cherry-pick a range of commits from another branch"
# → git cherry-pick abc123..def456

gh copilot suggest "create an alias for 'git log --oneline --graph'"
# → git config --global alias.lg "log --oneline --graph --decorate --all"
```

---

## Networking

### curl with authentication

```bash
gh copilot suggest "make a curl POST request with JSON body and Bearer token authentication"
# → curl -X POST https://api.example.com/endpoint \
#     -H "Authorization: Bearer your_token" \
#     -H "Content-Type: application/json" \
#     -d '{"key": "value"}'

gh copilot suggest "curl a URL, follow redirects, show response headers, save body to file"
# → curl -L -D headers.txt -o response.txt https://example.com

gh copilot suggest "make a curl request with Basic Auth and show only the HTTP status code"
# → curl -s -o /dev/null -w "%{http_code}" -u username:password https://api.example.com
```

### wget with rate limiting

```bash
gh copilot suggest "download a file with wget, limit bandwidth to 1MB/s, retry 3 times on failure"
# → wget --limit-rate=1m --tries=3 https://example.com/large-file.zip

gh copilot suggest "mirror a website with wget for offline browsing"
# → wget --mirror --convert-links --adjust-extension --page-requisites --no-parent https://example.com
```

### Port and network diagnostics

```bash
gh copilot suggest "show which process is listening on port 8080"
# → lsof -i TCP:8080 | grep LISTEN
# → (on Linux): ss -tlnp | grep :8080

gh copilot suggest "test if a TCP port is open on a remote host"
# → nc -zv hostname 443

gh copilot suggest "show all open network connections with process names"
# → netstat -tulnp  # Linux
# → lsof -i -P -n  # macOS
```

---

## Process Management

### Find and kill processes

```bash
gh copilot suggest "find and kill all processes matching the name 'node'"
# → pkill -f node
# or: kill $(pgrep -f node)

gh copilot suggest "kill the process using port 3000"
# → kill $(lsof -t -i:3000)
# or (safer, asks for confirmation): lsof -i :3000

gh copilot suggest "gracefully stop then force-kill a process by name if it doesn't stop"
# → pkill -SIGTERM node && sleep 5 && pkill -SIGKILL node 2>/dev/null; true
```

### Memory and CPU monitoring

```bash
gh copilot suggest "show the top 5 processes by memory usage"
# → ps aux --sort=-%mem | head -6

gh copilot suggest "monitor memory usage of a process by PID every 2 seconds"
# → watch -n 2 'ps -o pid,rss,vsz,pcpu,pmem,cmd -p 12345'

gh copilot suggest "show total memory usage of all node processes"
# → ps aux | grep node | awk '{sum += $6} END {print sum/1024 " MB"}'
```

---

## Docker

### Container management

```bash
gh copilot suggest "list all running docker containers with their port mappings"
# → docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"

gh copilot suggest "exec a bash shell into a running container named web"
# → docker exec -it web bash

gh copilot suggest "show logs for a container named api, follow in real time, last 100 lines"
# → docker logs -f --tail=100 api

gh copilot suggest "stop and remove all running containers"
# → docker stop $(docker ps -q) && docker rm $(docker ps -aq)
```

### Image cleanup

```bash
gh copilot suggest "remove all stopped containers, unused images, volumes, and networks"
# → docker system prune -a --volumes

gh copilot suggest "remove all docker images that are not tagged"
# → docker image prune --filter "dangling=true"

gh copilot suggest "show the size of each docker image sorted by size"
# → docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -rh
```

### Docker Compose

```bash
gh copilot suggest "start docker compose services in detached mode and follow logs"
# → docker compose up -d && docker compose logs -f

gh copilot suggest "rebuild a specific service in docker compose without affecting others"
# → docker compose up -d --no-deps --build web

gh copilot suggest "show the resource usage of all docker compose services"
# → docker stats $(docker compose ps -q)
```

---

## Text Processing

### grep pipelines

```bash
gh copilot suggest "find all TODO comments in Python files, show file name and line number"
# → grep -rn "TODO" --include="*.py" .

gh copilot suggest "count occurrences of each HTTP status code in a web server access log"
# → awk '{print $9}' access.log | sort | uniq -c | sort -rn

gh copilot suggest "find lines matching a pattern in multiple gzipped log files"
# → zgrep "ERROR" /var/log/app/*.gz
```

### awk pipelines

```bash
gh copilot suggest "sum the values in the third column of a CSV file"
# → awk -F',' '{sum += $3} END {print sum}' data.csv

gh copilot suggest "print lines where the second column is greater than 100"
# → awk '$2 > 100' data.txt

gh copilot suggest "print unique values from the first column of a file, sorted"
# → awk '{print $1}' file.txt | sort -u
```

### sed operations

```bash
gh copilot suggest "replace all occurrences of 'foo' with 'bar' in all .js files in place"
# → sed -i 's/foo/bar/g' *.js
# (on macOS, sed requires a backup extension: sed -i '' 's/foo/bar/g' *.js)

gh copilot suggest "remove all blank lines from a file"
# → sed '/^[[:space:]]*$/d' input.txt > output.txt
```

---

## Tips for Better Results

### Be Specific About the OS

Some commands differ between macOS and Linux (especially `sed`, `find`, `date`):

```bash
# Vague (Copilot may guess):
gh copilot suggest "show disk usage of each directory"

# Better — specify OS:
gh copilot suggest "on macOS, show disk usage of each directory in /Users in human-readable format"
gh copilot suggest "on Ubuntu Linux, show disk usage of each directory under /var"
```

### Specify "Safe for Production" if Needed

```bash
# Might generate a destructive command:
gh copilot suggest "clean up old docker images"

# Safer — specify the constraint:
gh copilot suggest "clean up old docker images but only dry-run first, do not delete anything"
# → docker image prune --dry-run --filter "until=720h"
```

### Mention Output Format Preferences

```bash
gh copilot suggest "list all running processes as JSON"
# → ps aux | python3 -c "import sys, json; ..."

gh copilot suggest "list all environment variables sorted alphabetically, one per line"
# → env | sort
```

### Use Revise for Iteration

After getting a suggestion, choose "Revise command" and add constraints:
- "Make it case-insensitive"
- "Add verbose output"
- "Make it work on macOS, not Linux"
- "Exclude hidden directories"
- "Pipe the output to less"
