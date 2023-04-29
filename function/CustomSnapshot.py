import boto3
import time
import requests
from requests_aws4auth import AWS4Auth


class CustomSnapshot():
	def __init__(self, host, region, service, repo, snapshot_prefix):
		credentials = boto3.Session().get_credentials()
		self.service = 'es'
		self.RETENTION_PERIOD = 30
		self.host = host
		self.region = region
		self.repo = repo
		self.awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)
		cur_time = time.gmtime()
		self.snapshot_name = snapshot_prefix+time.strftime("%Y-%m-%dt%H:%M:%S%z",cur_time)

	def check_health(self):
		path = '_cluster/health?pretty'
		url = self.host + path	
		r = requests.get(url, auth=self.awsauth)
		# print(r.status_code)
		return r.text


	def register_repo(self):
		##Register repository

		path = '_snapshot/'+self.repo# the Elasticsearch API endpoint
		url = self.host + path
		## payload for registering snapshot repo
		payload = {
		  "type": "s3",
		  "settings": {
		    "bucket": self.repo,
		    "region": self.region,
		    "role_arn": "arn:aws:iam::742801759527:role/snapshot-role"
		  }
		}
		headers = {"Content-Type": "application/json"}
		r = requests.put(url, auth=self.awsauth, json=payload, headers=headers)
		print(r.status_code)
		print(r.text)
		print(r.headers)




	def list_snapshots(self):
		get_path =  '_cat/snapshots/'+str(self.repo)+'/'+'?format=json&h=id&s=end_epoch'
		url = self.host + get_path
		r = requests.get(url, auth=self.awsauth)
		## Debugging output response
		# print(r.json())
		# print(r.status_code)
		# print(r.headers)

		## Print the Oldest snapshot-id
		# print(r.json()[0]['id'])

		return r.json()


	def delete_oldest_snapshot(self):
		if len(self.list_snapshots()) < self.RETENTION_PERIOD:
			print("Less than 30 snapshots")
			return False
		else:
			delete_path = '_snapshot/'+str(self.repo)+'/'+self.list_snapshots()[0]['id']
			delete_url = self.host + delete_path

			r = requests.delete(delete_url, auth=self.awsauth)

		    ## Debugging output response
			print(r.status_code)
			print(r.text)
			print(r.headers)

		return True

	def take_new_snapshot(self):
		path = '_snapshot/'+str(self.repo)+'/'+self.snapshot_name
		url = self.host + path

		r = requests.put(url, auth=self.awsauth)

		print(r.status_code)
		print(r.text)
		print(r.headers)