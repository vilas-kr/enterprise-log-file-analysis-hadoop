#!/usr/bin/env python3

import sys
import re

# Regex : IP, timestamp, http method, endpoint, http version, status code, response size, Referrer, User Agent, Response Time
log_pattern = re.compile(
    r'^(\d{1,3}(?:\.\d{1,3}){3}) - - \[([^\]]+)\] "(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS) ([^ ]+) (HTTP\/[0-9.]+)" (\d{3}) (\d+) "([^"]*)" "([^"]*)" (\d+)$'
)

for line in sys.stdin:
    
    match = log_pattern.match(line)
    if not match:
        continue
    
    code = int(match.group(6))
    if code >= 400:
        print(f'{code}\t1')
        print(f'{match.group(4)}\t1')
    
    

