#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MAXDB=$1
BACKUPDIR=$2

su - ctginst1 <<- EOS
  db2 CONNECT TO $MAXDB
  db2 QUIESCE DATABASE IMMEDIATE FORCE CONNECTIONS
  db2 CONNECT RESET
  db2 BACKUP DATABASE $MAXDB TO $BACKUPDIR WITH 4 BUFFERS BUFFER 2048 PARALLELISM 2 COMPRESS WITHOUT PROMPTING
  db2 CONNECT TO $MAXDB
  db2 UNQUIESCE DATABASE
  db2 CONNECT RESET
EOS
