
`pip install -e .`

cd src
mkdir instance
`pip install python-dotenv`

python -m pip install python-dotenv
`/Users/bsiever/.local/pipx/venvs/flask/bin/python3 -m pip install python-dotenv`
`/Users/bsiever/.local/pipx/venvs/flask/bin/python3 -m pip install -e .`


`flask --app codehelp initdb`
`flask --app codehelp newuser --admin admin`
`flask --app codehelp setpassword admin`  (Enter password twice)
`flask --app codehelp run`

test / eyWRDU 


`docker buildx build --tag gened --secret id=env,src=./env --secret id=adminpwd,src=./adminpass .`

# Interactive shell into named image
`docker run -it --entrypoint sh gened`

docker ps
`docker run --rm -it --entrypoint bash eager_hermann` 


# Build image & pass in local env and adminpass files for secrets

`docker buildx build --tag gened --secret id=env,src=./env --secret id=adminpass,src=./adminpass .`docker run -P gened_2`



docker buildx build --tag gened_2 --secret id=env,src=./.env .                  