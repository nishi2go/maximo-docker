"""
   Copyright Yasutaka Nishimura 2017

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
"""

import sys


def load_wsadminlib(filename='/opt/wsadminlib.py'):
    global createWebserver, generatePluginCfg, saveAndSyncAndPrintResult
    with open(filename) as in_file:
        exec(in_file.read())


load_wsadminlib()
nodeName, webServerName, webServerPort, httpServerHome, webspherePluginHome = sys.argv[:5]

createWebserver(webServerName, nodeName, webServerPort, httpServerHome, webspherePluginHome,
    httpServerHome + '/conf/httpd.conf', 'ALL', '8008', 'admin', 'password')
saveAndSyncAndPrintResult()

generatePluginCfg(webServerName, nodeName)
saveAndSyncAndPrintResult()
