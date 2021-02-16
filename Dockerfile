FROM python:3.9-slim
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.version="$VERSION" \
      org.label-schema.maintainer="https://github.com/capybara1/" \
      org.label-schema.url="https://github.com/capybara1/Docker-Ansible" \
      org.label-schema.name="ansible" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://github.com/capybara1/Docker-Ansible" \
      org.label-schema.vcs-ref="$VCS_REF" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.dockerfile="/Dockerfile"
WORKDIR /project
RUN mkdir action_plugins files handlers inventories library roles tasks templates vars vault
COPY requirements.txt ./
COPY tasks.py ./
RUN apt-get update -qq \
 && apt-get install -yq --no-install-recommends openssh-client sshpass gnupg2 pass \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT ["/usr/local/bin/invoke"]


