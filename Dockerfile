FROM ubuntu:20.04

# set time zone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

# if compiling amd64, you can remove the following comments to use the CN sources
# set up CN sources
# RUN rm -rf /etc/apt/sources.list
# RUN rm -rf /etc/apt/sources.list.d/*
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal main restricted >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-updates main restricted >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal universe >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-updates universe >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal multiverse >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-updates multiverse >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-security main restricted >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-security universe >> /etc/apt/sources.list
# RUN echo deb [arch=amd64,i386] http://cn.archive.ubuntu.com/ubuntu focal-security multiverse >> /etc/apt/sources.list

RUN apt-get update

# unminimize ubuntu
RUN yes | unminimize

# config CN environment
RUN apt install language-pack-zh-hans -y

RUN echo LANG="zh_CN.UTF-8" >> /etc/environment
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> /etc/environment

RUN echo LANG="zh_CN.UTF-8" >> /etc/profile
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> /etc/profile

RUN echo LANG="zh_CN.UTF-8" >> ~/.bashrc
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> ~/.bashrc

RUN locale-gen
RUN /bin/bash -c "source ~/.bashrc"

# install xfce4
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y xfce4 xfce4-terminal

RUN apt install dbus-x11 -y
RUN apt install fonts-wqy-microhei -y
RUN apt install -y \
    gnome-user-docs-zh-hans \
    language-pack-gnome-zh-hans \
    fcitx \
    fcitx-pinyin \
    fcitx-table-wubi \
    vim

# install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-get install curl -y
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update
RUN apt install ros-noetic-desktop-full -y
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# install SAD dependence
RUN apt-get install -y \
    ros-noetic-pcl-ros \
    ros-noetic-velodyne-msgs \
    libopencv-dev \
    libgoogle-glog-dev \
    libeigen3-dev \
    libsuitesparse-dev \
    libpcl-dev\
    libyaml-cpp-dev \
    libbtbb-dev \
    libgmock-dev \
    pcl-tools \
    libspdlog-dev \
    libqglviewer-dev-qt5
# install pangolin
RUN apt-get install git -y
WORKDIR /root/software
RUN git clone https://github.com/stevenlovegrove/Pangolin.git 
RUN cd Pangolin && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install && \
    ldconfig

# set up vnc
RUN apt-get install tigervnc-standalone-server x11vnc -y
WORKDIR /root/.vnc
COPY ./docker/xstartup ./
RUN chmod u+x ~/.vnc/xstartup

# set up noVNC
WORKDIR /usr/lib
RUN git clone https://github.com/novnc/noVNC.git -o noVNC
WORKDIR /usr/lib/noVNC/utils
RUN git clone https://github.com/novnc/websockify.git -o websockify

WORKDIR /
COPY ./docker/startup.sh ./
RUN chmod u+x startup.sh
ENTRYPOINT ["./startup.sh"]
# ENTRYPOINT ["tail","-f","/dev/null"]

