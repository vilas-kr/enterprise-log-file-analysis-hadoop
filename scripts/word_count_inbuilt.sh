#!/bin/bash

# Phase 3: Distributed Processing Using Built-in MapReduce
# --------------------------------------------------------------------------------------------
# Task 4: Built-in WordCount Execution
# To validate distributed processing, run Hadoop’s built-in WordCount example on the log data 
# stored in HDFS.

# Requirements
# Input must be read from HDFS
# Output must be written to HDFS

# Analysis
# Identify the number of mapper tasks launched
# Explain the relationship between input blocks and mapper count
# Observe reducer execution and shuffle behavior
# --------------------------------------------------------------------------------------------

# Shell variables
INPUT_DIR=/small-log-file-analytics/input
OUTPUT_DIR=/small-log-file-analytics/output

echo "Word count uisng built-in map reducer shell script started..."

# Step 1: Clear old data
echo "Removing old output directory if exists..."
hdfs dfs -rm -r -f $OUTPUT_DIR

# Step 2: Run world count 
echo "Running Hadoop WordCount job..."
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
wordcount \
$INPUT_DIR \
$OUTPUT_DIR

# Step 3: Listing word count output files
echo "Listing word count output files"
hdfs dfs -ls $OUTPUT_DIR

# Step 4: Checking the sample output
echo "Displaying sample output:"
hdfs dfs -cat $OUTPUT_DIR/part-r-00000 | head -20

echo "Word Count job complted successfully"

# Analysis: 
# 1. Identify the number of mapper tasks launched
# Number of mapper tasks launched is equal to the number of blocks created
echo "Number of blocks created are: "
hdfs fsck $INPUT_DIR -files -blocks | grep "Total blocks"

# 2. Explain the relationship between input blocks and mapper count
# In Hadoop each input split is processed by one mapper. By default, input split size equals 
# the HDFS block size. Therefore, the number of HDFS blocks determines the number of mappers. 
# More blocks result in more mappers and higher parallelism, but too many small blocks can 
# increase overhead.

# 3. Observe reducer execution and shuffle behavior
# During the shuffle phase, Map outputs are transferred and grouped by key across the cluster
# and the reducer executes by aggregating all values for each key to produce the final output.