FROM ros:DISTRO

RUN apt update && apt install -y \
  curl \
  python3-bloom \
  python3-rosdep \
  fakeroot \
  debhelper \
  dh-python \
  && apt clean && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://tutrobo.github.io/tutrobo-ros-apt/tutrobo-ros-apt.key -o /usr/share/keyrings/tutrobo-ros-apt.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/tutrobo-ros-apt.gpg] https://tutrobo.github.io/tutrobo-ros-apt $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
  > /etc/apt/sources.list.d/tutrobo-ros-apt.list \
  && echo "yaml https://tutrobo.github.io/tutrobo-ros-apt/rosdep.yaml" > /etc/ros/rosdep/sources.list.d/99-tutrobo-ros-apt.list

WORKDIR /workspace

COPY entrypoint.sh /

CMD [ "/entrypoint.sh" ]
