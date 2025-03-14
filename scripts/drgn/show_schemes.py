from drgn import FaultError, NULL, Object, alignof, cast, container_of, execscript, implicit_convert, offsetof, reinterpret, sizeof, stack_trace
from drgn.helpers.common import *
from drgn.helpers.linux import *

import sys

if len(sys.argv) < 2:
    print('Usage: %s <kdamond pid>' % sys.argv[0])
    exit(1)

pid = int(sys.argv[1])

kthread_data = cast('struct kthread *', find_task(pid).worker_private).data
ctx = cast('struct damon_ctx *', kthread_data)
for s in list_for_each_entry('struct damos', ctx.schemes.address_of_(), 'list'):
    print(s)
