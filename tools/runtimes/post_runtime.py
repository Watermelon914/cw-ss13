'''
    post_runtime.py

    Script that takes in information about a runtime error,
    processes it and posts it as an issue to gitlab
'''

from sys import argv
from os import environ
import requests

from runtime import Runtime

# Base URL for the GitLab issue API
BASE_URL = "https://gitlab.com/api/v4/projects/{}/issues"

# Search for {} as the title
LIST_ISSUES_URL = BASE_URL + "?search={}&in=title"
# Reopen issue {}
REOPEN_ISSUE_URL = BASE_URL + "/{}?state_event=reopen"
# Comment on issue {0} with body {1}
COMMENT_ISSUE_URL = BASE_URL + "/{}/notes?body={}"
# Open a new issue with {0} as the title and {1} as the body
OPEN_ISSUE_URL = BASE_URL + "?title={}&description={}&labels=Runtime&confidential=true"

def handle_issue(pid, pat):
    if not pid or not pat:
        return

    runtime = Runtime(*[argv[i] for i in range(1, 5)])

    # Check if there's already an issue for the runtime
    list_issues_url = LIST_ISSUES_URL.format(pid, runtime.get_title())
    response = requests.get(list_issues_url, headers={"Private-Token": pat, "Content-Type": "application/json"})

    # There is an issue already, so just re-open it if necessary
    if response.status_code == 200:
        issues = response.json()

        if issues:
            # May actually be multiple of them
            # Make sure there isn't an open issue for the runtime already.
            for issue in issues:
                if issue.get("state") == "opened":
                    return

            # They were all closed, so re-open the first issue GitLab handed us
            issue = issues[0]
            iid = issue.get("iid")

            reopen_url = REOPEN_ISSUE_URL.format(pid, iid)
            response = requests.put(reopen_url, headers={"Private-Token": pat})

            # Issue was successfully re-opened
            # Leave a comment to know that it was re-opened because the runtime re-occured
            if response.status_code == 200:
                comment = "The issue has been re-opened due to the runtime re-occuring. Details are provided below.\n\n{}".format(runtime.get_body())

                comment_url = COMMENT_ISSUE_URL.format(pid, iid, comment)
                requests.post(comment_url, headers={"Private-Token": pat})
                return

    # At this point we know that there was no issue already, so open a new one
    open_url = OPEN_ISSUE_URL.format(pid, runtime.get_title(), runtime.get_body())
    requests.post(open_url, headers={"Private-Token": pat, "Content-Type": "application/json"})

if __name__ == "__main__":
    PID = environ["GITLAB_RUNTIME_PID"]
    PAT = environ["GITLAB_RUNTIME_PAT"]

    handle_issue(PID, PAT)