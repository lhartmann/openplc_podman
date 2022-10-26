#! /bin/bash
PORT=3333

pod_image_exists() {
    podman image ls | grep -q openplc_editor
}
pod_exists() {
    podman ps -a | grep -q openplc_editor
}
pod_running() {
    podman ps | grep -q openplc_editor
}

ssh_generate_key() {
    [ -r $HOME/.ssh/id_rsa.pub ] \
    || ssh-keygen -q -f $HOME/.ssh/id_rsa -N ""
}
ssh_forget_host() {
    ssh-keygen -R "[127.0.0.1]:$PORT"
}
ssh_introduce_host() {
    ssh-keyscan -t ssh-rsa -p $PORT 127.0.0.1 >> $HOME/.ssh/known_hosts
}

pod_image_build() {
    podman build -t openplc_editor .
}

pod_start() {
    podman run --rm -d --name openplc_editor \
    -p $PORT:22 -v $HOME/.ssh/id_rsa.pub:/root/.ssh/authorized_keys:ro \
    --security-opt label=disable -v $HOME:/home \
    openplc_editor
}

pod_stop() {
    pod_running && podman stop openplc_editor
    pod_exists  && podman rm   openplc_editor
}

pod_exec() {
    ssh -Xt -p $PORT root@127.0.0.1 "$@"
}

ssh_generate_key

pod_stop
pod_image_exists || pod_image_build
pod_start

ssh_forget_host
while ! ssh_introduce_host; do
    sleep 1
done

pod_exec beremiz

ssh_forget_host
pod_stop

