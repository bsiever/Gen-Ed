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
    # source /run/secrets/env \
    # echo "FLASK_INSTANCE_PATH=$FLASK_INSTANCE_PATH" > /app/src/.env \
    # echo "SECRET_KEY=\"$SECRET_KEY\"" >> /app/src/.env \
    # echo "OPENAI_API_KEY=\"$OPENAI_API_KEY\"" >> /app/src/.env \

# Setup the image with defaults (seems bad to do password here)
RUN <<EOF 
flask --app codehelp initdb
flask --app codehelp newuser --admin admin
# Just doesn't work.... Ugh
expect -c 'spawn flask --app codehelp setpassword admin ; expect "New password:"; send "password\n"; expect "Repeat:"; send "password\n"; interact;'
EOF

# RUN expect -c 'spawn flask --app codehelp setpassword admin; expect "New password:"; send "password\n"; expect "Repeat:"; send "password\n"; interact;'

# RUN --mount=type=secret,id=adminpass,target=/run/secrets/adminpass \
#     source /run/secrets/adminpass ; \
#     expect -c 'spawn flask --app codehelp setpassword admin; expect "New password:"; send "password\n"; expect "Repeat:"; send "password\n"; interact;'
#    expect -c 'spawn flask --app codehelp setpassword admin; expect "New password:"; send "$env(ADMINPASS)\n"; expect "Repeat:"; send "$env(ADMINPASS)\n"; interact;'

# Expose server port
EXPOSE 8080

# Remove base image's ENTRYPOINT
ENTRYPOINT []
#ENTRYPOINT [ "python3", "-m", "flask", "--app", "codehelp", "run"]
CMD [ "python3", "-m" , "flask", "--app", "codehelp", "run", "-p", "8080", "-h", "0.0.0.0"]
