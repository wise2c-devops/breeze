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
    logs playbook results, per host, to 127.0.0.1:8080
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

    # V2 METHODS, by default they call v1 counterparts if possible
    def v2_on_any(self, *args, **kwargs):
        self.on_any(args, kwargs)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        host = result._host.get_name()
        self.log(host, 'failed', result._result)

    def v2_runner_on_ok(self, result):
        host = result._host.get_name()
        self.log(host, 'ok', result._result)

    def v2_runner_on_skipped(self, result):
        host = result._host.get_name()
        self.log(host, 'skipped', self._get_item_label(getattr(result._result, 'results', {})))

    def v2_runner_on_unreachable(self, result):
        host = result._host.get_name()
        self.log(host, 'unreachable', result._result)

    # FIXME: not called
    def v2_runner_on_async_poll(self, result):
        host = result._host.get_name()
        jid = result._result.get('ansible_job_id')
        # FIXME, get real clock
        clock = 0
        self.runner_on_async_poll(host, result._result, jid, clock)

    # FIXME: not called
    def v2_runner_on_async_ok(self, result):
        host = result._host.get_name()
        jid = result._result.get('ansible_job_id')
        self.runner_on_async_ok(host, result._result, jid)

    # FIXME: not called
    def v2_runner_on_async_failed(self, result):
        host = result._host.get_name()
        jid = result._result.get('ansible_job_id')
        self.runner_on_async_failed(host, result._result, jid)

    def v2_playbook_on_start(self, playbook):
        name, _ = os.path.basename(os.path.dirname(playbook._basedir)).split('-')
        self.stage = name

    def v2_playbook_on_notify(self, handler, host):
        self.playbook_on_notify(host, handler)

    def v2_playbook_on_no_hosts_matched(self):
        self.playbook_on_no_hosts_matched()

    def v2_playbook_on_no_hosts_remaining(self):
        self.playbook_on_no_hosts_remaining()

    def v2_playbook_on_task_start(self, task, is_conditional):
        self.task['name'] = task.name
        self.log("all", "starting", dict())

    # FIXME: not called
    def v2_playbook_on_cleanup_task_start(self, task):
        pass  # no v1 correspondence

    def v2_playbook_on_handler_task_start(self, task):
        pass  # no v1 correspondence

    def v2_playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        self.playbook_on_vars_prompt(varname, private, prompt, encrypt, confirm, salt_size, salt, default)

    # FIXME: not called
    def v2_playbook_on_import_for_host(self, result, imported_file):
        host = result._host.get_name()
        self.playbook_on_import_for_host(host, imported_file)

    # FIXME: not called
    def v2_playbook_on_not_import_for_host(self, result, missing_file):
        host = result._host.get_name()
        self.playbook_on_not_import_for_host(host, missing_file)

    def v2_playbook_on_play_start(self, play):
        self.playbook_on_play_start(play.name)

    def v2_playbook_on_stats(self, stats):
        state = ""
        if len(stats.failures) > 0 or len(stats.dark) > 0:
            state = "failed"
        else:
            state = "ok"
        self.task['name'] = "ending"
        self.log("all", state, dict(state=state))

    def v2_on_file_diff(self, result):
        if 'diff' in result._result:
            host = result._host.get_name()
            self.on_file_diff(host, result._result['diff'])

    def v2_playbook_on_include(self, included_file):
        pass  # no v1 correspondence

    def v2_runner_item_on_ok(self, result):
        pass

    def v2_runner_item_on_failed(self, result):
        pass

    def v2_runner_item_on_skipped(self, result):
        pass

    def v2_runner_retry(self, result):
        pass
