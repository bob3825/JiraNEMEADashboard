__author__ = 'eel'

import requests
import json

class JiraRestAPI():
    def get_data_from_jira(self):
        json_reply=""
        userid = "jira.readonly"
        password = "4SUlER2ucsJR"
        try:
            api_to_collect_jql = 'https://jira.vizrt.com/rest/api/2/filter/22339'
            resp_1 = requests.get(api_to_collect_jql, auth=(userid, password))
            json_jql = json.loads(resp_1.text)
            jql = json_jql['jql']

            api = 'https://jira.vizrt.com/rest/api/2/search?jql=' + jql
            resp_2 = requests.get(api, auth=(userid, password))
            json_reply = resp_2.text
        except Exception as err:
            pass
        finally:
            return json_reply

class ProductObj(object):
    product = ""
    status = ""
    summary = ""
    planned_date_for_next_rc = ""
    planned_public_release_date = ""
    assignee = ""

if __name__ == '__main__':
    jira_api = JiraRestAPI()
    list_of_product = jira_api.get_data_from_jira()
    parsed = json.loads(list_of_product)
    print json.dumps(parsed, indent=4, sort_keys=True)
    #print list_of_product.encode('utf-8')


