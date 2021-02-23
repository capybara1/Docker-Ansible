FROM python:3.9-slim
ARG VERSION
ARG VCS_REF
ARG BUILD_DATE
ARG USER_ID=1000
ARG GROUP_ID=${USER_ID}
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
COPY vault ./vault
RUN chmod +x tasks.py vault/*
RUN apt-get update -qq \
 && apt-get install -yq --no-install-recommends sudo openssh-client sshpass gnupg2 pass netcat vim \
 && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt
RUN groupadd -g ${GROUP_ID} ansible \
 && useradd -l -m -u ${USER_ID} -g ansible -s /bin/bash ansible \
 && usermod -aG sudo ansible \
 && chown ansible:ansible /project
RUN echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'export GPG_TTY=$(tty)' >> /etc/profile
USER ansible
ENTRYPOINT ["/bin/bash", "-l"]


