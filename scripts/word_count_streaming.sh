#!/bin/bash

# Phase 4: Custom MapReduce Implementation Using Python

# --------------------------------------------------------------------------------------------
# Task 5: Python WordCount Using Hadoop Streaming
# The engineering team prefers Python for rapid development and flexibility.

# Actions
# Implement a WordCount MapReduce job using Python
# Ensure compatibility with Hadoop Streaming
# Execute the job on the same HDFS input data

# Comparison
# Compare the Python implementation with the built-in WordCount job
# Discuss differences in performance, flexibility, and execution overhead
# --------------------------------------------------------------------------------------------

# Shell variables
INPUT_DIR=/small-log-file-analytics/input
OUTPUT_DIR=/small-log-file-analytics/output

# Local script path
MAPPER=./streams/word_count_mapper.py
REDUCER=./streams/word_count_reducer.py

# Cleat output directory
echo "Removing old HDFS output directory..."
hdfs dfs -rm -r -f $OUTPUT_DIR

# Run hadoop streaming job
echo "Running Hadoop Streaming job..."

hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
-files $MAPPER,$REDUCER \
-mapper 'python3 word_count_mapper.py' \
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
echo "Streaming job output (first 20 lines):"
hdfs dfs -cat $OUTPUT_DIR/part-00000 | head -20

echo "Hadoop Streaming job completed successfully."

# performance comparison
# Python Hadoop Streaming has higher execution overhead because it runs mapper and reducer 
# as external processes, unlike built-in Java MapReduce which runs inside the JVM.

# Flexibilty comparison
# The Python WordCount implementation using Hadoop Streaming is more flexible than the built-in 
# WordCount because it allows easy modification and rapid development without recompiling Java code.

# Execution Overhead comparison
# The built-in word count has lower execution overhead because it won't create new processes whereas 
# the python streaming has more overhead.
