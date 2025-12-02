FROM ubuntu:22.04

# 避免交互式前端的干扰
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1. 安装依赖 + 证书 
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    wget git sed make binutils build-essential diffutils gcc g++ bash patch gzip \
    bzip2 perl tar cpio unzip rsync file bc findutils libncurses-dev python3 \
    libssl-dev gawk cmake bison flex bash-completion parted curl xz-utils \
    openssh-server gdb sudo vim locales net-tools iputils-ping \
    ca-certificates \
    && update-ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. 配置 SSH 服务
# 允许 root 登录
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# 3. 设置语言环境
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# 4. 创建开发用户 'k230' 并配置 sudo
RUN useradd -m -s /bin/bash k230 && \
    echo "k230:k230" | chpasswd && \
    adduser k230 sudo && \
    echo 'k230 ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# 5. 准备目录并修正权限
WORKDIR /workspace
RUN mkdir -p /opt/toolchain && chown -R k230:k230 /opt/toolchain

# 添加进环境变量
ENV PATH="/opt/toolchain/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.0.2/bin:${PATH}"

USER k230

# 6. 启动命令
# 因为当前身份已切换为 k230 (普通用户)，而 sshd 默认需要 root 权限才能监听 22 端口
# 所以这里利用我们配置好的 NOPASSWD sudo 来启动 SSH 服务
EXPOSE 22
CMD ["sudo", "/usr/sbin/sshd", "-D"]