#!/bin/bash

<<COMMENT
Bash script that get repository list for a github organization, scan it using detect-secrets and save results in a file

Requirements : a github token to call the API
              Name of the organization

Sample of use:
./simple-secret-scanner.sh $my_token $my_org

testing on Debian Linux 11
COMMENT

export github_token=$1
export github_org_name=$2

function get_repo_list () {
  # return all repo list on the organization
  org_repo_list=$(curl --silent --header "Authorization: Bearer ${github_token}" "https://api.github.com/orgs/${github_org_name}/repos?per_page=500" | jq .[].name | tr --delete '"')
  #org_repo_list=$(curl --silent "https://api.github.com/orgs/${github_org_name}/repos?per_page=500" | jq .[].name | tr --delete '"')
  echo ${org_repo_list}
}

function clone_and_scan () {
  # clone the repository and scan it for secrets
  # input : $1 = repo_name
  local repo_name=$1
  cd /tmp
  git clone --depth 1 https://${github_token}@github.com/${github_org_name}/${repo_name}.git
  /usr/local/bin/detect-secrets scan --all-files ./${repo_name} > /tmp/detect-secrets-results/${repo_name}
}

function save_results_in_file () {
  # parse the result and save it into a file
  # input : $1 = repo_name
  # get all values
  /usr/local/bin/detect-secrets audit --report --json /tmp/detect-secrets-results/$1 | jq -r '.results[] | [.filename, (.lines | to_entries[] | "\(.key):\(.value)"), .secrets, (.types[])] | @csv' >> /tmp/detect-secrets-results/${github_org_name}_results.csv
  rm -rf /tmp/$1
}

function remove_false_positifs () {
  # remove some false positifs find on GSS results
  regex="dummy|.git|src/test|integrity=sha|secret_key|api_url|inherit|none|fake|image|filename|example|fileName|guest|VAULT_SECRET_ENVIRONMENT|secret/data|ABCDEFG|valueSubject|Empty|topic|secretReference|message|Selector|name|SecretRequest|versionName|vault_secret_path|PostMapping|preference|PATH|hooks.slack.com|secretID|secret-id|test|TEST|expiredPassword|missingPassword|wrongLoginPassword|wrongPassword|SecretFeature|keySubject|zzz|xxx|shared|blank|existing_file_sha|: ApiKey|: api-key|private_key_type|login:password|gitHead|commit|store:|: API_KEY|= x-Gateway-APIKey|test:|code:|consumersecret:|sha256-|lostPasswordSuccess|ProductId|revision:"
  grep -v -i -E "${regex}" /tmp/detect-secrets-results/${github_org_name}_results.csv > /tmp/${github_org_name}_results.csv
  rm -rf /tmp/detect-secrets-results
}

function main () {
  # main function
  # get all repo
  get_repo_list
  echo "get_repo_list ok"

  # create detect-secrets directory result
  mkdir /tmp/detect-secrets-results
  touch /tmp/detect-secrets-results/${github_org_name}_results.csv
  echo "org,repo_name,filename,line_number,value,secret_type,category" >> /tmp/detect-secrets-results/${github_org_name}_results.csv

  # for each repo, clone, scan and save results
  for repo_name in ${org_repo_list}
  do
    echo "Scanning ${repo_name}"
    clone_and_scan ${repo_name}
    echo "Save results for ${repo_name}"
    save_results_in_file ${repo_name}
  done

  #remove false positifs
  remove_false_positifs
  echo "Scan successfully performed ! You can retrieve results in /tmp/${github_org_name}_results.csv"

}

function check_requirements () {
  # install requirements
  which detect-secrets
  if [ $? -eq 1 ]
  then
    pip3 install detect-secrets
  fi
}

check_requirements
echo "requirements ok"
main
