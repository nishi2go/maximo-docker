"""
   Copyright Yasutaka Nishimura 2017, 2019

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


def load_wsadminlib(filename='/opt/wsadminlib.py'):
    global enableDebugMessages, getObjectsOfType, getServerId, listAllAppServers, save
    global setObjectAttributes, sop
    with open(filename) as in_file:
        exec(in_file.read())


def setServerAutoRestart(nodename, servername, autorestart, state):
    """Sets whether the nodeagent will automatically restart a failed server.

    Specify autorestart='true' or 'false' (as a string)"""
    m = "setServerAutoRestart:"
    sop(m, "Entry. nodename=%s servername=%s autorestart=%s" % (nodename, servername, autorestart))
    if autorestart not in ("true", "false"):
        raise Exception(m + " Invocation Error: autorestart must be 'true' or 'false'. autorestart=%s" % (autorestart))
    server_id = getServerId(nodename, servername)
    if server_id is None:
        raise Exception(" Error: Could not find server. servername=%s nodename=%s" % (nodename, servername))
    sop(m, "server_id=%s" % server_id)
    monitors = getObjectsOfType('MonitoringPolicy', server_id)
    sop(m, "monitors=%s" % (repr(monitors)))
    if len(monitors) == 1:
        setObjectAttributes(monitors[0], autoRestart="%s" % (autorestart))
        setObjectAttributes(monitors[0], nodeRestartState="%s" % (state))
    else:
        raise Exception(m + "ERROR Server has an unexpected number of monitor object(s). monitors=%s" % (repr(monitors)))
    sop(m, "Exit.")


# Try execfile first for Jython
filename = '/opt/wsadminlib.py'
try:
    execfile(filename)
except NameError:
    load_wsadminlib()

enableDebugMessages()
for (nodename, servername) in listAllAppServers():
    setServerAutoRestart(nodename, servername, 'true', 'RUNNING')
save()
