#!/bin/bash

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

# Log file
LOG_FILE="/var/log/system_health.log"

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        log_message "ALERT: CPU usage is at ${cpu_usage}% (Threshold: ${CPU_THRESHOLD}%)"
    else
        log_message "CPU usage is normal at ${cpu_usage}%"
    fi
}

# Function to check memory usage
check_memory() {
    local mem_total=$(free -m | awk '/Mem:/ {print $2}')
    local mem_used=$(free -m | awk '/Mem:/ {print $3}')
    local mem_percent=$((100 * mem_used / mem_total))
    if [ "$mem_percent" -gt "$MEM_THRESHOLD" ]; then
        log_message "ALERT: Memory usage is at ${mem_percent}% (Threshold: ${MEM_THRESHOLD}%)"
    else
        log_message "Memory usage is normal at ${mem_percent}%"
    fi
}

# Function to check disk space
check_disk() {
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | cut -d% -f1)
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        log_message "ALERT: Disk usage is at ${disk_usage}% (Threshold: ${DISK_THRESHOLD}%)"
    else
        log_message "Disk usage is normal at ${disk_usage}%"
    fi
}

# Function to check running processes
check_processes() {
    local process_count=$(ps -e | wc -l)
    log_message "Number of running processes: ${process_count}"
    # List top 5 processes by CPU usage
    log_message "Top 5 CPU-consuming processes:"
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6 | tail -n 5 | while read -r line; do
        log_message "$line"
    done
}

# Main execution
log_message "Starting system health check..."

check_cpu
check_memory
check_disk
check_processes

log_message "System health check completed."
