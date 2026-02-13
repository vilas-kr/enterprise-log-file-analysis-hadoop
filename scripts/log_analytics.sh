#!/bin/bash

# Phase 5: Log-Specific Analytical Enhancements
# --------------------------------------------------------------------------------------------
# Task 6: Error-Focused Log Analysis
# Extend the MapReduce logic to analyze only error-related requests.

# Definition
# HTTP status codes greater than or equal to 400

# Expected Output
# Frequency of error status codes
# Frequency of error-generating endpoints

# Analysis
# Justify mapper and reducer design decisions
# Explain how filtering impacts job performance
# --------------------------------------------------------------------------------------------

# Shell variables
INPUT_DIR=/small-log-file-analytics/input
OUTPUT_DIR=/small-log-file-analytics/output

# Local script path
MAPPER=./streaming/log_analytics_mapper.py
REDUCER=./streaming/word_count_reducer.py

echo "Started log analytics..."

# Clear output folder if present
echo "Removing old HDFS output directory..."
hdfs dfs -rm -r -f $OUTPUT_DIR

# Run hadoop stream
echo "Running Hadoop Streaming job..."
hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
-files $MAPPER,$REDUCER \
-mapper 'python3 log_analytics_mapper.py' \
-reducer 'python3 word_count_reducer.py' \
-input $INPUT_DIR \
-output $OUTPUT_DIR

if [ $? -eq 0 ]; then
    echo "Hadoop streaming done"
else
    echo "Hadoop streaming failed"
    exit 1
fi

# Verify output
echo "--------------- Streaming job output ----------------"
hdfs dfs -cat $OUTPUT_DIR/part-00000

echo "Hadoop Streaming job completed successfully."

# Analysis
# 1. Justify mapper and reducer design decisions
# Mapper:
# The mapper uses a regular expression to parse web server logs and extract relevant fields 
# such as HTTP status code and endpoint. It filters only error responses (status code ≥ 400) 
# to focus on failure analysis. For each valid record, it emits tab-separated key-value pairs 
# (status code → 1 and endpoint → 1) to enable frequency counting.

# Reducer:
# The reducer aggregates mapper outputs by summing counts for identical keys. Since MapReduce 
# sorts keys before reduction, sequential aggregation ensures efficient memory usage and 
# scalability. The final output provides total occurrences of each error status code and 
# problematic endpoints

# 2. Explain how filtering impacts job performance
# Filtering improves job performance in Apache Hadoop by reducing unnecessary data processing. 
# It lowers computation time, decreases network data transfer between mapper and reducer, and 
# reduces memory usage. As a result, the MapReduce job runs faster and more efficiently