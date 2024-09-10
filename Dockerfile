FROM python:3.11-alpine

# Install git and expect
RUN apk add --no-cache git \
    expect 

WORKDIR /app
COPY . .
RUN pip3 install .
WORKDIR /app/src
RUN mkdir instance

RUN --mount=type=secret,id=env,target=/run/secrets/env \
    cp /run/secrets/env /app/src/.env 

# Setup the image with defaults (seems bad to do password here)
RUN <<EOF 
flask --app codehelp initdb
flask --app codehelp newuser --admin admin
EOF

# RUN --mount=type=secret,id=env,target=/run/secrets/env \
#     source /run/secrets/env ; \
#     expect -c 'spawn flask --app codehelp setpassword admin ; expect "New password:"; send "password\r"; expect "Repeat:"; send "password\r"; interact;'

#    expect -c 'spawn flask --app codehelp setpassword admin; expect "New password:"; send "$env(ADMINPASS)\r"; expect "Repeat:"; send "$env(ADMINPASS)\r"; interact;'

# Expose server port
EXPOSE 8080

# Remove base image's ENTRYPOINT
ENTRYPOINT []
#ENTRYPOINT [ "python3", "-m", "flask", "--app", "codehelp", "run"]
CMD [ "python3", "-m" , "flask", "--app", "codehelp", "run", "-p", "8080", "-h", "0.0.0.0"]
