import os
import json
import urllib.parse
import boto3
from CustomSnapshot import CustomSnapshot



def lambda_handler(event, context):
	AOSS_EP = os.environ.get('AOSS_ENDPOINT')
	AOSS_REG = os.environ.get('AOSS_REGION')
	SNAP_REPO = os.environ.get('SNAPSHOT_REPO_NAME')
	SNAP_PRE = os.environ.get('SNAPSHOT_PREFIX')
	cs = CustomSnapshot(AOSS_EP,AOSS_REG,'es',SNAP_REPO,'snapshot-')
	print(cs.check_health())
	# print(cs.list_snapshots())

	# if len(cs.list_snapshots()) == 0:
	# cs.register_repo()
	# cs.delete_oldest_snapshot()
	# cs.take_new_snapshot()
