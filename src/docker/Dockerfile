# https://github.com/willhallonline/docker-ansible/blob/master/ansible-core/alpine320/Dockerfile
FROM willhallonline/ansible:2.17.9-alpine-3.20

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

COPY ansible/ansible.cfg /ansible/ansible.cfg
COPY ansible/requirements.txt /ansible/requirements.txt
COPY ansible/requirements.yml /ansible/requirements.yml

RUN pip install -r /ansible/requirements.txt
RUN ansible-galaxy collection install -r /ansible/requirements.yml
