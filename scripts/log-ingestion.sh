#!/bin/bash

# Phase 2: Log Ingestion and HDFS Block Analysis
# --------------------------------------------------------------------------------------------
# Task 2: Small Log File Storage

# You are provided with a small access log file containing the given log structure.

# Actions :
# Upload the file to HDFS
# Identify how many HDFS blocks are created
# Analyze block allocation behavior for small files

# Expected Analysis :
# Explain why the observed number of blocks is created
# Discuss inefficiencies related to small files in HDFS
# --------------------------------------------------------------------------------------------

echo "Small Log File Storage and Analysis"

# Shell variables
S_INPUT_DIR=/small-log-file-analytics/input
S_LOCAL_LOG_FILE=downloads/logfiles.log

# Step 1: Create a directory in HDFS
echo "Creating HDFS input directory..."
hdfs dfs -mkdir -p $S_INPUT_DIR

# Step 2: Listing all the directories in the HDFS
echo "List of all directories in the HDFS"
hdfs dfs -ls /

# Step 3: Upload the file to HDFS
echo "Uploading the file to HDFS"
hdfs dfs -put $S_LOCAL_LOG_FILE $S_INPUT_DIR

# Step 4: Check the uploaded file
echo "Verify upload file..."
hdfs dfs -ls -h $S_INPUT_DIR

# Step 5: Analyse HDFS blocks
echo "Running HDFS FSCK (block analysis)..."
hdfs fsck $S_INPUT_DIR/logfiles.log -files -blocks

# Step 6: Number of blocks created
echo "Number of blocks created are: "
hdfs fsck $S_INPUT_DIR -files -blocks | grep "Total blocks"

echo "Small log file execution and Analysis completed"

# 1. Explain why the observed number of blocks is created
# The default HDFS block size is 128 MB. Since the given file size is 234 MB, 
# it cannot fit into a single block. Therefore, two blocks are created 
# the first block stores 128 MB of data, and the remaining 106 MB is stored in the second block 

# 2. Discuss inefficiencies related to small files in HDFS
# Small files in HDFS cause inefficiency because HDFS is designed for large files.
# Many small files increase NameNode memory usage, waste block storage, 
# create more disk seeks, slow processing jobs, and add network and replication overhead.
# so small files should be combined into larger files before storing in HDFS.



# ----------------------------------------------------------------------------------------------
# Task 3: Large Log File Scalability Test

# The system starts aggregating logs from multiple services, resulting in a 
# large log file (1 GB or more).

# Actions
# Generate or simulate a large log file using the same log structure
# Upload the file to HDFS
# Verify that the file is split into multiple blocks

# Constraints
# HDFS block size must be configured to 128 MB

# Expected Analysis
# Determine the number of blocks created
# Explain how block size impacts parallelism, storage, and fault tolerance
# ---------------------------------------------------------------------------------------------

echo "Large Log File Storage and Analysis"

# Shell variables
L_INPUT_DIR=/large-log-file-analytics/input
L_LOCAL_LOG_FILE=downloads/access.log

# Step 1: Create a directory in HDFS
echo "Creating HDFS input directory..."
hdfs dfs -mkdir -p $L_INPUT_DIR

# Step 2: Listing all the directories in the HDFS
echo "List of all directories in the HDFS"
hdfs dfs -ls /

# Step 3: Upload the file to HDFS
echo "Uploading the file to HDFS and Set Block size to 128 MB"
hdfs dfs -D dfs.blocksize=134217728 -put $L_LOCAL_LOG_FILE $L_INPUT_DIR

# Step 4: Check the uploaded file
echo "Verify upload file..."
hdfs dfs -ls -h $L_INPUT_DIR

# Step 5: Analyse HDFS blocks
echo "Running HDFS FSCK (block analysis)..."
hdfs fsck $L_INPUT_DIR/access.log -files -blocks

# Step 6: Number of blocks created
echo "Number of blocks created are: "
hdfs fsck $L_INPUT_DIR -files -blocks | grep "Total blocks"

echo "Large log file execution and Analysis completed"















