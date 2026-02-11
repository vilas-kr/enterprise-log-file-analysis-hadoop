#!/bin/bash

echo "========== HADOOP FULL SETUP STARTED =========="

# 1. CHECK & INSTALL JAVA (8 or 11)
echo "Checking Java..."

if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "Java already installed: $JAVA_VERSION"
else
    echo "Java not found. Installing Java 8..."
    sudo apt update -y
    sudo apt install openjdk-8-jdk -y
fi

# 2. SET JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    JAVA_HOME_PATH=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    echo "Setting JAVA_HOME=$JAVA_HOME_PATH"
    echo "export JAVA_HOME=$JAVA_HOME_PATH" >> ~/.bashrc
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc
else
    echo "JAVA_HOME already set"
fi

source ~/.bashrc

# 3. CHECK & INSTALL HADOOP
echo "Checking Hadoop..."

if command -v hadoop >/dev/null 2>&1; then
    echo "Hadoop already installed"
    hadoop version | head -n 1
else
    echo "Hadoop not found. Installing Hadoop 3.3.6..."

    cd ~
    wget -q https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    tar -xzf hadoop-3.3.6.tar.gz
    mv hadoop-3.3.6 hadoop
fi

# 4. SET HADOOP_HOME
if [ -z "$HADOOP_HOME" ]; then
    echo "Setting HADOOP_HOME"
    echo "export HADOOP_HOME=\$HOME/hadoop" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> ~/.bashrc
else
    echo "HADOOP_HOME already set"
fi
source ~/.bashrc

# 5. CONFIGURE hadoop-env.sh
echo "Configuring hadoop-env.sh..."

sed -i "s|^.*JAVA_HOME.*|export JAVA_HOME=$JAVA_HOME|" \
$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# 6. CREATE HDFS DIRECTORIES
echo "Creating HDFS directories..."

mkdir -p ~/hadoopdata/hdfs/namenode
mkdir -p ~/hadoopdata/hdfs/datanode

# 7. CONFIGURE core-site.xml
echo "Configuring core-site.xml..."

cat <<EOF > $HADOOP_HOME/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

# 8. CONFIGURE hdfs-site.xml
echo "Configuring hdfs-site.xml..."

cat <<EOF > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>

  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:/home/$USER/hadoopdata/hdfs/namenode</value>
  </property>

  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/home/$USER/hadoopdata/hdfs/datanode</value>
  </property>
</configuration>
EOF

# 9. CONFIGURE mapred-site.xml
echo "Configuring mapred-site.xml..."

cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
   $HADOOP_HOME/etc/hadoop/mapred-site.xml

cat <<EOF > $HADOOP_HOME/etc/hadoop/mapred-site.xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
EOF

# 10. CONFIGURE yarn-site.xml
echo "Configuring yarn-site.xml..."

cat <<EOF > $HADOOP_HOME/etc/hadoop/yarn-site.xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF

# 11. FORMAT NAMENODE (ONLY IF NOT FORMATTED)
echo "Checking NameNode format..."

if [ ! -d ~/hadoopdata/hdfs/namenode/current ]; then
    echo "Formatting NameNode..."
    hdfs namenode -format -force
else
    echo "NameNode already formatted"
fi

echo "========== HADOOP FULL SETUP COMPLETED =========="