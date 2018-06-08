# (C) 2012, Michael DeHaan, <michael.dehaan@gmail.com>

# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# Make coding more python3-ish
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import time
import json
import httplib
from collections import MutableMapping

from ansible.module_utils._text import to_bytes
from ansible.plugins.callback import CallbackBase


# NOTE: in Ansible 1.2 or later general logging is available without
# this plugin, just set ANSIBLE_LOG_PATH as an environment variable
# or log_path in the DEFAULTS section of your ansible configuration
# file.  This callback is an example of per hosts logging for those
# that want it.


class CallbackModule(CallbackBase):
    """
    logs playbook results, per host, in /var/log/ansible/hosts
    """
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'log_plays'
    CALLBACK_NEEDS_WHITELIST = True

    TIME_FORMAT = "%b %d %Y %H:%M:%S"
    MSG_FORMAT = "%(now)s - %(category)s - %(data)s\n\n"

    def __init__(self):
        super(CallbackModule, self).__init__()
        
        self.task = dict()
        self.data = dict()
        self.stage = ""

    def log(self, host, category, data):
        state = "processing"
        if isinstance(data, MutableMapping):
            if "state" in data.keys():
                state = data["state"]

            if "changed" in data.keys():
                self.data["changed"] = data["changed"]
            else:
                self.data["changed"] = False
                
            if "msg" in data.keys():
                self.data["msg"] = data["msg"]
            else:
                self.data["msg"] = ""

        now = time.strftime(self.TIME_FORMAT, time.localtime())
        self.task["state"] = category
        
        h1 = httplib.HTTPConnection('127.0.0.1:8080')
        h1.request(
            "POST", 
            "/v1/notify",
            json.dumps(
                dict(
                    time=now, 
                    data=self.data, 
                    task=self.task, 
                    host=host, 
                    state=state,
                    stage=self.stage
                )
            )
        )

    def runner_on_failed(self, host, res, ignore_errors=False):
        self.log(host, 'failed', res)

    def runner_on_ok(self, host, res):
        self.log(host, 'ok', res)

    def runner_on_skipped(self, host, item=None):
        self.log(host, 'skipped', '...')

    def runner_on_unreachable(self, host, res):
        self.log(host, 'unreachable', res)

    def runner_on_async_failed(self, host, res, jid):
        self.log(host, 'ASYNC_FAILED', res)

    def v2_playbook_on_start(self, playbook):
        name, suffix = os.path.basename(os.path.dirname(playbook._basedir)).split('-')
        self.stage = name

    def playbook_on_import_for_host(self, host, imported_file):
        self.log(host, 'IMPORTED', imported_file)

    def playbook_on_not_import_for_host(self, host, missing_file):
        self.log(host, 'NOTIMPORTED', missing_file)

    def playbook_on_task_start(self, name, is_conditional):
        self.task['name'] = name

    def playbook_on_stats(self, stats):
        state = ""
        if len(stats.failures) > 0 or len(stats.dark) > 0:
            state = "failed"
        else:
            state = "ok"
        self.task['name'] = "ending"
        self.log("all", state, dict(state=state))