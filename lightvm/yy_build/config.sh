cat > /etc/apt/sources.list << EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-proposed main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-proposed main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
EOF
