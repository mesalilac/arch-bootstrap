FROM archlinux:latest


RUN useradd -m -d /home/testuser -s /bin/bash testuser

WORKDIR /home/testuser

RUN pacman-key --init

RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm sudo base-devel && \
    echo "testuser:test" | chpasswd

RUN echo "testuser ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/testuser-nopasswd && \
    chmod 0440 /etc/sudoers.d/testuser-nopasswd

COPY . .

USER testuser
ENV USER=testuser

CMD ["./bootstrap.sh"]
